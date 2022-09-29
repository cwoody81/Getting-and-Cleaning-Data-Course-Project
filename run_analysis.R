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
##combine test data columns
test_data<-cbind(subject_test,y_test,x_test)

##repeat for train data
y_train<-read_table("./data/UCI HAR Dataset/train/Y_train.txt", col_names="activity")
x_train<-read_table("./data/UCI HAR Dataset/train/X_train.txt", col_names=F)
subject_train<-read_table("./data/UCI HAR Dataset/train/subject_train.txt", col_names="subject")
colnames(x_train)<-cnames$X2
train_data<-cbind(subject_train,y_train,x_train)

##row bind all data into new table of total data
total_data<-rbind(train_data,test_data)
##identify the columns with mean or standard deviation values then select and 
##save back to total data. Then bind all test data by column
scol<-grep("mean|std",names(total_data))
total_data<-select(total_data,subject,activity,all_of(scol))

##change the activity numbers back to the actual activity
total_data$activity<-anames[total_data$activity, 2]
## change labels to the appropriate descriptive variable names
names(total_data)<-gsub("Acc", "Acceleration", names(total_data))
names(total_data)<-gsub("Gyro", "Gyroscopic", names(total_data))
names(total_data)<-gsub("Mag", "Magnitude", names(total_data))
names(total_data)<-gsub("^t", "Time", names(total_data))
names(total_data)<-gsub("^f", "Frequency", names(total_data))
names(total_data)<-gsub("-mean()", "Mean", names(total_data), ignore.case = TRUE)
names(total_data)<-gsub("-std()", "STD", names(total_data), ignore.case = TRUE)
names(total_data)<-gsub("-freq()", "Frequency", names(total_data), ignore.case = TRUE)
names(total_data)<-gsub("BodyBody", "Body", names(total_data))

##group data by subject first then by activity
activitygroups<-group_by(total_data, subject,activity)
##average each variable of data by activity
Q5data<-summarize_all(activitygroups,mean)
## create csv file of final data.
write.csv(Q5data, "Tidydata.csv")

