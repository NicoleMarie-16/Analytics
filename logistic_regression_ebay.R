### Logistic Regression ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(ggplot2)	
library(caret)	
library(dplyr)	
library(tidyr)
library(caTools)
library(ROCR)

### Import data
ebay = read.csv(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/ebay_data.csv"))

### Let's begin by taking a look at the structure of the data
str(ebay)

### Now, let's split the data into a train sample and a test sample using a seed of 196 such that 80% of the data is in the train
#   sample. Let's see how many observations are in the train sample.
set.seed(196)	
split = sample.split(ebay$sold, SplitRatio = 0.8)				
train = subset(ebay, split == TRUE)			
test = subset(ebay, split == FALSE)			
nrow(train)
# 1489

### What is the median startprice of iPads that got sold? 
median(train$startprice[train$sold == 1])				
# 99

### How about the ones that did not sell? 
median(train$startprice[train$sold == 0])
# 249.99

### Now, let us run a model to predict the variables that influence whether an iPad will be sold or not using a logistic regression
#   model using 'binomial' as the family since we have a boolean value as the target variable (i.e. 1 or 0). Then let's see the AIC.
model1 = glm(formula = sold ~ biddable + startprice + condition + cellular + carrier + color + storage + productline + noDescription + charCountDescription + upperCaseDescription + startprice_99end, family = "binomial", data = train)																							
summary(model1)	
# 1454.5
# If we examine the individual variables using a p-value of 0.10 we see that biddable, startprice, cellular, productline have a
# significant influence on whether or not an iPad is sold.

### Let's drop out non-signficant variables from model1 but keep variables that previous research or experience indicates should have
#   an effect. Let's generate a second model and take a look at the AIC. 
model2 = glm(formula = sold ~ biddable + startprice + condition + storage + productline + upperCaseDescription + startprice_99end, family = binomial, data = train)																
summary(model2)
# 1448.5

# After controlling for the effects of all other variables in the model, what sells better iPad3 or iPad 1?
sum(train$sold[train$productline == 'iPad 1']) / sum(train$productline == 'iPad 1', na.rm = T)										
# 0.5621622
sum(train$sold[train$productline == 'iPad 3']) / sum(train$productline == 'iPad 3', na.rm = T)											
# 0.519685
# iPad 3 seems to have a better chance of being sold

### Let's consider that the startprice goes up by $1. What would be the % reduction in the chance of selling an iPad? 
model3 = glm(sold ~ startprice, family = "binomial", data = train)	
summary(model3)	
100 * (exp(summary(model3)$coef[2])-1)			
# With a result of -0.720809, we could say that the percent reduction in the chance of selling an iPad when the startprice goes up
# by $1 is almost 1%.

### Based on model2 and, once again, controlling for the effects of all other variables, how much more or less likely is an iPad
#   Air 1/2 to sell compared to an iPad 1?
sum(train$sold[train$productline == 'iPad Air 1/2']) / sum(train$productline == 'iPad Air 1/2', na.rm = T)												
# 0.4327273, therefore an iPad Air 1/2 is 6.6 times (or 560%) more likely to sell than iPad 1						

### Let's run one more model called to predict the variable 'sold' using only 'productline'. Now let's take a look ad the sign of
#   the coefficient for iPad Air1/2 in this model. Is it the same as that in model2? 
model_productline = glm(sold ~ productline, family = "binomial", data = train)
summary(model2)$coef[12] 
# 1.887304	
summary(model_productline)$coef[5]				
# -0.5206743, so no, it is not

###Section 4###

### Let's make predictions on the test set using model2 and use it to find out what the probability of sale for an iPad with UniqueID
#   10940 is?
pred2 = predict(model2, newdata = test, type = 'response')					
pred2[test$UniqueID==10940]
# 0.02824507 

### What is the accuracy of model2 on the test set using a threshold of 0.5? 
table(as.numeric(pred2 > 0.5))		
ct = table(test$sold, pred2 > 0.5)			
ct
accuracy = sum(ct[1,1], ct[2,2])/nrow(test)				
accuracy
# 0.8064516

### Let's see if there is any incremental benefit from using model2 over the baseline. If we examine 'sold' in the train sample, it
#   would be easy to see that most iPads don't sell. If we didn't have any information on the independent variables we would predict
#   an iPad will not sell. The baseline, however is the percentage of times we would be correct in the test sample if we were to make
#   this assumption.
t = table(train$sold)		
baseline = max(t[1],t[2])/nrow(train)	
baseline
# 0.5379449, which indicates that model2 is performing better than the baseline

### Since the accuracy measure depends on the cut-value (or threshold) used, we could use a more popular measure, which is the area
#   under the curve (or AUC). This can be computed by finding the area under the curve of a plot of Senstivity vs. 1-Specificity. The
#   AUC is a model performance measure that is independent of any particular threshold.
pred = predict(model2, newdata = test, type = 'response')
ROCRpred = prediction(pred,test$sold)
as.numeric(performance(ROCRpred,"auc")@y.values)
# AUC = 0.868968
ROCRperf = performance(ROCRpred,"tpr","fpr")
plot(ROCRperf,colorize=TRUE,print.cutoffs.at=seq(0,1,0.2),text.adj=c(-0.3,2),xlab="1 - Specificity",ylab="Sensitivity")