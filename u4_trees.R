dat <- read.csv("./W4/gerber.csv")
str(dat)
prop.table(table(dat$v))
library(dplyr)
sapply(dat[,4:8], function(x) {mn = mean(dat$voting[x ==1])})
str(dat)
f <- formula(voting ~ hawthorne + civicduty + neighbors + self)
mod_glm <- glm(f, data=dat, family=binomial)
summary(mod_glm)
predictions <- predict(mod_glm, type = "response")
prop.table(table(predictions >= .5, dat$voting))

library(ROCR)
PredictROC = prediction(predictions, dat$voting)
as.numeric(performance(PredictROC, "auc")@y.values)


CARTmodel <- rpart(f, data=dat)
prp(CARTmodel)

CARTmodel2 <- rpart(f, data=dat, cp=0.0)
prp(CARTmodel2)

CARTmodel3 <- rpart(voting ~ hawthorne + civicduty + neighbors + self + sex,
                    data=dat, cp=0.0)
prp(CARTmodel3)
sb1 <- subset(dat, control == 1)
prop.table(table(sb1$sex, sb1$voting))

sb1 <- subset(dat, civicduty == 1)
prop.table(table(sb1$sex, sb1$voting))

CARTmodel3 <- rpart(voting ~ control, data=dat, cp=0.0)
prp(CARTmodel3, digits = 6)
CARTmodel4 <- rpart(voting ~ control+sex, data=dat, cp=0.0)
prp(CARTmodel4, digits = 6)
CARTmodel5 <- rpart(voting ~ control+sex, data=dat, method="class", cp=0.0)
prp(CARTmodel5)

mod_glm <- glm(voting ~ control + sex, data=dat, family=binomial)
summary(mod_glm)

Possibilities = data.frame(sex=c(0,0,1,1),control=c(0,1,0,1))
predictionsGLM <- predict(mod_glm, newdata=Possibilities, type="response")
predictionsGLM

LogModel2 = glm(voting ~ sex + control + sex:control, data=dat, family="binomial")
summary(LogModel2)
predict(LogModel2, newdata=Possibilities, type="response")


letters <- read.csv("./W4/letters_ABPR.csv")
letters$isB = as.factor(letters$letter == "B")
library(caTools)
set.seed(1000)
split <- sample.split(letters$isB, SplitRatio=.5)
train <- letters[split,]
test <- letters[!split,]
str(train)
prop.table(table(train$isB))

CARTb <- rpart(isB ~ . - letter, data=train, method="class")
predictions <- predict(CARTb, newdata=test, type="class")
confusionMatrix(predictions, test$isB)

set.seed(1000)
rf_model <- randomForest(isB ~ . - letter, data=train)
predictions <- predict(rf_model, newdata=test, type="class")
confusionMatrix(predictions, test$isB)



letters$letter = as.factor( letters$letter )
set.seed(2000)
ind <- sample.split(letters$letter, .5)
train <- letters[ind,]
test <- letters[!ind,]
prop.table(table(train$letter))
mod_CART <- rpart(letter ~.- isB, data=letters, method="class")
predictions <- predict(mod_CART, test, type="class")
confusionMatrix(predictions, test$letter)


set.seed(1000)
mod_rf <- randomForest(letter ~.- isB, data=letters, method="class")
predictions <- predict(mod_rf, test, type="class")
confusionMatrix(predictions, test$letter)


census <- read.csv("./W4/census.csv")
str(census)
set.seed(2000)
ind <- sample.split(census$over50k, .6)
train <- census[ind,]
test <- census[!ind, ]
mod_glm <- glm(over50k~., data=train, family=binomial)
summary(mod_glm)
predictions <- predict(mod_glm, test, type = "response")
prop.table(table(as.numeric(predictions >.5), test$over50k))
prop.table(table(test$over50k))


PredictROC = prediction(predictions, test$over50k)
as.numeric(performance(PredictROC, "auc")@y.values)


mod_CART <- rpart(over50k~., data=train, method="class", cp=0.001)
prp(mod_CART)

predictions <- predict(mod_CART, test, type="class")
confusionMatrix(predictions, test$over50k)
head(predictions)


PredictROC = predict(mod_CART, newdata = test)
pred = prediction(PredictROC[,2], test$over50k)
perf = performance(pred, "tpr", "fpr")
plot(perf)

predictions <- predict(mod_CART, test)
PredictROC = prediction(predictions[,2], test$over50k)
as.numeric(performance(PredictROC, "auc")@y.values)


set.seed(1)
trainSmall = train[sample(nrow(train), 2000), ]
set.seed(1)
mod_rf <- randomForest(over50k ~., data=trainSmall, method="class")
predictions <- predict(mod_rf, test)
confusionMatrix(predictions, test$over50k)

vu = varUsed(mod_rf, count=TRUE)
vusorted = sort(vu, decreasing = FALSE, index.return = TRUE)
dotchart(vusorted$x, names(mod_rf$forest$xlevels[vusorted$ix]))
varImpPlot(mod_rf)

cartGrid = expand.grid( .cp = seq(0.002,0.1,0.002))
tr.control = trainControl(method = "cv", number = 10)
set.seed(2)
tr <- train(over50k ~.,
            data = train,
            method = "rpart",
            trControl = tr.control,
            tuneGrid = cp.grid)
ls(tr)

predictions <- predict(tr, test)
confusionMatrix(predictions, test$over50k)
prp(tr$finalModel)
ls(tr$finalModel)
nrow(tr$finalModel$splits)

