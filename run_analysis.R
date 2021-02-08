# main script to run
library(data.table)
library(dplyr)

# define where the files are! change "dataDir" to you dir for data to run 

dataDir ="UCI HAR Dataset/"

tidyData ="myData.txt"
meanSbjExcData ="meanSbjExcData.txt"


#feature text location
features = paste(dataDir,"features.txt",sep = "")
# subject location
testSbj = paste(dataDir,"test/subject_test.txt",sep = "")
trainSbj = paste(dataDir,"train/subject_train.txt",sep = "")

# Exercise location
testExe = paste(dataDir,"test/y_test.txt",sep = "")
trainExe = paste(dataDir,"train/y_train.txt",sep = "")

# data record by device
testData = paste(dataDir,"test/X_test.txt",sep = "")
trainData = paste(dataDir,"train/X_train.txt",sep = "")


##Processing the DATA

dt <- data.table()

#read data (you can try 150 roll for a start) 
#dt <- fread(testData, nrows=150)

# read test data, train data in the data table

dt <- fread(testData)
dt <- rbind(dt,fread(trainData))

#read colum names from features.text, set the column names according feature
featureNames <- fread(features)
setnames(dt,as.character(featureNames$V2))

# subset mean std var with regX -- 89 var in total out of 561 (What did you get?)
dt <- dt[, names(dt) %like% "(.*)[Ss]td(.*)|(.*)[mM]ean(.*)", with=F]

## Reading the subject id as column

subjectDt <- fread(testSbj)
subjectDt <- rbind(subjectDt,fread(trainSbj))
setnames(subjectDt,"studysubjects")


## Read the Excerises and 

#read test and train data from y_test.txt amd y_train.txt
exeDt <- fread(testExe)
exeDt <- rbind(exeDt,fread(trainExe))


# set the table name to be exerciseid
setnames(exeDt,"execeriseid")

# read in exercise from activity_labels.txt
execerise = paste(dataDir,"activity_labels.txt",sep = "")
exefactorDt <- fread(execerise)
setnames(exefactorDt,"V2", "execerise")
factor(exefactorDt$execerise)


#setkey(exeDt,execeriseid)
#setkey(exefactorDt,V1)
# merge 2 tables without sorting according to execeriseid's index
execerisDT<- merge(exeDt,exefactorDt, by.x = "execeriseid", by.y = "V1",all.x = T, sort = F)


### cbind all DT together, write the file

# Cbind all data tables together ,,, not very elegant ..:) does the job

resultDT <-data.table()
resultDT <- cbind(resultDT,subjectDt)
resultDT <- cbind(resultDT,execerisDT)
resultDT <- cbind(resultDT,dt)

# write data to working dir with name defined in the beginning of the script
fwrite(resultDT,tidyData)

#data set represent average of each variable for each activity and each subject
meanSbjExc<- resultDT %>% group_by(studysubjects,execerise) %>% summarise(across(names(dt),mean,na.rm = TRUE))
# save to text file
fwrite(meanSbjExc,meanSbjExcData)



