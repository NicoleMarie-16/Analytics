######################################## AAFM II WHISKY REVIEW PREDICTION PROJECT ############################################## 

### File Date: 2019-08-12

### Collaborators:
# Nicole Davila
# Peter Kim
# Ramaswamy Subramanian
# Matthew Lee

######################################## LOAD LIBRARIES AND IMPORT DATA #########################################################

#Clear console to start fresh
rm(list=ls())

library(tidyverse)
library(dplyr)
library(stringr)
library(readxl)
library(tidytext)
library(tm)
library(ggplot2)
library(ggthemes)
library(rpart)
library(rpart.plot)
library(party)
library(glmnet)
library(gbm)
library(caret)
library(randomForest)
library(rJava)
library(qdap)
library(lexicon)

#Import whisky data
whisky <- read_excel("Desktop/whisky_dataset_v1.4.xlsx")
View(whisky)

#Inspect structure of whisky data
str(whisky) #2247 observations of 9 variables

############################################ CLEANSING OF DATASET ##############################################################

#Remove the "currency" column- all values in that column are "$" so the column seems unnecessary to keep
whisky <- whisky[-c(8)] #"Currency" column is the eighth column in the original dataset

#Rename dataset columns
colnames(whisky)[1] = "id"
colnames(whisky)[6] = "review_point"

#Convert dataset into dataframe and convert "age", price", and "review_point" columns into numeric class
whisky <- as.data.frame(whisky) #Convert uploaded dataset into data frame
whisky %>% mutate_if(is.factor, as.character) -> whisky #The data frame conversion process turns all the character variables into factor variables, so we have to address this by changing them back
whisky$age <- as.numeric(whisky$age) #Convert age to numeric class
whisky$review_point <- as.numeric(whisky$review_point) #Convert review_point to numeric class
whisky$price <- as.numeric(as.character(whisky$price)) #Convert price to numeric class

#Count NAs for "age" column and replace any present 
sum(is.na(whisky$age)) #667 NAs are present
median_whisky_age = median(whisky$age, na.rm = T) #21 years is the median age
mask_NAs_whisky_age = is.na(whisky$age) #Let's replace with median age (21 years) rather than mean as mean age (23.76 years) seems like an un-standard bottling age 
whisky[mask_NAs_whisky_age, 'age'] = median_whisky_age
sum(is.na(whisky$age)) #Check for no NAs- should read as 0

#Fix the six pricing NAs through manual imputation since there's only 6 NAs; use pricing source: https://scotchwhisky.com/magazine/latest-news/16546/balvenie-dcs-compendium-chapter-3-unveiled/ and a currency conversion rate of 1 GBP to 1.27 USD
whisky[20, 7] = 19047 #Balvenie 1973 43 year old, 46.6%
whisky[96, 7] = 44444 #Balvenie 1961 55 year old, 41.7%
whisky[411, 7] = 4444 #Balvenie 1981 35 year old, 43.8%
whisky[577, 7] = 44 #Johnnie Walker Blenders??? Batch Sherry Cask Finish 12 year old, 40%
whisky[1001, 7] = 1143 #Balvenie 1993 23 year old, 51.9%
whisky[1216, 7] = 762 #Balvenie 2004 13 year old, 58.2%

#Count NAs for "review_point" column and replace any present 
sum(is.na(whisky$review_point)) #Check for no NAs- should read as 0

################################### FEATURE ENGINEERING ######################################################

#Feature engineering #1: extract ABV% from "name" column
ABV <- str_extract_all(whisky$name, "\\d+(\\.\\d+){0,1}%") #Create ABV variable with extracted percentages
ABV = data.frame(word(whisky$name, -1)) #Add new column for ABV
whisky$ABV = word(whisky$name, -1)
whisky$ABV = as.numeric(gsub("[\\%,]", "", whisky$ABV)) #Remove "%" from ABV column
view(whisky) #Check appearance of new column and examine extraction for any wild outliers
whisky[988, 9] = 46 #Replace ABV value (1998%, which is clearly wrong) of "Ardmore Traditional Cask 1998" with the correct value of 46%

#Feature engineering #1.1: Cleanse NAs for ABV column- this time let's use median since manual imputation will be too much work
sum(is.na(whisky$ABV)) #45 NAs present 
median_whisky_ABV = median(whisky$ABV, na.rm = T) #46% is the median ABV %
mask_NAs_whisky_ABV = is.na(whisky$ABV) #Let's replace with median price ($110) rather than mean as mean price ($531) seems very high 
whisky[mask_NAs_whisky_ABV, 'ABV'] = median_whisky_ABV
sum(is.na(whisky$ABV)) #Check that all NAs have been removed- should read as 0

