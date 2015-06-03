# Example 1
# Regression with Random forests from ISLR Ch.8

library(MASS)
library(randomForest)
library(caret)
str(Boston)
ind <- createDataPartition(Boston$medv, p=.7, list=F)
train <- Boston[ind,]
test <- Boston[-ind,]
mod_rf <- randomForest(medv~., data=train, importance=T)
mod_rf # model performance summary
RMSE(mod_rf$pred, train$medv) # more meaningful metric

# we can cross-validate model on
#
# -- mtry - # of variables randomly chosen at each split
#           default is sqrt(p) for classification
#                      p/3 for regression
#
# -- ntree - # of trees tried, default is 500
#            recommended: no more than 5000

train_rf <- train(medv~.,
                  method="rf",
                  data=train,
                  importance=T,
                  tuneLength=5,
                  ntrees=1000,
                  trControl= trainControl(method="cv"))
plot(train_rf)

train_rf2 <- train(medv~.,
                  data=train,
                  method="rf",
                  importance=T,
                  tuneLength=5,
                  ntrees=5000,
                  trControl= trainControl(method="cv"))
plot(train_rf2)

RMSE(predict(train_rf, test), test$medv)
RMSE(predict(train_rf2, test), test$medv)

# comparison to boosted trees in gbm
train_gbm <- train(medv~.,
                   data=train,
                   method="gbm",
                   trControl=trainControl(method="cv"))
train_gbm

modelLookup("gbm")
getModelInfo("gbm")
getModelInfo("gbm", regex = FALSE)[[1]]$parameters$parameter

grid <- expand.grid(n.trees = seq(50,200, 50),
                    interaction.depth = 1:5,
                    shrinkage=seq(0.01, 0.2, 0.01))

train_gbm <- train(medv~.,
                   data=train,
                   method="gbm",
                   tuneGrid=grid,
                   verbose=F,
                   trControl=trainControl(method="cv"))
plot(train_gbm)
RMSE(predict(train_gbm, test), test$medv)
