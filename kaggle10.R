# 3. Load functions
source("./makeClusters.R")
source("./makeBow.R")
source("./makeDateTime.R")
source("./makeBigram.R")
source("./makeQM.R")

# 2. Load packages
library(tm)
library(R.utils)
library(RWeka)
library(RWekajars)
options(mc.cores=1)


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
    makeBigram("Headline"),
    makeBigram("Abstract"),
    Popular=factor(popular)
)


preds <- model.matrix(Popular~.-1, data=predictors)
colnames(preds) <- make.names(colnames(preds))
dim(preds)


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

predTrain <- head(preds, nTrain)
predTest  <- tail(preds, nTest)

f <- list()
pop <- train$Popular
f[[1]] <- read.csv("./pred0.csv",head=F)
f[[2]] <- read.csv("./pred1.csv",head=F)
f[[3]] <- read.csv("./pred2.csv",head=F)
f[[4]] <- read.csv("./pred3.csv",head=F)
f[[5]] <- read.csv("./pred4.csv",head=F)
f[[6]] <- read.csv("./pred5.csv",head=F)
f[[7]] <- read.csv("./pred6.csv",head=F)
f[[8]] <- read.csv("./pred7.csv",head=F)
f[[9]] <- read.csv("./pred8.csv",head=F)
f[[10]] <- read.csv("./pred9.csv",head=F)
f[[11]] <- read.csv("./pred10.csv",head=F)

sapply(f, dim)
ne <- list()
for (i in seq_along(f)) {
    ne[[i]] <- f[[i]][,1] != train$Popular
}

badInd <- Reduce("&", ne)

clust <- kmeans(predTrain[,1:36], centers=3, iter.max = 10000)
library(flexclust)
clust_kcca <- as.kcca(object = clust, predTrain[,1:36])
clust_test <- predict(clust_kcca, newdata = predTest[,1:36])
summary(clust_test)
str(clust$cluster)

# Cluster indecies
clTr1 <- grep("1", clust$cluster)
clTr2 <- grep("2", clust$cluster)
clTr3 <- grep("3", clust$cluster)
clTe1 <- grep("1", clust_test)
clTe2 <- grep("2", clust_test)
clTe3 <- grep("3", clust_test)
length(c(clTe1, clTe2, clTe3))

dim(predTrain[clTr1, ])
tail(clTr1)

# 1st Cluster
length(clTr1)
write.csv(clTr1,
           "/home/sergey/MachineLearning/kaggle/clTr1.csv",
           row.names = F)
write.csv(clTe1 ,
           "/home/sergey/MachineLearning/kaggle/clTe1.csv",
           row.names = F)


