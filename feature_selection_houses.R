### Feature Selection ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(tidyr)	
library(dplyr)	
library(caret)	
library(ggplot2)
library(corrplot)
library(car)
library(leaps)
library(glmnet)

### Import data
houses = read.csv(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/houses.csv"))

### First, let's start by splitting the data into a train and test sample such that 70% of the data is in the train sample, using 
#   groups of 100 and setting the seed to 1031. What is the average house price in the train sample? 
set.seed(1031)
split = createDataPartition(y = houses$price, p = 0.7, list = F, groups = 100)
train = houses[split, ]
test = houses[-split, ]
mean(train$price)
# 540674.2

### Now, let's examine bivariate correlations with price to identify variables that are weakly related to (or not relevant) for
#   predicting price. 
cor(select_if(train, is.numeric))
model1 = lm(price ~ ., train)
summary(model1)
# We see that sqft_above and yr_renovated have a very weark relationship with price

### Let's examine correlations amongst the predictors to identify which pair has the highest bivariate correlation.
corrplot(cor(train[,c(3:7, 10:13,16)]),method = 'square',type = 'lower',diag = F)
cor(train[,c(3:7, 10:13,16)])
# sqft_living and sqft_above appear to be the two variables with the highest bivariate correlations. 

### It could be considered that the area of a house (sqft_living) is the sum of area above the basement (sqft_above) and the basement
#   (sqft_basement). We could verify this by computing the correlation between sqft_living and the sum of sqft_above and sqft_basement.
#   This is important to note because multicollinearity can arise not only from associations between a pair of predictors but also
#   between a linear combination of predictors. 
cor(train$sqft_living, (train$sqft_above + train$sqft_basement))
# We see that the correlationis equal to 1, indicating our assumption is correct.

### It is evident from the above that the threat of collinearity can also come from linear relationships between sets of variables.
#   Let's compute the Variance Inflating Factor (VIF) to assess the threat of multicollinearity in another model.
model2 = lm(price ~ bedrooms + bathrooms + sqft_living + sqft_lot + floors + waterfront + view + condition + grade + age, train)
vif(model2)
# sqft_living has the highest VIF with a value of 4.183860 

### Let's examine some algorithm driven ways to select features as predictors for price and evaluate all possible subsets to identify
#   the best-six predictor model. If we were to run a six-predictor model, which variables should we include?
subsets = regsubsets(price~bedrooms+ bathrooms + sqft_living + sqft_lot + floors + waterfront + view + condition + grade + age,data=train, nvmax=10)
summary(subsets)
# bedrooms, sqft_living, waterfront, view, grade, age		

### What would be the R2 for the best six-predictor model?
best_6=lm(price~bedrooms+sqft_living+waterfront+view+grade+age,train)
summary(best_6)
# 0.6441

### Next, let's run a forward stepwise regression model and identify the variables in te best model.
start_mod = lm(price ~ 1, data=train)
empty_mod = lm(price ~ 1, data=train)
full_mod = lm(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age,data=train)
forwardStepwise = step(start_mod,
                       scope=list(upper=full_mod,
                                  lower=empty_mod),
                       direction='forward')
summary(forwardStepwise)
# We see that all viariables were included in the best model.

### Now, let's run a backward stepwise regression model and identify the variables in te best model.
start_mod = lm(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age,data=train)
empty_mod = lm(price~1,data=train)
full_mod = lm(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age,data=train)
backwardStepwise = step(start_mod,
                        scope=list(upper=full_mod,
                                   lower=empty_mod),
                        direction='backward')

summary(backwardStepwise)
# Once again, all variables were selected.

### Let's run a hybrid stepwise regression model, where both forward and backward algorithms operate simultaneously and identify
#   the variables in te best model. 
start_mod = lm(price~1,data=train)
empty_mod = lm(price~1,data=train)
full_mod = lm(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age,data=train)
hybridStepwise = step(start_mod,
                      scope=list(upper=full_mod,
                                 lower=empty_mod),
                      direction='both')
summary(hybridStepwise)
# We get the same results as with forward and backwards.

### Now, let's use a Lasso model to select features and identify which variables are included in the best model.
x = model.matrix(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age, data=train)
y = train$price
cv.lasso = cv.glmnet(x,y,alpha=1) 
plot(cv.lasso)
coef(cv.lasso)
# We see that bathrooms, sqft_living, waterfront, view, grade, and age are included, which resembles our results when we used
# regsubsets.

### What is the R2 for the model selected by lasso?
model_lasso=lm(price ~ bathrooms + sqft_living + waterfront + view + grade + age, train)
summary(model_lasso)
# 0.6435 which is similar to our best_6 model

### Let's move on to dimension reduction. Now, rather than selecting individual variables, we will capture the essence in a few
#   components so as to retain at least 90% of the information.
trainPredictors = train[,c(3:11,16)]
testPredictors = test[,c(3:11,16)]
x = preProcess(x = trainPredictors,method = 'pca',thresh = 0.9)
trainComponents = predict(x,newdata=trainPredictors)
trainComponents$price = train$price
str(trainComponents)
# We see that we ended up using 7 components to capture the information in the predictors.

### Using only these components to predict price in the train sample. What is the R2?
train_model = lm(price ~ ., trainComponents)
summary(train_model)		
# 0.5483, which is not as good as with the 6 predictors

### Let's impose the trained component structure on the test sample.
testComponents = predict(x,newdata=testPredictors)
testComponents$price = test$price
# Now, let's apply the train model created with the components to the test-component dataset we just created. 
pred_comp = predict(train_model, newdata = testComponents)
# And finally, let's compute R2 on the test set.
sse_comp = sum((pred_comp - testComponents$price)^2)	
sst_comp = sum((mean(testComponents$price)-testComponents$price)^2)			
train_model_r2 = 1 - sse_comp/sst_comp
train_model_r2
# 0.5589984, just slightly higher than on the train data