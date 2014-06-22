### <code r>

### Working directory #########################################################
setwd(choose.dir("C:/LAB/Cursos/Coursera/C3_Getting/Project")); getwd()
# setwd("C:/LAB/Cursos/Coursera/C3_Getting/Project"); getwd()

### Data source ###############################################################
dURL <- URLdecode("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")
basename(dURL) # "UCI HAR Dataset.zip"

### For a full data description uncomment and run the following line.
# browseURL("http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones") 

### Download data #############################################################
### First verify if the file exists. If no, download it. After that, unzip it.
if (!file.exists(basename(dURL))) {
          setInternet2(TRUE); setInternet2(NA)
          download.file(dURL, dest=basename(dURL), mode='wb')
          unzip(basename(dURL))}

dir("UCI HAR Dataset") ### list files unzipped

### Data Reading ##############################################################

### Labels of activities used on 'y_.*.txt' files.
# id    "1"       "2"                "3"                  "4"       "5"        "6"     
# descr "WALKING" "WALKING_UPSTAIRS" "WALKING_DOWNSTAIRS" "SITTING" "STANDING" "LAYING"
activities <- read.table('UCI HAR Dataset/activity_labels.txt', head=F, col.names=c("id", "descr"))

### File names of data sets (Test & Train)
fnTest  <- paste0('UCI HAR Dataset/test/',  c("subject_test.txt", "y_test.txt",  "X_test.txt"))
fnTrain <- paste0('UCI HAR Dataset/train/', c("subject_train.txt","y_train.txt", "X_train.txt"))

### Reading...
### For best performance consider use {data.table} package.
system.time(dTest  <- do.call(cbind, lapply(fnTest,  read.table, head=F)))
system.time(dTrain <- do.call(cbind, lapply(fnTrain, read.table, head=F)))

# subject: individuals (1:30)
# subject_test:  c(2,4,9,10,12,13,18,20,24)
# subject_train: c(1,3,5,6,7,8,11,14,15,16,17,19,21,22,23,25,26,27,28,29,30)
table(dTest[,1]); table(dTrain[,1]) ### subjects

### Combine data sets
dAll <- rbind(dTest, dTrain)
names(dAll)[1:2] <- c('SUB', 'LAB'); head(names(dAll))
# write.table(dAll, "dAll.txt") ### Backup

### Features (variable names)
features   <- read.table('UCI HAR Dataset/features.txt', header=F); head(features)

### Selecting variables concerning to mean and standard deviation
ftSel      <- grep("-mean\\(\\)|-std\\(\\)", tolower(features[,2]))
ftSelNames <- grep("-mean\\(\\)|-std\\(\\)", tolower(features[,2]), value=T)
features[ftSel,]; nrow(features[ftSel,])
varSel <- paste0("V",features[ftSel,1]); varSel

### Extracting data concerning to variables selected
{
          dTidy <- dAll[c("SUB","LAB", varSel)]
          names(dTidy) <- c("SUB","LAB", ftSelNames)
          dTidy$ACT <- activities$descr[dTidy$LAB]
          dTidy <- dTidy[,c(1:2,69,3:68)]
}

### Some tests with tapply
tapply(dTidy[,5], dTidy$SUB, mean)
tapply(dTidy[,5], dTidy$ACT, mean)

### Data aggregation
dTidy2 <- aggregate(dTidy[,4:69], list(Subject=dTidy$SUB, Label=dTidy$LAB, Activity=dTidy$ACT), mean)

str(dTidy2)
head(dTidy2[,1:6]); tail(dTidy2[,1:6])
# write.table(dTidy2, "dTidy2.txt", row.names=F) ### Backup

### </code>