#Feature engineering #2: add column "nchar_description" for character count of the "description" column
nchar_description <- nchar(whisky$description, type = "chars") #Count the number of characters in the "description" column with nchar()
whisky <- data.frame(whisky, nchar_description = nchar_description) #Add the new column to the existing data frame
whisky$nchar_description <- as.numeric(whisky$nchar_description) #Convert class of nchar_description from integer into numeric
sum(is.na(whisky$nchar_description)) #Check for NAs- result is 0 NAs, which is good
view(whisky) #Check appearance of new column

#Feature engineering #3: add column "sentence_count" for sentence count of the "description" column, using periods as a proxy for sentences
sentence_count <- str_count(whisky$description, "\\.") #Count the number of periods in the "description" column with str
whisky <- data.frame(whisky, sentence_count = sentence_count) #Add the new column to the existing data frame
whisky$sentence_count <- as.numeric(whisky$sentence_count) #Convert class of nchar_description from integer into numeric
sum(is.na(whisky$sentence_count)) #Check for NAs- result is 0 NAs, which is good
view(whisky) #Check appearance of new column

#Feature engineering #4: add a new column review_category to categorize the review points by supplementing the data set with data from Whisky advocate website. Use the Whisky review source website for categories: http://whiskyadvocate.com/ratings-and-reviews/
whisky$rating_category[(whisky$review_point > 94) & (whisky$review_point < 101)] = "Classic"
whisky$rating_category[(whisky$review_point > 89) & (whisky$review_point < 95)] = "Outstanding"
whisky$rating_category[(whisky$review_point > 84) & (whisky$review_point < 90)] = "Very good"
whisky$rating_category[(whisky$review_point > 79) & (whisky$review_point < 85)] = "Good"
whisky$rating_category[(whisky$review_point > 74) & (whisky$review_point < 80)] = "Mediocre"
whisky$rating_category[(whisky$review_point < 75)] = "Not recommended"
view(whisky) #Check appearance of new column

#Feature engineering #5: use sentiment analysis to create a polarity variable
#Determine the polarity of each review. Here each word present in a review is given a polarity. The 
#mean polarity was calculated by review id and turned into a data frame. There are 4 reviews for which 
#no polarity was calculatd. We will replace them with the average polarity.

## 07/25 Ram: The results of the code below are yet to be verified following the code change related to merging the record IDs with whisky_data
head(hash_sentiment_nrc)
polarity = as.data.frame(whisky %>%
                           select(id, description)%>%
                           group_by(id)%>%
                           unnest_tokens(output = word, input = description)%>%
                           inner_join(y = hash_sentiment_nrc,by = c('word'='x'))%>%
                           ungroup()%>%
                           group_by(id)%>%
                           summarize(polarity = mean(y))%>%
                           ungroup())

#Insert missing ids to polarity data frame. These were eliminted during the inner join.
polarity_miss_rows = data.frame(id = c(1305, 1448, 1690, 1866), polarity = c(NA, NA, NA, NA))
new_polarity = data.frame(rbind(polarity, polarity_miss_rows))

#Replace NAs with mean polarity.
mean_whisky_age = mean(new_polarity$polarity, na.rm = T)
mask_NAs_polarity = is.na(new_polarity$polarity) 
new_polarity[mask_NAs_polarity, 'polarity'] = mean_whisky_age

#Add polarity column to whisky data
whisky = cbind(polarity = new_polarity$polarity,whisky)

#Feature engineering #6: let's use sentiment analysis to see what words are the most significant predictors of review ratings

#Create corpus
corpus = Corpus(VectorSource(whisky$description)) #Define corpus to clean
corpus = tm_map(corpus,FUN = content_transformer(tolower)) #Convert to lowercase
corpus = tm_map(corpus,FUN = removePunctuation) #Remove punctuation 
corpus = tm_map(corpus,FUN = removeWords,c(stopwords('english'))) #Remove stop words
corpus = tm_map(corpus,FUN = stripWhitespace) #Remove white space

#Create dictionary
dict = findFreqTerms(DocumentTermMatrix(Corpus(VectorSource(whisky$description))),lowfreq = 0)
dict_corpus = Corpus(VectorSource(dict))

