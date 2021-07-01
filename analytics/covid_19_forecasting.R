### Coronavirus Time Series Analysis ### -------------------------------------------------------

# By: Nicole Davila
# Date: 2020-03-21
# Data Source: Johns Hopkins Bloomberg School of Public Health (https://data.humdata.org/dataset/novel-coronavirus-2019-ncov-cases)

### Call libraries
library(data.table)
library(reshape2)
library(reshape)
library(quantmod)
library(forecast)
library(xts)

### Load data
dt <- data.table(read.csv("C:/Users/nicol/Downloads/time_series_2019-ncov-Confirmed.csv"))

### Select New York
dt <- dt[Province.State == "New York"]

### Arrange columns
setnames(dt, colnames(dt), gsub("X", "", colnames(dt)))
setnames(dt, colnames(dt), gsub("\\.", "-", colnames(dt)))

### Reshape data
dt <- dt[, c(1, 5:63)]
dtLong <- melt(dt, id = "Province-State")
dtLong <- dtLong[, date := as.Date(variable, format = "%m-%d-%y")]
dtLong <- dtLong[, c("date", "value")]        
setnames(dtLong, "value", "cases")
prevObs <- data.table(date = c(seq(as.Date("2020-01-01"), by = "day", length.out = 21)), cases = 0)
dtLong <- data.frame(rbindlist(list(prevObs,dtLong)))
rownames(dtLong) <- dtLong$date
dtLong$date <- NULL

### Correlation between number of cases and one-day lagged number of cases
acf(x = dtLong, plot = F)
cor(dtLong, use = 'complete.obs') # cor = 1

### Convert to time series data ('ts')
myts <- ts(dtLong, start = c(2020, 1), frequency = 365.25)

### Plot the data
plot(myts)

### Forecast for the following two months
fit <- ets(myts)
plot(forecast(fit, h = 61))

### If things remain as they are, in two months we're expected to have
forecast(fit, h = 61) # 190485 cases of infected people
