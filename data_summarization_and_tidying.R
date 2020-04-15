### Data Summarization and Tidying Using ggplot2's diamond Dataset ### -------------------------------------------

# By: Nicole Davila
# Date: 2020-05-06

### Import required libraries
library(ggplot2)
library(dplyr)
library(tidyr)

### What is the average carat size of a diamond?
mean(diamonds$carat)
# 0.7979397

### What is the average carat size of an Ideal cut diamond?
mean(diamonds$carat[diamonds$cut == "Ideal"])
# 0.702837

### Which cut of diamond has the largest variance in carat size?
var(diamonds$carat[diamonds$cut=="Fair"])
# Fair

### Let's compare number of diamonds by cut but only for color "D". Which cut has the greatest selection (i.e., highest count)
#   in color D?
tally(diamonds, diamonds$color == "D" & diamonds$cut == "Ideal")
# Ideal

### What is the average price in Euros of diamonds larger than 1 carat (assuming $1 = 0.85 Euro)? 
mean(diamonds$price[diamonds$carat > 1]) * 0.85
# 7140.268

### Let's construct a density curve of price and then add faceting based on cut.
ggplot(data=diamonds, aes(x=price))+
  geom_density(size=1.2)+
  facet_grid(cut~.)

### Now, let's construct a similar density curve but adding cut as a color aesthetic rather than using faceting.
ggplot(data=diamonds, aes(x=price, color=cut))+
  geom_density(size=1.2)
# Based on these vidualizations, we see that Ideal cut diamonds tend to be less expensive than Fair cut diamonds

### Let's construct a density curve of carat. 
ggplot(data=diamonds, aes(x=carat))+
  geom_density(size=1.2)

### Let's add faceting based on cut to the above density curve.
ggplot(data=diamonds, aes(x=carat))+
  geom_density(size=1.2)+
  facet_grid(cut~.)

### Similar to what we did earlier, let's construct a similar density curve replacing faceting with cut as a color aesthetic.
ggplot(data=diamonds, aes(x=carat, color=cut))+
  geom_density(size=1.2)
# Based on the plot we see that Ideal cut diamonds tend to be smaller (i.e., lower carat) than Fair cut diamonds.

### Let's construct a histogram for carat.
ggplot(data=diamonds,aes(x=carat))+ 
  geom_histogram(binwidth = 0.01)+
  coord_cartesian(xlim=c(0,2.5))+
  scale_x_continuous(breaks=seq(0,2.5,0.1))
# The spikes in the density plot represent the popularity of the diamond at a certain carat size. 
# The following represent peaks (local maxima) in the density plot: 0.3, 0.4, 0.5, 0.7, 0.9, 1, 1.5, 2

### Let's simulate some data that compares ten models on three commonly used indices, rmse, sse, and r2. 
model = paste('model',1:10,sep = '')
sse = runif(10,min = 4000,max = 10000)
rmse = sqrt(sse)
r2 = ((rmse - min(rmse))/(max(rmse)-min(rmse)))*0.9
results = data.frame(model, sse, rmse, r2)
results

### Since this data is in a wide format, it limits the types of analysis that can be run and functions that can be applied. Let's
#   select an option that will transform results into a meaningful tall format with model in column 1, metric in column 2, and
#   value in column 3. 
results %>% gather(key=metric, value=value, 2:4)

### Let's compute the average of variable x excluding the 0 values.
diamonds_new = diamonds
diamonds_new$x[diamonds_new$x==0] = NA
mean(diamonds_new$x, na.rm=T)
# 5.732007
  
       
                          