#Stem document
corpus = tm_map(corpus,FUN = stemDocument)

#Create document term matrix
dtm = DocumentTermMatrix(corpus)
dtm

#Remove sparse terms (threshold = 10%)
xdtm = removeSparseTerms(dtm,sparse = 0.90) 
xdtm

#Complete stems
xdtm = as.data.frame(as.matrix(xdtm))
colnames(xdtm) = stemCompletion(x = colnames(xdtm),dictionary = dict_corpus,type='prevalent')
colnames(xdtm) = make.names(colnames(xdtm))

#Browse tokens and sort from highest to lowest count
sort(colSums(xdtm),decreasing = T)

#Create new dataframe by combining record id and review_point with xdtm
whisky_data = cbind(review_rating = whisky$review_point,xdtm)
View(whisky_data)

#Split into train and test sets
set.seed(1234)
split = sample(1:nrow(whisky_data),size = 0.7*nrow(whisky_data))
train = whisky_data[split,]
test = whisky_data[-split,]

#Create regression model excluding the record_id attribute
reg = lm(review_rating~.,train)
summary(reg)

#Conduct feature reduction on regression model 
x = model.matrix(review_rating~.,data=train)
y = train$review_rating
lassoModel = glmnet(x,y, alpha=1)
lassoModel
cv.lasso = cv.glmnet(x,y,alpha=1)
coef(cv.lasso) #See what are the 10 words with the largest coefficients (in order from largest to smallest: complex, long, rich, cinnamon, smoke, dark, oak, chocolate, release, and pepper)

#Create 10 columns calculating the frequency of each key word and append to the greater dataset
#INSERT NICOLE'S FREQUENCY COUNT AND BINDING CODE HERE

######################################## CONDUCT REMAINING EXPLORATORY ANALYSIS ###########################################################

#Conduct initial exploratory analysis of whisky data
mean(na.omit(whisky$price)) #531.03- this seems pretty high!
median(na.omit(whisky$price)) #110- quite a big difference from the mean price, which is likely skewed by high-price outliers
mean(whisky$review_point) #86.7
median(whisky$review_point) #87

#Create histogram of review points
ggplot(data=whisky,aes(x=review_point))+geom_histogram(bins=35)+xlab("Review Point") + ylab("Count") + ggtitle("Histogram of Whisky Review Points") + theme_economist() + theme(plot.title = element_text(hjust = 0.5)) 
#Seems like review points are clustered around the mid to high eighties range (on a 0-100 scale)

#Examine the relationship between rating category (X-axis) and median price (Y-axis)
#We're using median rather than mean price as there are multiple outliers within price (e.g. some whiskies are in the five-figure price-range)
ggplot(data=whisky,aes(x=rating_category,y=price))+geom_bar(stat = 'summary',fun.y='median')+scale_x_discrete(limits = positions) + xlab("Rating Category") + ylab("Median Price ($)") + ggtitle("Median Price by Rating Category") + theme_economist() + theme(plot.title = element_text(hjust = 0.5))

#Examine the relationship between rating category (X-axis) and mean ABV% (Y-axis)
ggplot(data=whisky,aes(x=rating_category,y=ABV))+geom_bar(stat = 'summary',fun.y='mean')+scale_x_discrete(limits = positions) + xlab("Rating Category") + ylab("Mean ABV (%)") + ggtitle("Mean ABV% by Rating Category") + theme_economist() + theme(plot.title = element_text(hjust = 0.5))

#Examine the relationship between rating category (X-axis) and mean ABV% (Y-axis)
ggplot(data=whisky,aes(x=rating_category,y=age))+geom_bar(stat = 'summary',fun.y='mean')+scale_x_discrete(limits = positions) + xlab("Rating Category") + ylab("Mean Age (Years)") + ggtitle("Mean Whisky Age by Rating Category") + theme_economist() + theme(plot.title = element_text(hjust = 0.5))

#Examine the relationship between rating category (X-axis) and mean polarity (Y-axis)
ggplot(data=whisky,aes(x=rating_category,y=polarity))+geom_bar(stat = 'summary',fun.y='mean')+scale_x_discrete(limits = positions) + xlab("Rating Category") + ylab("Mean Polarity") + ggtitle("Mean Polarity by Rating Category") + theme_economist() + theme(plot.title = element_text(hjust = 0.5))

