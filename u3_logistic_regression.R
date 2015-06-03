dat <- read.csv("./data/quality.csv")
head(dat)
dat$PoorCare <- as.factor(dat$PoorCare)
# as.factor(dat$PoorCare)
# palette(value = c("green", "red"))
# plot(x=dat$OfficeVisits,
#      y=dat$Narcotics,
#      pch=19,
#      col=as.factor(dat$PoorCare),
#      xlab="Number of office visits",
#      ylab="Number of drugs prescirbed")
# legend("topleft",
#        title="Quality of service",
#        c("good", "poor"),
#        pch=19,
#        col= c("green", "red"))

library(ggplot2)
ggplot(aes(x=OfficeVisits, y=Narcotics), data=dat) +
    geom_point(aes(col=PoorCare))

contrasts(dat$PoorCare)
tab <- table(dat$PoorCare)
tab
pt <- prop.table(tab)
addmargins(pt)

library(caTools)


library(caret)
set.seed(1)
train <- createDataPartition(dat$PoorCare, p=.75)[[1]]
train
length(dat$PoorCare)
length(train)
datTrain <- dat[train,]
prop.table(table(datTrain$PoorCare))
datTest <- dat[-train,]

quality <- glm(PoorCare ~ ., family=binomial, data=datTrain[, -4])
summary(quality)
predictions <- predict(quality, newdata = datTest, type = "response")
table(datTest$PoorCare, predictions>.6)
tapply(predictions, datTest$PoorCare, "mean")

# model selection
library(leaps)
library(bestglm)

