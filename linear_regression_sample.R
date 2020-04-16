### Linear Regression ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(caret)
library(dplyr)
library(tidyr)
library(data.table)
library(lm.beta)

### Import data
houses = read.csv(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/houses.csv"))

### Let's the data into a train and test sample such that 70% of the data is in the train sample and partition with groups of 100.
# Set seed
set.seed(1031)
# Split data
split=createDataPartition(y=houses$price,p=0.7,list=F,groups=100)
train=houses[split,]
test=houses[-split,]
# Check average house price in each sample
mean(train$price)
# 540674.2
mean(test$price)
# 538707.6

### Let's do some data exploration on the train sample to better understand the structure and nature of the data and to spot unusual
#   values.
train %>%
  select(id,price:sqft_lot,age)%>%
  gather(key=numericVariable,value=value,price:age)%>%
  ggplot(aes(x='',y=value))+
  geom_boxplot(outlier.color = 'red')+
  facet_wrap(~numericVariable,scales='free_y')
# We can see that there are outliers for bathrooms, bedrooms, price, sqft_living, and sqft_lot. Let's inspect bedrooms outliers. 

### Let's see what the living area (sqft_living) for the house with the most bedrooms is.
data.table(train)[bedrooms==max(bedrooms),"sqft_living"]
# 1620

### It is expected that larger houses cost more, but let's onstruct a scatterplot to examine the relationship between sqft_living
#   and price, placing sqft_living on the horizontal axis and price on the vertical axis. This will allow us to confirm or reject
#   this hypothesis.
ggplot(data=houses,aes(x=sqft_living, y=price))+
  geom_point()
# We see the dots going ottom-left to top-right confirming our hypothesis.

### Now let's take a look at the correlation between sqft_living and price? 
cor(houses$sqft_living,houses$price)
# A correlation of 0.7020351, which is relatively close to 1, indicates there is in fact a positive relationship between these two
# variables. This aligns with wht we saw in the scatterplot.

### Now, let's construct a simple regression to predict house price from area (sqft_living) using the training set we created earlier
#   and examine how well the model is predicting price by calculating the p-value for the F-statistic.
model1 = lm(price ~ sqft_living, data=train)
summary(model1)
# Since we get a p-value of < 2.2e-16, we can say with a good degree of confidence that our model is performing well.

### Let's calculate the R2 for model1
pred1 = predict(model1)
sse1 = sum((pred1 - train$price)^2)
sst1 = sum((mean(train$price)-train$price)^2)
model1_r2 = 1 - sse1/sst1; model1_r2
# Since we got an R2 of 0.4985522, we can say that our model expalins about 50% of the variablity of the response data around its
# mean. Our model does not fit the data too well.

### Let's see what the rmse for model1 is, since this is an absolute measure of fir, whereas R2 is a relative measure of fit.
rmse1 = sqrt(mean((pred1-train$price)^2))
rmse1
# 263932.6
# Note: RMSE can be better interpreted in relation to other models using the same data. Below we will construct another model and
#       we will be able to better interpret this measure.

### Since this model is built on sample data, it is important to see if the coefficient estimates are non-zero in the population.
summary(model1)
# Based on the model results, indicate your agreement with the following statement we see that the coefficient of sqft_living is
# significantly different from zero.

### Based on this model, on average, what would a 1400 square foot house cost?
predict(model1, newdata = data.frame(sqft_living = 1400))
# 346581

### Let's imagine a homeowner were to put in a 200 square foot addition on the house. How much would the price be expected to go
#   up by?
predict(model1, newdata = data.frame(sqft_living = 200)) - predict(model1, newdata = data.frame(sqft_living = 0))
# 56980.49

### Let's construct another simple regression to predict house price from waterfront. Once again, let's use the training set we
#   created earlier. Waterfront is a boolean where 1 indicates the house has a view to the waterfront and 0 that it does not.
model2 = lm(price~waterfront, data = train)				
pred2 = predict(model2)		
sse2 = sum((pred2 - train$price)^2)			
sst2 = sum((mean(train$price)-train$price)^2)					
model2_r2 = 1 - sse2/sst2; model2_r2			
# We get an R2 of 0.07406626 indicating that a waterfront does not really influence the price of a house. 

### Let's take a look at the impact of a waterfront view on the expected price. That is, how much more is the expected price of a
#   house with a waterfront view compared to one without a waterfront view?
predict(model2, newdata = data.frame(waterfront = 1))- predict(model2, newdata = data.frame(waterfront = 0))
# 1179766

### We had previously calculated the RMSe for model1. Now let's compare it to the RMSE for model2.
rmse1
rmse2 = sqrt(mean((pred2 - train$price)^2))
rmse2
# We see that model1 has an RMSE of 263932.6 which is lower than the RMSE for model2 (358649.4), indicating that model1 is better.
# Therefore, we could say that the area of a house is a better predictor than a house having a waterfront view.

### Let's use both the predictors from model1 and model2 to predict price and compare the R2 against that of the previous models.
model3 = lm(price~waterfront+sqft_living, data = train)				
pred3 = predict(model3)		
sse3 = sum((pred3 - train$price)^2)			
sst3 = sum((mean(train$price)-train$price)^2)					
model3_r2 = 1 - sse3/sst3
model3_r2
model2_r2
model1_r2
rmse3 = sqrt(mean((pred3 - train$price)^2))
rmse3
# We see that model3 has an R2 of 0.5375464, which is higher than model1 and model2, indicating better fit. Furthermore, the lower
# RMSE of model3 (253462.8) is indicative of a better model.

### Now, let's take a look at the impact of a waterfront view on the expected price holding area constant.
coef(model3)[2]	
# The expected price would be 861002.3631

### Let's run a multiple regression model on the training set and add some more variables.
#Call this model4. What is the R2 for model4?
model4 = lm(price~bedrooms + bathrooms+ sqft_living + sqft_lot + floors + waterfront + view + condition + grade + age, data = train)				
pred4 = predict(model4)		
sse4 = sum((pred4 - train$price)^2)			
sst4 = sum((mean(train$price)-train$price)^2)					
model4_r2 = 1 - sse4/sst4
model4_r2
rmse4 = sqrt(mean((pred4 - train$price)^2))
rmse4
# With a higher R2 (0.6512827) and a lower RMSE (220098.4), model4 is an even better model.

### Let's see which of the predictors used have an influence on price?
summary(model4)
# All of the predictors have a significant influence on price.

### Let's day a person decides to add another bathroom. What would be the increase in expected price, holding all other predictors
#   constant?
coef(model4)[3]
# 50744.76

### Now, out of all the predictors in model4, which exerts the strongest influence on price?
lm.beta(model4)	
# Since sqft_living has the highest beta coefficient, we can say tht it is the strongest predictor of price.

### Finally, let's apply this model to test data and calculate what the R2 and RMSE are.
model4 = lm(price~bedrooms+bathrooms+sqft_living+sqft_lot+floors+waterfront+view+condition+grade+age, data = train)			
pred4test = predict(model4, newdata = test)
sse4test = sum((pred4test - test$price)^2)	
sst4test = sum((mean(test$price)-test$price)^2)			
model4test_r2 = 1 - sse4test/sst4test
model4test_r2
rmse4test = sqrt(mean((pred4test - test$price)^2))
rmse4test
# The R2 is slightl higher than in the train sample, with a value of 0.6544801, indicating the model performed well on the test data.
# Similarly, in terms of the RMSE it was slightly lower than the train data, with a value of 207835.2. This is also a good indication
# that our model performed well in the test data.