# 1. Load functions
source("./makeBow.R")
source("./makeDateTime.R")
source("./makeQM.R")
source("./makeNC.R")
source("./makeNW.R")


# 2. Load packages
library(tm)
library(caret)
library(ROCR)
library(caTools)
library(R.utils)


# 2. Load data
train <- read.csv("./kaggle/NYTimesBlogTrain.csv", stringsAsFactors = F)
test  <- read.csv("./kaggle/NYTimesBlogTest.csv", stringsAsFactors = F)

# 3. Preprocess data
nTrain <- nrow(train)
nTest <- nrow(test)
all <- rbind(train[, !(colnames(train) %in% c("UniqueID", "Popular"))],
             test[, !(colnames(test) %in% c("UniqueID"))])
all$NewsDesk <- ifelse(all$NewsDesk == "", "empty", all$NewsDesk)
all$NewsDesk <- ifelse(all$NewsDesk == "Sports", "empty", all$NewsDesk)
all$SectionName <- ifelse(all$SectionName == "", "empty", all$SectionName)
all$SectionName <- ifelse(all$SectionName == "Sports", "empty", all$SectionName)
all$SubsectionName <- ifelse(all$SubsectionName == "", "empty", all$SubsectionName)
all$WordCount <- log(all$WordCount + .001) # delete if AUC drops



# 4. Make predictors
predictors <- cbind(
    apply(all[, c("NewsDesk", "SectionName")], 2, factor),
    WordCount = all$WordCount,
    makeDateTime(),
    makeQM(),
    makeNC(),
    makeNW()
)


# expand factors
preds <- as.data.frame(model.matrix(~.-1, data=predictors))
colnames(preds) <- make.names(colnames(preds))

# split train/test
tr <- head(preds, nTrain)
tr <- data.frame(tr, Popular =train$Popular)
te <- tail(preds, nTest)
glm_mod <- glm(Popular~., data=tr, family = binomial)
summary(glm_mod)

# AUC of the base model
predictions <- predict(glm_mod, type="response")
predROCR = prediction(predictions, tr$Popular)
performance(predROCR, "auc")@y.values[[1]]

# StepAIC
library(MASS)
glm_mod2 <- stepAIC(glm_mod, trace=F, direction = "backward")
summary(glm_mod2)

preds_glm <- predict(glm_mod2, newdata = te, type="response")
write.csv(preds_glm, "./preds_glm.csv", row.names = F)

# Cross validated AUC
folds <- createFolds(tr$Popular, k=5, returnTrain = T)
for (f in folds) {
    predictions <- predict(glm_mod2, newdata=tr[-f,], type="response")
    predROCR = prediction(predictions, tr[-f,"Popular"])
    print(performance(predROCR, "auc")@y.values[[1]])
}


# Cross validated AUC
folds <- createFolds(tr$Popular, k=5, returnTrain = T)
for (f in folds) {
    glm_mod <- glm(Popular~., data=tr[f,], family = binomial)
    predictions <- predict(glm_mod, newdata=tr[-f,], type="response")
    predROCR = prediction(predictions, tr[-f,"Popular"])
    print(performance(predROCR, "auc")@y.values[[1]])
}

# Train GLM via caret's "glmStepAIC"
glm_train <- train(
    Popular ~.,
    data=tr,
    method='glmStepAIC',
    trControl = trainControl(method = "cv"))

summary(glm_train$finalModel)
predict(glm_train$finalModel, type="response")


# Trained CV AUC
folds <- createFolds(tr$Popular, k=5, returnTrain = T)
predict(glm_train$finalModel, newdata=tr, type="response")
for (f in folds) {
    predictions <- predict(glm_train$finalModel, newdata=tr[-f,], type="response")
    predROCR = prediction(predictions, tr[-f,"Popular"])
    print(performance(predROCR, "auc")@y.values[[1]])
}


# Ensemble
preds_rf <- read.csv("/home/sergey/R_Analyttics_Edge_MITx/subFeatureSelectionSVMp0.csv")[,2]
preds_glm <- predict(glm_mod2, newdata=tr, type="response")
for (sh in seq(.1,.9,.1)) {
    cat("\n", "share of Random Forest is ", sh, "\n")
    auc = vector()
    for (i in 1:10) {
        f <- sample(1:nrow(test), size = nrow(test), replace = T)
        predictions <- sh*preds_rf[f] + (1-sh)*preds_glm[f]
        predROCR = prediction(predictions, tr[f,"Popular"])
        auc[i] = performance(predROCR, "auc")@y.values[[1]]
    }
    cat("Mean AUC is ", mean(auc))
}
