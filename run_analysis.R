getwd()
setwd("c:/R/Course3/Week4/")
rm(list = ls())
cat("\014")

?data.table

#includes
library(data.table)
library(plyr)

#read in the list of activities
?read.table
dtActivities <- data.table(read.table("./Project/data/activity_labels.txt", sep=" ", col.names = c("ActivityId","ActivityDescription")))

#column names/variables for dataset
dtFeatures <- data.table(read.table("./Project/data/features.txt", sep=" ", col.names = c("FeatureId","FeatureDescription")))

dtSubjectTrain <- data.table(read.table("./Project/data/train/subject_train.txt", sep=" ", col.names = c("SubjectId")))
dtSubjectTest <- data.table(read.table("./Project/data/test/subject_test.txt", sep=" ", col.names = c("SubjectId")))

dtActivityTrain <- data.table(read.table("./Project/data/train/y_train.txt", sep=" ", col.names = c("ActivityId")))
dtActivityTest <- data.table(read.table("./Project/data/test/y_test.txt", sep=" ", col.names = c("ActivityId")))

# Step 4 in the provided instructions. 
# Use the feature names to label the data columns.
#one or more spaces
dtFeaturesTrain <- data.table(read.table("./Project/data/train/X_train.txt", sep="", col.names = dtFeatures$FeatureDescription))
dtFeaturesTest <- data.table(read.table("./Project/data/test/X_test.txt", sep="", col.names = dtFeatures$FeatureDescription))

# Step 4 in the provided instructions. 
#Add the subject and activties
dtFeaturesTrain$SubjectId <- dtSubjectTrain$SubjectId
dtFeaturesTrain$ActivityId <- dtActivityTrain$ActivityId
dtFeaturesTest$SubjectId <- dtSubjectTest$SubjectId
dtFeaturesTest$ActivityId <- dtActivityTest$ActivityId

# Step 3 in the instructions provided.
# Add the ActivityDescription via an inner join
dtTrain <- merge(dtFeaturesTrain, dtActivities, all=TRUE, by=c("ActivityId"), sort = FALSE)
dtTest <- merge(dtFeaturesTest, dtActivities, all=TRUE, by=c("ActivityId"), sort = FALSE)

# Step 4 in the provided instructions. 
dtTrain$sample.set <- rep("train", nrow(dtTrain))
dtTest$sample.set <- rep("test", nrow(dtTest))

# Step 1 in the instructions provided.
#union the training and testing data.tables together. 
dtAll <- rbind(dtTrain, dtTest)

# Step 2 in the instructions provided. 
# We want only the ActivityId, ActivityDescription, SubjectId, sample.set and any column with mean or std in the column name
columnList <- grepl("^Activity|^Subject|\\.mean\\.|\\.std\\.|sample\\.set", names(dtAll))
dtAllColSubset <- dtAll[,columnList, with = FALSE]
names(dtAllColSubset)
dtAllColSubset[1:3]

# Step 5 creates a second, independent tidy data set with the average of each variable for each activity and each subject.
setkey(dtAllColSubset, ActivityDescription, SubjectId)

# Get the mean of the numeric columns.
df <- as.data.frame(dtAllColSubset)
dfAgg <- aggregate(df[, 2:67], list(df$ActivityDescription, df$SubjectId), mean)

head(dfAgg)

# Lose the default column names. 
dfAgg <- rename(dfAgg, c("Group.1"="ActivityDescription", "Group.2"="Subjectid"))

# Output results.
df
dfAgg
