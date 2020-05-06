### Advanced Trees ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(ISLR)
library(caTools)
library(rpart)
library(rpart.plot)
library(ROCR)
library(caret)
library(randomForest)
library(gbm)

### Import Data
head(OJ)
OJ=OJ

### Split the data into a train and test sample such that 70% of the data is in the train sample
set.seed(1234)
split=sample.split(Y=OJ$Purchase,SplitRatio=0.7)
train=OJ[split,]
test=OJ[!split,]

### Let's take a look at how many observations we have on our train sample
nrow(train)
# 749

### How many Minute Maid purchases were made in the trian sample?
sum(train$Purchase=="MM")
# 292

### Let's take a lok at the average price for Minute Maid in the train sample.
mean(train$PriceMM)
# 2.087223

### How about the average discount?
mean(train$DiscMM)
# 0.1237116

### How many purchases of Minute Maid were made in Week 275?
nrow(train[which(train$Purchase=="MM" & train$WeekofPurchase==275),])
# 17

### Let's construct a classification tree to predict "Purchase"
tree1=rpart(Purchase~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,method="class")
# Do predictions
pred1=predict(tree1,newdata=test)
ROCRpred1=prediction(pred1[,2],test$Purchase)
# Calculate AUC
as.numeric(performance(ROCRpred1,"auc")@y.values)
# 0.8628776

### Let's tune the model using a 10-fold cross-validation and test cp values ranging from 0 to 0.1 in steps of 0.001.
trControl=trainControl(method="cv", number=10)
tuneGrid = expand.grid(.cp = seq(0,0.1,0.001))
set.seed(100)
cvModel=train(Purchase~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,
              method="rpart",trControl=trControl,tuneGrid=tuneGrid)
cvModel$bestTune
# We see that the optimal cp is of 0.004

### Rerun the tree model but using the optimal cp value. What is the auc for this model on the test sample?
treeCV=rpart(Purchase~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,
             control=rpart.control(cp=cvModel$bestTune))
predTreeCV=predict(treeCV,newdata=test)
ROCRpredTreeCV=prediction(predTreeCV[,2],test$Purchase)
as.numeric(performance(ROCRpredTreeCV,"auc")@y.values)
# 0.8628776, same as above

### Let's construct a bag model, using 1000 trees.
set.seed(100)
bag=randomForest(Purchase~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,
                 mtry=10,ntree=1000)
# In order to get the AUC, we'll need to get the prediction probability for each prediction. To achieve this, use argument type = "prob"
# and the second column of the output in the predict function. 
predBag=predict(bag,newdata=test,type="prob")
ROCRpredBag=prediction(predBag[,2],test$Purchase)
as.numeric(performance(ROCRpredBag,"auc")@y.values)
# We get an AUC of 0.867102 on the test sample

### Now, let's construct a random forest model, using 1000 trees, but using the default instead of establishing an mtry. As we did above
#   for the bag model, use argument type = "prob" for the predict function and use the second column of the output.
set.seed(100)
forest=randomForest(Purchase~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,ntree=1000)
# Determine the AUC for the test sample 
predForest=predict(forest,newdata=test,type="prob")
ROCRpredForest=prediction(predForest[,2],test$Purchase)
as.numeric(performance(ROCRpredForest,"auc")@y.values)
# 0.8812449

### In this dataset, the levels of variable Purchase are 1 and 2. However, in order to run a boosting model for a two-level classification
#   model, the dependent variable will need to have values of 0 and 1. Let's modify the variable and create a new one called Purchase2.
train$Purchase2 = as.numeric(train$Purchase)-1
test$Purchase2 = as.numeric(test$Purchase)-1

### Let's run a gradient boosting model (gbm) with 1000 trees using Purchase2 instead of Purchase and using the same independent variables
#   used in above models. Let's set distribution to "bernoulli", interaction depth to 1, and shrinkage parameter to 0.04. Let's also set
#   argument type = "response" the predict function and n.trees = 100. 
set.seed(100)
boost=gbm(Purchase2~PriceCH+PriceMM+DiscCH+DiscMM+SpecialCH+SpecialMM+LoyalCH+PriceDiff+PctDiscMM+PctDiscCH,data=train,distribution="bernoulli",n.trees=1000,interaction.depth=1,shrinkage=0.04)
predBoost=predict(boost,newdata=test,n.trees=100,type="response")
ROCRpredBoost=prediction(predBoost,test$Purchase2)
# Determine the AUC for the test sample
as.numeric(performance(ROCRpredBoost,"auc")@y.values)
# 0.879551