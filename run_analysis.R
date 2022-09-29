##set the environment
library(readr)
library(dplyr)

##download the data
if(!file.exists("./data")){dir.create("./data")}
url1<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url1,"./data/wearable.zip",method="curl")
unzip("./data/wearable.zip", exdir="./data")

##extract the names of the data set and activities
cnames<-read_table("./data/UCI HAR Dataset/features.txt",col_names=F)
anames<-read_table("./data/UCI HAR Dataset/activity_labels.txt",col_names=F)

##read the data into a table with readr package
y_test<-read_table("./data/UCI HAR Dataset/test/Y_test.txt", col_names="activity")
x_test<-read_table("./data/UCI HAR Dataset/test/X_test.txt", col_names=F)
subject_test<-read_table("./data/UCI HAR Dataset/test/subject_test.txt", col_names="subject")
##rename the columns of the x data
colnames(x_test)<-cnames$X2
##identify the columns with mean or standard deviation values then select and 
##create a new table of data. Then bind all test data by column
scol<-grep("mean|std",names(x_test))
x_test<-select(x_test,all_of(scol))
test_data<-cbind(subject_test,y_test,x_test)

##repeat for train data
y_train<-read_table("./data/UCI HAR Dataset/train/Y_train.txt", col_names="activity")
x_train<-read_table("./data/UCI HAR Dataset/train/X_train.txt", col_names=F)
colnames(x_train)<-cnames$X2
subject_train<-read_table("./data/UCI HAR Dataset/train/subject_train.txt", col_names="subject")
scol<-grep("mean|std",names(x_train))
x_train<-select(x_train,all_of(scol))
train_data<-cbind(subject_train,y_train,x_train)

##row bind all data into new table of total dat
total_data<-rbind(train_data,test_data)
##change the activity numbers back to the actual activity
total_data$activity<-anames[total_data$activity, 2]
##group data by subject first then by activity
activitygroups<-group_by(total_data, subject,activity)
##average each variable of data by activity
Q5data<-summarize_all(activitygroups,mean)

