### Clustering ### -----------------------------------------------------------------------------

# By: Nicole Davila
# Date: 2019-06-25

### Import required libraries
library(mice)
library(ggplot2)
library(mclust)
library(cluster)
library(dplyr)
library(tidyr)
library(RColorBrewer)

### Import Data
fastfood = read.csv(paste0(dirname(rstudioapi::getSourceEditorContext()$path), "/fastfood_survey.csv"))

### Let's see how many variables are in the dataset
ncol(fastfood)
# There are 21 variables

### First, let us subset the data to only include the first eleven variables, which are the characteristics that respondents rated the 
#   importance of for fast-food restaurants.
data_cluster=fastfood[,1:11]

###Q Now, let's for any missing values. 
sum(is.na(data_cluster))
# There are 333 missing values

###Question 4###

#### How many rows would we have left if we removed rows where any of the variables had missing values?
nrow(na.omit(data_cluster))
# 556

### Let's impute the missing values. 
set.seed(1706)
data_cluster = mice::complete(mice(data_cluster))
data_cluster_value=data_cluster[10,"cleanliness"]

### Let's standardize the variables since cluster analysis is sensitive to the scale of the variables,
data_cluster=scale(data_cluster)
head(data_cluster,10)

### Let's compute the Euclidean distance between all observations in data_cluster and see how many elements are in the distance matrix.
d=dist(x=data_cluster,method='euclidean')
length(d)
# 193131

###Let's conduct a Hierarchical cluster analysis using the method and plot the dendrogram from this process.
clusters=hclust(d=d,method='ward.D2')
plot(clusters)
# Now, let's see how well the dendrogram matches true distances by identifying the Cophenetic correlation coefficient.
cor(cophenetic(clusters),d)
# we get a value of 0.7974408

### Based on the distances shown in the dendrogram, which is the best cluster solution?
plot(cut(as.dendrogram(clusters),h=5)$upper)

plot(clusters)
rect.hclust(tree=clusters,k = 2,border='tomato')

plot(clusters)
rect.hclust(tree=clusters,k = 3,border='tomato')

plot(clusters)
rect.hclust(tree=clusters,k = 4,border='tomato')

plot(clusters)
rect.hclust(tree=clusters,k = 6,border='tomato')
# It appears to be that 2 is the best cluster solution

### If we decided to go with a two-cluster solution, how many observations would be in the smaller of the two clusters?
h_segments2 = cutree(tree = clusters,k=2)
table(h_segments2)
# 41

### If we decided to go with a three-cluster solution, how many observations would be in the smallest of the three clusters?
h_segments3 = cutree(tree = clusters,k=3)
table(h_segments3)
# 41 again

### Let's conduct k-means clustering to generate a two-cluster solution and see how many observations are in the smaller cluster?
set.seed(1706)
km1 = kmeans(x = data_cluster,centers = 2,iter.max=100,nstart=25)
table(km1$cluster)
# 41

### Let's run another k-means clustering, but this time to generate a three-cluster solution and see how many observations are in the
#   smallest cluster?
set.seed(1706)
km2 = kmeans(x = data_cluster,centers = 3,iter.max=100,nstart=25)
table(km2$cluster)
# 39 

### Now, let us examine a data driven approach to determining the number, rather than selecting the number of clusters and then ompute the
#   total within cluster sum of squares for cluster solutions from 2 to 10. What is the total within cluster sum of squares for a
#   three-cluster solution?
paste(km2$totss,'=',km2$betweenss,'+',km2$tot.withinss,sep = ' ')
km2$totss == km2$betweenss + km2$tot.withinss
within_ss = sapply(2:10,FUN = function(x) kmeans(x = data_cluster,
                                                 centers = x,iter.max = 100,nstart = 25)$tot.withinss)
within_ss
# 3808.567

### For the three-cluster solution, what the ratio of between sum of squares and total sum of squares is.
ratio_ss=km2$betweenss/km2$totss
ratio_ss
# 0.4424584

### Now, let's construct a line graph of clusters (on the x-axis) against total within cluster sum of squares (on y-axis). 
within_ss = sapply(2:10,FUN = function(x) kmeans(x = data_cluster,centers = x,iter.max = 100,nstart = 25)$tot.withinss)
ggplot(data=data.frame(cluster = 2:10,within_ss),aes(x=cluster,y=within_ss))+
  geom_line(col='steelblue',size=1.2)+
  geom_point()+
  scale_x_continuous(breaks=seq(1,10,1))
# Based on this chart, it seems like 2 and 3 are good cluster solutions.

###Question 11###
#Next, let us examine the Silhouette method, another data driven
#approach to choosing number of clusters. What is the average
#silhouette width for a 2 cluster solution? Use pam() from
#library(cluster) to compute silhouette width.
pam(data_cluster,k = 2)$silinfo$avg.width
#0.5936349

