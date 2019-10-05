# Load Libraries
library(data.table)

#Load Data
attrition <- as.data.table(read.csv("C:/Users/nicol/Desktop/assignment2.csv", encoding = "UTF-8"))

# Select R&D with no attrition
noAttritionRd <- attrition[Attrition == "No" & Department == "Research & Development"]

# Analysis for Question 2
nrow(noAttritionRd) # 828 employees
sum(noAttritionRd$MonthlyRate) # 11846425 monthly rate
(sum(noAttritionRd$MonthlyRate))*12 # 142157100 yearly salary
nrow(noAttritionRd[Gender == "Male"]) # 492 males
nrow(noAttritionRd[Gender == "Female"]) #336 females
((nrow(noAttritionRd[Gender == "Male"]))/(nrow(noAttritionRd)))*100 # 59.4Z% male
# Get mode of education and marital status
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}
getmode(noAttritionRd$Education) # 3 (bachelors)
getmode(noAttritionRd$MaritalStatus) # the majority are married
((nrow(noAttritionRd[MaritalStatus == "Married"]))/(nrow(noAttritionRd)))*100 #46.38% are married
mean(noAttritionRd$TotalWorkingYears) # 11.87 average total working years
mean(noAttritionRd$YearsAtCompany) # 7.17 average years at company
getmode(noAttritionRd$EducationField) # life sciences is the most common education field
getmode(noAttritionRd$JobRole) # research scientist is the most common job role
getmode(noAttritionRd$PerformanceRating) # 3 (excellent)