#Examine correlations between review_point and numerical variables (e.g. price, ABV, age, nchar_description, sentence_count)
cor(whisky$review_point, whisky$price) #0.131
cor(whisky$review_point, whisky$ABV) #0.071
cor(whisky$review_point, whisky$age) #0.296
cor(whisky$review_point, whisky$nchar_description) #0.156
cor(whisky$review_point, whisky$sentence_count) #0.140
cor(whisky$review_point, whisky$polarity) #0.140

#Further sentiment analysis - let's first load the NRC lexicon
nrc = read.table(file = 'https://raw.githubusercontent.com/pseudorational/data/master/nrc_lexicon.txt',header = F,col.names = c('word','sentiment','num'),sep = '\t'); nrc = nrc[nrc$num!=0,]; nrc$num = NULL

#Count instance of words relative to NRC lexicon (e.g. number of "surprise" or "joy" words)
whisky%>%
  group_by(id)%>%
  unnest_tokens(output = word, input = description)%>%
  inner_join(nrc)%>%
  group_by(sentiment)%>%
  count()
#38,474 words total, most words are associated with positive (12,197 words, or 31.7%) and trust (5,168 words, or 13.4%)

#Calculate correlations between NRC lexicon emotions and review_point
whisky%>%
  group_by(id)%>%
  unnest_tokens(output = word, input = description)%>%
  inner_join(nrc)%>%
  group_by(id,sentiment,review_point)%>%
  count()%>%
  ungroup()%>%
  group_by(sentiment)%>%
  summarize(correlation = cor(n,review_point))
#Correlations seem weak to mild- largest one is with positive (0.183) and joy (0.118); there exists a negative correlation with disgust (-0.0374) and surprise (-0.0146)

#Count number of negative vs. positive words with the "bing" lexicon
whisky%>%
  group_by(id)%>%
  unnest_tokens(output = word, input = description)%>%
  inner_join(get_sentiments('bing'))%>%
  group_by(sentiment)%>%
  count() #From all the whisky reviews, approximately 71% of words are positive 

####################################################### PREDICTIVE MODELLING ##########################################################

#1st decision tree model
tree = rpart(review_rating~.,data=train, cp=0.005)
rpart.plot(tree)

whisky_tree <- whisky_data[, -c(2)]
split = sample(1:nrow(whisky_tree), size = 0.7*nrow(whisky_tree))
train1 = whisky_tree[split,]
test1 = whisky_tree[-split,]

#2nd decision tree model
tree1 <- ctree(review_rating~., data = train1, controls = ctree_control(mincriterion = 0.95, minsplit = 50))
tree1
plot(tree1)

#Predict
predict(tree1, test)

#Store whisky_tree to whisky_forest
whisky_forest <- whisky_tree


# RANDOM FOREST

#Split dataset into train and test data
set.seed(123)
split = sample(1:nrow(whisky_forest),size = 0.7*nrow(whisky_forest))
train = whisky_tree[split,]
test = whisky_tree[-split,]

set.seed(100)
bag <- randomForest(review_rating~., data = train, mtry = ncol(train)-1, ntree = 1000)
predBag = predict(bag, newdata = test)
rmseBag = sqrt(mean((predBag - test$review_rating)^2))
rmseBag #3.917517
plot(bag)

varImpPlot(bag); importance(bag) #See variable imortance
getTree(bag, k=100) #View tree 100
hist(treesize(bag)) #Size of trees constructed


# RANDOM FOREST
set.seed(333)
forest = randomForest(review_rating~., data = train, ntree = 1000)
predForest = predict(forest, newdata = test)
rmseForest = sqrt(mean((predForest - test$review_rating)^2))
rmseForest #3.875111

#names(forest)
#summary(forest)
plot(forest)

varImpPlot(forest); importance(forest) #See variable importance

getTree(forest, k = 100) #View tree 100
hist(treesize(forest)) #Size of trees constructed

#RandomForest with cross-validation
trControl = trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(mtry = 1:5)
set.seed(100)
cvForest = train(review_rating~., data = train, method = "rf", ntree = 1000, trControl = trControl, tuneGrid = tuneGrid)
cvForest #Best mtry was 5; RMSE 3.698239

#Boosting
set.seed(100)
boost = gbm(review_rating~., data = train, distribution = "gaussian",
            n.trees = 100000, interaction.depth = 3, shrinkage = 0.001)
