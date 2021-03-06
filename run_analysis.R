 # download the zip file
url_zip<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(url_zip,destfile = "./data/dataset.zip")

# upzip the file in ./data/

# install the dplyr package
library(dplyr)

# read the columns names of the training and test sets
features<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/features.txt", sep = "", header = FALSE)
features<-tbl_df(features)
features
  ## result:
  ## columns of the names of 
  ## V1. column number
  ## V2. name : 561 different features

# select the column names including mean or standard deviation

##  index  = array of the column numbers containing mean or standard deviation: to be used to select the column of the data sets.
index<-grep("^[tf].*[Mm]ean[^F]|^[tf].*[sS]td", features$V2)

## headers= array of headers containing mean or standard deviation: to be used as headers for the data set
headers<-grep("^[tf].*[Mm]ean[^F]|^[tf].*[sS]td", features$V2, value= TRUE)
  ## result: 66 columns selected
  ## column names can be separated into signal, variable, axis


# read the type of activities
activity<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt", sep = "", header = FALSE)
activity<-tbl_df(activity)
activity
  ## result: 6 rows 2 columns
  ## V1. activity (training set label) number
  ## V2. activity executed 1. walking 2. walking upstairs 3. walking downstairs 4. sitting 5. standing 6. laying

# read the training set
training_set<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
training_set<-tbl_df(training_set)
training_set<-select(training_set, index)
training_set
  ## result:
  ## 7.352 observations and 66 columns

# define the names of the training_set data frame
names(training_set)<-headers

# read the labels of the training set
training_set_labels<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt", sep = "", header = FALSE)
training_set_labels<-tbl_df(training_set_labels)
training_set_labels
unique(training_set_labels$V1)
  ## result:
  ## 7.352 observations and 1 column // unique values 1 ... 6

# merge the labels and the activities
training_activity<-tbl_df(merge(training_set_labels,activity,by.x= "V1", by.y= "V1"))

# read the data of the subjects who performed the training activities
subjects_train<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt", sep = "", header = FALSE)
subjects_train<-tbl_df(subjects_train)
unique(subjects_train$V1)
  ## result:
  ## 7.352 observations 1 column // unique values 1 ... 30

# add the subjects and the activity to the training set
training_set<-cbind(subjects_train,training_activity$V2, training_set)
names(training_set)[c(1,2)]<-c("subject","activity")

# read the test set
test_set<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
test_set<-tbl_df(test_set)
test_set<-select(test_set, index)
test_set
  ## result:
  ##  2.947 observations and 66 columns

# define the names of the test_set data frame
names(test_set)<-headers

# read the labels of the test set
test_set_labels<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/y_test.txt", sep = "", header = FALSE)
test_set_labels<-tbl_df(test_set_labels)
test_set_labels
unique(test_set_labels$V1)
  ## result:
  ## 2.947 observations and 1 column // unique vaLues 1 ... 6

# merge the labels and the activities
test_activity<-tbl_df(merge(test_set_labels,activity,by.x= "V1", by.y= "V1"))

# read the data of the subjects who performed the test activities
subjects_test<-read.csv("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt", sep = "", header = FALSE)
subjects_test<-tbl_df(subjects_test)
subjects_test
unique(subjects_test$V1)
  ## result:
  ## 2.947 observations 1 column // unique values 1 ... 30

# add the subjects and the activity to the test set
test_set<-cbind(subjects_test,test_activity$V2, test_set)
names(test_set)[c(1,2)]<-c("subject","activity")

# ad a variable called 'set'to the data to label the observations to eiher training or test
training_set<-cbind("training", training_set)
names(training_set)[1]<-"set"
test_set<-cbind("test", test_set)
names(test_set)[1]<-"set"

# merge the training set and the test set
total_set<-rbind(training_set,test_set)

# reorder the columns. Gather the variable names in one column and the values in another column
library("tidyr")
total_set<-gather(total_set,signal_measure_axis,value,-(set:activity))

# split the column variaable names into 3 columns: signal, measure and axis
total_set<-separate(total_set,signal_measure_axis,c("signal","measure","axis"),sep="-")

# alter the N/A values into '---' to emphasise these values are not applicable instead of not available
total_set$axis[is.na(total_set$axis)]<-"---"
