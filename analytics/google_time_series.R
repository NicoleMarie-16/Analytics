#######################################################
### Time Series Analysis on Google Stock Price Data ###
#######################################################

# By: Nicole Davila
# Date: 2019-08-05

### Install and load required packages
install.packages("quantmod")
install.packages("forecast")
library(quantmod)
library(forecast)


### Part I: Do some data exploration
# Read file
goog <- readRDS("C:/Users/nicol/Desktop/goog.RDS")

# What type of data structure is goog?
class(goog)

# Evaluate the records
goog[1]
# Data is indexed in months and years so we need to multiply by the number of months and years after
# that date and add the month number for any record we want to identify.

# How many months of data are included in this dataset?
dim(goog)

# What was Google's stock price for June, 2010?
goog[12*3+6]

# Using the monthly stock price for Google, what is the average stock price for the year 2010?
mean(goog[37:48,])


### Part II: Time Series Analysis
# What is the correlation between google stock price and one-month lagged stock price?
acf(x = goog,plot=F)
cor(goog, use='complete.obs')

# Convert the data to 'ts' data type.
google = ts(goog,start=c(2007,01),frequency=12)
# Split the data into a train and test sample, using the train sample to estimate a model and the
# test sample to evaluate it. Use data from Jan, 2007 to Dec, 2015 for the train sample and the
# rest for the test sample. How many rows do we have for the train sample?
train = window(google,start=c(2007,01),end=c(2015,12))
test = window(google,start=c(2016,01),end=c(2018,10))
nrow(train)

# Construct a plot of autocorrelations for train using. Which lag has the strongest autocorrelation?
ggAcf(goog)

# Use the average to make a prediction for the stock price over the 34 months of the test sample.
# What is the point forecast of the stock price for October 2018?
average_model = meanf(train,h = 34)
average_model

# Examine the accuracy of the prediction from on the train sample. hat is the RMSE of the prediction
# in the train sample? 
accuracy(average_model)

# What is the RMSE of the average_model on the test sample?
accuracy(average_model,x = google)

# Examine another prediction, which assumes the future will be the same as the last observation.
# Use this model to construct a forecast for stock price over the next 34 months of the test sample.
# What is the point forecast of the stock price for October 2018?
naive_model = naive(train,h=34)
naive_model

# What is the RMSE of the naive_model on the test sample?
accuracy(naive_model,x=google)

# Fit an exponential smoothing model and find its errors (additive)
ets_model = ets(train,model = 'AAA')
ets_model

# What is the trend for the model?
summary(ets_model)
# Additive

# What is AICc for ets_model?
summary(ets_model)

# See if the residuals look like white noise. 
checkresiduals(ets_model)
# Not white noise

# Use ets_model to construct a forecast for stock price over the next 34 months of the test
# sample. What is the point forecast of the stock price for October 2018?
ets_model_forecast = forecast(ets_model,h=34)
ets_model_forecast

# What is the RMSE of the ets_model on the test sample?
accuracy(ets_model_forecast,x=google)

# Build an ARIMA model using auto.arima() to automatically determine the best parameters.
# How many ordinary autoregressive lag variables have been used?
auto_arima_model = auto.arima(train,stepwise = F,approximation = F)
auto_arima_model
# Zero

# What is the number of ordinary differences used in auto_arima_model?
# One

# How many ordinary moving average lags have been used in auto_arima_model?
# Zero

# How many seasonal autoregressive lag variables have been used in auto_arima_model?
# Two

# Do the residuals look like white noise? 
checkresiduals(auto_arima_model)
# Yes, they do

# Use auto_arima_model to construct a forecast for stock price over the next 34 months
# of the test sample. What is the point forecast of the stock price for October 2018?
auto_arima_model_forecast = forecast(auto_arima_model,h=34)
auto_arima_model_forecast

# What is the RMSE of auto_arima_model on the test sample?
accuracy(auto_arima_model_forecast,x=google)


# Improve the ARIMA model by a variance stabilizing transformation. What is the optimal value of lambda?
BoxCox.lambda(train)

# Specify an ARIMA model as instead of using auto.arima(). What is the AICc for arima_model?
arima_model = Arima(train,order = c(1,1,1),seasonal = c(3,1,0),lambda=BoxCox.lambda(train))
arima_model

# Examine the results of Ljung-Box test to see if the residuals resemble white noise.
checkresiduals(arima_model)
# Residuals resemble white noise

# Use arima_model to construct a forecast for stock price over the next 34 months of the
# test sample. What is the point forecast of the stock price for October 2018?
arima_model_forecast = forecast(arima_model,h=34)
arima_model_forecast

# What is the RMSE of arima_model on the test sample?
accuracy(arima_model_forecast,x=google)