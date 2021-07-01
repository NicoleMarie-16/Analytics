### Decision Trees ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(rpart)
library(rpart.plot)
library(ggplot2)

### Import Data
wages = read.csv(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/wages.csv"))

### Remove values under 0
wages = wages[wages$earn>0,]

### Find what fraction of the population female
females = sum(wages$sex == 'female')
females/nrow(wages)
# 0.627924

### Which race earns the least?
tapply(wages$earn, wages$race, 'mean')
# We see that Hispanics earn the least

### Let's split the data into train and test samples such that 75% of the observations are in the train sample.
set.seed(100)
split = sample(1:nrow(wages), nrow(wages)*0.75)
train = wages[split,]
test = wages[-split,]
nrow(train)
# We see that there are 1026 observations in the train set.

### Construct a linear regression model to predict earn using all variables
model1=lm(earn~.,train)

### Which of the predictors were considered significant?
anova(model1)
summary(model1)
# We see that height, sex (specifically male), education, and age are determinant factors

### Let us generate predictins using model1 and compute the root mean squared error on the training sample since tree models
# don't generate an R2.
pred=predict(model1)
# RMSE
sse=sum((pred-train$earn)^2)
sst=sum((mean(train$earn)-train$earn)^2)
sse1=sum((pred-train$earn)^2)
rmse1=sqrt(mean((pred-train$earn)^2))
rmse1
# We see that the RMSE of model1 is equal to 26567.31

### Let's consider an interaction hypothesis. Let's say education impacts earning differently for men than for women. Specifically,
#   education boosts earnings more for men than for women and visualize this interaction.
ggplot(data=train,aes(y=earn,x=sex,fill=factor(ed)))+ geom_bar(stat="summary",fun.y="mean",position="dodge")
# Visualize regression separately for men and women
ggplot(data=train,aes(y=earn,x=ed,color=sex))+
  geom_smooth(method="lm",se=F,size=1.2)+ 
  scale_x_continuous(breaks=c(seq(2,20,2)))+
  scale_y_continuous(breaks=c(seq(0,100000,20000)))
# We see an approximate difference in earn between 12 years and 16 years of education for males of 20000, whereas for females it is
# about 15000.

### Now that we know this, let's construct a regression that only models effects of ed and sex on earn.
model_sex_ed = lm(earn~sex + ed + sex*ed,data=train)
# Now verify significance
anova(model_sex_ed)
summary(model_sex_ed)
# We see that education and educated males are considered significant (with a p-value < 0.05) so we se that sex and education interact
# in predicting earn.

### Let's incorporae our findings into a new model that incorporates all the variables in model1 and the interaction between sex and
#   ed from the previous model.
model2=lm(earn~height+sex+race+ed+age+sex*ed,data=train)
# Generate prediction
pred2=predict(model2)
# Calculate RMSE
sse2=sum((pred2-train$earn)^2)
sst2=sum((mean(train$earn)-train$earn)^2)
sse3=sum((pred2-train$earn)^2)
rmse2=sqrt(mean((pred2-train$earn)^2))
rmse2
# We get an RMSE of 26516.03, which is lower than the one for our first model because we accounted for this interaction.

### Now let's see what happens when we add the interaction between sex and age to model2
model3=lm(earn~height+sex+race+ed+age+sex*ed+sex*age,data=train)
# Generate prediction
pred3=predict(model3)
# Calculate RMSE
sse3=sum((pred3-train$earn)^2)
sst3=sum((mean(train$earn)-train$earn)^2)
sse4=sum((pred3-train$earn)^2)
rmse3=sqrt(mean((pred3-train$earn)^2))
rmse3
# We get an even lower RMSE of 26512.54

### Now let's add the interaction between ed and age to model3
model4=lm(earn~height+sex+race+ed+age+sex*ed+sex*age+age*ed,data=train)
# Generate predictions
pred4=predict(model4)
# Calculate RMSE
sse4=sum((pred4-train$earn)^2)
sst4=sum((mean(train$earn)-train$earn)^2)
sse5=sum((pred4-train$earn)^2)
rmse4=sqrt(mean((pred4-train$earn)^2))
rmse4
# RMSE goes down again with a value of 26508.2

# Let's now construct a model that considers all possible pairwise interactions.
model5 = lm(earn~(height+sex+race+ed+age)^2,data=train)
# Generate predictions
pred5=predict(model5)
# Calculate RMSE
sse5=sum((pred5-train$earn)^2)
sst5=sum((mean(train$earn)-train$earn)^2)
sse6=sum((pred5-train$earn)^2)
rmse5=sqrt(mean((pred5-train$earn)^2))
rmse5
# We get an RMSE of 26261.21, our lowest so far
summary(model5)
# We see that now none of our original variables are relevant

### Calculate RMSE for the test data on the model With the lowest RMSE
pred6 = predict(model5, newdata=test)
sse5_test = sum((pred6 - test$earn)^2)
sst5_test = sum((mean(test$earn)-test$earn)^2)
model5_r2_test = 1 - sse5_test/sst5_test
rmse5_test = sqrt(mean((pred6-test$earn)^2))
rmse5_test
# When we apply this to the test data, we see that the RMSE actually increases to 27949.29

### Now, let's develop a regression tree to predict earn using all other variables and identify the first variable that is used for
#   the split.
tree1=rpart(earn~height+sex+race+ed+age,data=train)
# Visualize the tree
par(mar=c(1,1,1,1))
prp(tree1,digits=5)
# Our 12-leaf tree shows that sex is the first variable where the split occurs.

### Now let's compute RMSE for our tree
pred=predict(tree1)
sse=sum((pred-train$earn)^2)
sst=sum((mean(train$earn)-train$earn)^2)
sse1=sum((pred-train$earn)^2)
rmse1=sqrt(mean((pred-train$earn)^2))
rmse1
# We get an RMSE of 24367.89

### Let's now try to simplify our tree by specifying a minbucket of 20
treeSimp1 = rpart(earn~.,data=train,control=rpart.control(minbucket=20))
prp(treeSimp1,digits=5)
# We see that our tree now has 9 leaves, instead of 12

### Now, let's calculate the RMSe
pred2=predict(treeSimp1)
sse2=sum((pred2-train$earn)^2)
sst2=sum((mean(train$earn)-train$earn)^2)
sse3=sum((pred2-train$earn)^2)
rmse2=sqrt(mean((pred2-train$earn)^2))
rmse2
# We see slight increase in RMSE, with a value of 25466.95

### What happens if we simplify our tree even more?
treeSimp2 = rpart(earn~.,data=train,control=rpart.control(minbucket=50))
prp(treeSimp2,digits=5)
# Calculate RMSE 
pred3=predict(treeSimp2)
sse3=sum((pred3-train$earn)^2)
sst3=sum((mean(train$earn)-train$earn)^2)
sse4=sum((pred3-train$earn)^2)
rmse3=sqrt(mean((pred3-train$earn)^2))
rmse3
# We get a 7-leaf tree with an RMSE of 26328.55. Reducing the complexity of the model is not improving the model

### Let's construct a large tree instead.
treeComplex1 = rpart(earn~.,data=train,control=rpart.control(minbucket=5))
prp(treeComplex1,digits=5)
# Calculate RMSE
pred4=predict(treeComplex1)
sse4=sum((pred4-train$earn)^2)
sst4=sum((mean(train$earn)-train$earn)^2)
sse5=sum((pred4-train$earn)^2)
rmse4=sqrt(mean((pred4-train$earn)^2))
rmse4
# We see a reduction in RMSE with a value of 24348.58, and an increase in leaves, back to 12

### Now, what if we construct a maximal tree?
treeComplex2 = rpart(earn~.,data=train,control=rpart.control(minbucket=1))
prp(treeComplex2,digits=5)
# Calculate RMSE
pred5=predict(treeComplex2)
sse5=sum((pred5-train$earn)^2)
sst5=sum((mean(train$earn)-train$earn)^2)
sse6=sum((pred5-train$earn)^2)
rmse5=sqrt(mean((pred5-train$earn)^2))
rmse5
# Now with a 15-leaf tree, we get an RMSE of 23180.9

### Let's calculate the RMSE on the test data for our initial tree, and then for the best performing
#   simple and complex trees.
# Let's begin with our linear regression model
# Let's continue with our initial tree (tree1)
pred6=predict(tree1,newdata=test)
sse6=sum((pred6-test$earn)^2)
sst6=sum((mean(test$earn)-test$earn)^2)
sse7=sum((pred6-test$earn)^2)
rmse6=sqrt(mean((pred6-test$earn)^2))
rmse6
# 29545.45
# Now, let's do treeSimp2 
pred7=predict(treeSimp2,newdata=test)
sse7=sum((pred7-test$earn)^2)
sst7=sum((mean(test$earn)-test$earn)^2)
sse7=sum((pred7-test$earn)^2)
rmse7=sqrt(mean((pred7-test$earn)^2))
rmse7
# 28238.25
# And finally, let's do treeComplex2 
pred8=predict(treeComplex2,newdata=test)
sse8=sum((pred8-test$earn)^2)
sst8=sum((mean(test$earn)-test$earn)^2)
sse9=sum((pred8-test$earn)^2)
rmse7=sqrt(mean((pred8-test$earn)^2))
rmse7
# 28888.88
# We see that out of the tree models, the one that performed the best on the test data was actuallt the more complex out of the simple
# trees: treeSimp2. However, the best performing model on the test data overall was model5, with an RMSE of 27949.29