### What is the average silhouette width for a 3 cluster solution?
pam(data_cluster,k = 3)$silinfo$avg.width
# 0.1710672

### Let's examine average silhouette width for other cluster solutions.
silhoette_width = sapply(2:10,FUN = function(x) pam(x = data_cluster,k = x)$silinfo$avg.width)
paste(silhoette_width)  
# Based on this criterion, it appears that 2 is the best cluster solution.

### Now, let's make use of a Model-based clustering technique and identify how many clusters he model decided to group the data into.
clusters_mclust = Mclust(data_cluster)
summary(clusters_mclust)
# 8 clusters

### Using model-based clustering, let's force a two-cluster solution. How many observations are in the smallest cluster?
clusters_mclust_2 = Mclust(data_cluster,G=2)
summary(clusters_mclust_2)
# 178

### Let's compare the two-cluster solutions obtained from hierarchical cluster to k-means. Specifically, let's compare the cluster
#   assignments for hierarchical cluster analysis to k-means for the two-cluster solution. For how many observations do the cluster
#   assignments differ?
table(h_segments2)
table(km1$cluster)
# For the two clusters the observation assignemtns differ. In the hierarchical model cluster 1 gets 581 observations while cluster 2 gets
# 41, but in the k-means model, the numbers are reversed.

### Now, let's compare the two-cluster solutions for k-means to Model-based clustering. Specifically, let's compare the cluster
#   assignments for k-means to Model-based clustering. For how many observations do the cluster assignments differ?
summary(clusters_mclust_2)
table(km1$cluster)
# For both clusters the obsrvation assignments differ. 

### TODO: Continue editing

### Let's use k-means clustering with three clusters, setting a seed of 1706 and a maximum of 100 iterations.
names = colnames(data_cluster)
names
df = as.data.frame(cbind(km2$cluster, data_cluster))
colnames(df) = c("cluster", names)
head(df)
df[which.max(df$popularity_with_children), ]

m_clusters = Mclust(data = data_cluster,G = 3)
m_segments = m_clusters$classification
table(m_segments)

h_segments = cutree(tree = clusters,k=3)
table(h_segments)

set.seed(1706)
km = kmeans(x = data_cluster,centers = 3,iter.max=100,nstart=25)
k_segments = km$cluster
table(k_segments)

data2 = cbind(fastfood,k_segments)

data2 %>%
  select(speed_of_service:taste_burgers,k_segments)%>%
  group_by(k_segments)%>%
  summarize_all(function(x) round(mean(x,na.rm=T),2))%>%
  data.frame()

tab = prop.table(table(data2$k_segments,data2[,11]),1)
tab2 = data.frame(round(tab,2))

ggplot(data=tab2,aes(x=Var2,y=Var1,fill=Freq))+
  geom_tile()+
  geom_text(aes(label=Freq),size=6)+
  xlab(label = '')+
  ylab(label = '')+
  scale_fill_gradientn(colors=brewer.pal(n=9,name = 'Greens'))

# Compared to other clusters, cluster 1 does not have the lowest value for any of the variables. cluster 2, on the other hand has the 
# lowest values for popularity_with+children and drive_through. Finalyy, clster 3 has the lowest values for speed_of_service, variety,
# cleanliness, convenience, taste, price, friendliness, quality_of_fries, and taste_burgers.

### Now, let's understand the demographic makeup of the customers that belong to each cluster or market segment. Given that segment sizes
#   are different, let's examine the percentage of each group in the segment.
round(prop.table(table(data2$k_segment,data2$dollars_avg_meal),1),2)*100
round(prop.table(table(data2$k_segment,data2$age),1),2)*100
round(prop.table(table(data2$k_segment,data2$marital_status),1),2)*100
round(prop.table(table(data2$k_segment,data2$gender),1),2)*100
round(prop.table(table(data2$k_segment,data2$number_children),1),2)*100
round(prop.table(table(data2$k_segment,data2$own_rent),1),2)*100
round(prop.table(table(data2$k_segment,data2$dwelling),1),2)*100
round(prop.table(table(data2$k_segment,data2$occupation),1),2)*100
round(prop.table(table(data2$k_segment,data2$education),1),2)*100
round(prop.table(table(data2$k_segment,data2$income),1),2)*100

# We can see that compared to other clusters, cluster 1 spends the most when eating out, has the smallest percentage of singles, has the
# largest percentage of females, has the largest percentage stay at home moms, and has the least amount of education. We also see that, 
# compared to other clusters, luster 2 has the lowest percent home ownership and is the youngest. Finally, compared to other clusters,
# cluster 3 has the most number of children, has the largest percentage of professionals.