predBoostTrain = predict(boost, n.trees = 100000)
rmseBoostTrain = sqrt(mean((predBoostTrain - train$review_rating)^2))
rmseBoostTrain #2.41912
summary(boost) #whiskies 4.426, oak 4.360, complex 3.391, fruit 3.054

predBoost = predict(boost, newdata = test, n.trees = 10000)
rmseBoost = sqrt(mean((predBoost - test$review_rating)^2))
rmseBoost #3.570576

#Boosting with cross-validation
set.seed(100)
trControl = trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(n.trees = 1000, interaction.depth = c(1,2),
                       shrinkage = (1:100)*0.001, n.minobsinnode = 5)
cvBoost = train(review_rating~., data = train, method = "gbm",
                trControl = trControl, tuneGrid = tuneGrid) #this took somewhere between half an hr to an hr to run

boostCV = gbm(review_rating~., data = train, distribution = "gaussian",
              n.trees = cvBoost$bestTune$n.trees,
              interaction.depth = cvBoost$bestTune$interaction.depth,
              shrinkage = cvBoost$bestTune$shrinkage,
              n.minobsinnode = cvBoost$bestTune$n.minobsinnode)
predBoostCV = predict(boostCV, test, n.trees = 1000)
rmseBoostCV = sqrt(mean((predBoostCV - test$review_rating)^2))
rmseBoostCV #3.7325

### Check for frequency of the top words chosen by decision tree from bag of words
new_whisky$complex_count<-as.vector(str_count(new_whisky$description, pattern = "complex"))
new_whisky$long_count<-as.vector(str_count(new_whisky$description, pattern = "long"))
new_whisky$rich_count<-as.vector(str_count(new_whisky$description, pattern = "rich"))
new_whisky$cinnamon_count<-as.vector(str_count(new_whisky$description, pattern = "cinnamon"))
new_whisky$smoke_count<-as.vector(str_count(new_whisky$description, pattern = "smoke"))
new_whisky$dark_count<-as.vector(str_count(new_whisky$description, pattern = "dark"))
new_whisky$oak_count<-as.vector(str_count(new_whisky$description, pattern = "oak"))
new_whisky$chocolat_count<-as.vector(str_count(new_whisky$description, pattern = "chocolat."))
new_whisky$release_count<-as.vector(str_count(new_whisky$description, pattern = "release"))
new_whisky$pepper_count<-as.vector(str_count(new_whisky$description, pattern = "pepper"))

### Create multi-class classification model

# Change from character to factor
new_whisky$name<-as.factor(new_whisky$name)
new_whisky$brand<-as.factor(new_whisky$brand)
new_whisky$category<-as.factor(new_whisky$category)
new_whisky$description<-as.factor(new_whisky$description)
new_whisky$rating_category<-as.factor(new_whisky$rating_category)

# Assign numeric value to categories
new_whisky$rating_number[(new_whisky$rating_category == "Classic")] = 6
new_whisky$rating_number[(new_whisky$rating_category == "Outstanding")] = 5
new_whisky$rating_number[(new_whisky$rating_category == "Very good")] = 4
new_whisky$rating_number[(new_whisky$rating_category == "Good")] = 3
new_whisky$rating_number[(new_whisky$rating_category == "Mediocre")] = 2
new_whisky$rating_number[(new_whisky$rating_category == "Not recommended")] = 1

# Remove factor variables with more than 53 levels and redundant variables
whisky_rf<-new_whisky[, -c(2,3,4,7,9,14)]

# Split data
set.seed(123)
split = sample(1:nrow(whisky_rf),size = 0.7*nrow(whisky_rf))
train = whisky_rf[split,]
test = whisky_rf[-split,]

# Do Random Forest
# RANDOM FOREST
set.seed(333)
forest = randomForest(rating_number~., data = train, ntree = 1000)
predForest = predict(forest, newdata = test)
rmseForest = sqrt(mean((predForest - test$rating_number)^2))
rmseForest #0.08952058

#names(forest)
#summary(forest)
plot(forest)

varImpPlot(forest); importance(forest) #See variable importance

getTree(forest, k = 100) #View tree 100
hist(treesize(forest)) #Size of trees constructed

#RandomForest with cross-validation
library(caret)
trControl = trainControl(method = "cv", number = 10)
tuneGrid = expand.grid(mtry = 1:5)
set.seed(100)
cvForest = train(rating_number~., data = train, method = "rf", ntree = 1000, trControl = trControl, tuneGrid = tuneGrid)
cvForest #Best mtry was 3; RMSE 0.7550336

