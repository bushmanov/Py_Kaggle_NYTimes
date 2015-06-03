# 1. Load functions
source("./makeClusters.R")
source("./makeBow.R")
source("./makeDateTime.R")
source(("./makeQM.R"))

# 2. Load packages
library(tm)
library(caret)
library(randomForest)
library(ROCR)
library(caTools)
library(R.utils)


# 2. Load data
train <- read.csv("./kaggle/NYTimesBlogTrain.csv",colClasses = colClasses("fffcccicii"))
test  <- read.csv("./kaggle/NYTimesBlogTest.csv", colClasses = colClasses("fffcccici"))

# 3. Preprocess data
nTrain <- nrow(train)
nTest <- nrow(test)
popular <- c(train$Popular, rep(1, nTest)) # delete 1's
all <- rbind(train[, !(colnames(train) %in% "Popular")], test)
all$NewsDesk <- ifelse(all$NewsDesk == "", "empty", all$NewsDesk)
all$SectionName <- ifelse(all$SectionName == "", "empty", all$SectionName)
all$SubsectionName <- ifelse(all$SubsectionName == "", "empty", all$SubsectionName)
all$WordCount <- log(all$WordCount + .001) # delete if AUC drops
sapply(all, class)
# 4. Make predictors
predictors <- cbind(
    all[, c("NewsDesk", "SectionName", "SubsectionName", "WordCount")],
    makeBow("Headline"),
    makeBow("Abstract"),
    makeDateTime(),
    makeQM(),
    Popular=factor(popular)
)

# predTrain <- head(predictors, nTrain)
# predTest  <- tail(predictors, nTest)
preds <- model.matrix(Popular~.-1, data=predictors)


write.csv( head(preds, nTrain),
           "/home/sergey/MachineLearning/kaggle/data1.csv",
           row.names = F)
write.csv(train$Popular,
          "/home/sergey/MachineLearning/kaggle/target.csv",
          row.names = F)
write.csv(tail(preds, nTest),
          "/home/sergey/MachineLearning/kaggle/data1Tr.csv",
          row.names = F)
dim(preds)
