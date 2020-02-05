### Berlin Airbnb group project: Creating relational database ###

### File Date: 2019-08-04

### Collaborators
# Nicole Davila 
# Byung Joo Kim
# Qingyan Cao
# Yu Wan

rm(list=ls()) 

# Install required packages
install.packages('RPostgreSQL')
install.packages('stringr')
install.packages('reshape')
require(RPostgreSQL)
require(stringr)
require(reshape)

# Load the PostgreSQL driver
drv <- dbDriver('PostgreSQL')

# Create connection
con <- dbConnect(drv, dbname = 'airbnb',
                 host = 'su19server.apan5310.com', port = 50101,
                 user = 'postgres', password = 'gb455o0x')

# Create tables
dbGetQuery(con, "CREATE TABLE list (
           list_id		 varchar(20),
           list_url     varchar(100) NOT NULL,
           PRIMARY KEY  (list_id)	
);")

dbGetQuery(con, "CREATE TABLE responses (
           response_id		varchar(20),
           response	 	varchar(20),
           PRIMARY KEY  (response_id)	
);")

dbGetQuery(con, "CREATE TABLE hosts (
           host_id		 	varchar(20),
           host_name	 	varchar(100),
           host_url     	varchar(100) NOt NULL,
           response_id	 	varchar(20),	
           PRIMARY KEY  (host_id),
           FOREIGN KEY  (response_id) REFERENCES responses (response_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE
);")


dbGetQuery(con, "CREATE TABLE cities (
           city_id		 varchar(20),
           city     	 varchar(50),
           PRIMARY KEY  (city_id)	
);")

dbGetQuery(con, "CREATE TABLE states (
           state_id		 varchar(20),
           state     	 varchar(50),
           PRIMARY KEY  (state_id)	
);")

dbGetQuery(con, "CREATE TABLE countries (
           country_id		 varchar(20),
           country     	 varchar(50),
           PRIMARY KEY  (country_id)	
);")

dbGetQuery(con, "CREATE TABLE neighborhood (
           neighborhood_id		varchar(20),
           neighborhood_group		varchar(50),
           PRIMARY KEY  (neighborhood_id)
);")

dbGetQuery(con, "CREATE TABLE neighborhood_overview (
           neighborhood_overview_id		varchar(20),
           neighborhood_overview	 	text,
           neighborhood_id            varchar(20),
           PRIMARY KEY  (neighborhood_overview_id),
           FOREIGN KEY (neighborhood_id) REFERENCES neighborhood (neighborhood_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE
);")

dbGetQuery(con, "CREATE TABLE locations (
           location_id			varchar(20),
           neighborhood_id	 	varchar(20),
           latitude				numeric(15,13) NOt NULL,
           longitude				numeric(15,13) NOt NULL,
           city_id					varchar(20),
           state_id					varchar(20),
           country_id					varchar(20),
           PRIMARY KEY  (location_id),
           FOREIGN KEY  (neighborhood_id) REFERENCES neighborhood (neighborhood_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (city_id) REFERENCES cities (city_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (state_id) REFERENCES states (state_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (country_id) REFERENCES countries (country_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE
);  ")

dbGetQuery(con, "CREATE TABLE property_types (
           property_type_id		 varchar(20),
           property_type     	 		varchar(50),
           PRIMARY KEY  (property_type_id)	
);")

dbGetQuery(con, "CREATE TABLE room_types (
           room_type_id		 varchar(20),
           room_type    	 		varchar(50),
           PRIMARY KEY  (room_type_id)	
);")

dbGetQuery(con, "CREATE TABLE bed_types (
           bed_type_id		 	varchar(20),
           bed_type     	 		varchar(50),
           PRIMARY KEY  (bed_type_id)	
);")

dbGetQuery(con, "CREATE TABLE reviewers (
           reviewer_id		 	varchar(30),
           reviewer_name     	 varchar(100),
           PRIMARY KEY  (reviewer_id)	
);")

dbGetQuery(con, "CREATE TABLE reviews (
           review_id		 	varchar(20),
           comments     	 	text,
           reviewer_id			varchar(30),
           list_id       	varchar(20),	
           date				date,
           PRIMARY KEY  (review_id),
           FOREIGN KEY  (reviewer_id) REFERENCES reviewers (reviewer_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (list_id) REFERENCES list (list_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE
);")

dbGetQuery(con, "CREATE TABLE properties (
           properties_id		 varchar(20),
           name			     text,
           list_id			     varchar(20),
           host_id				varchar(20),
           location_id		varchar(20),
           property_type_id		 varchar(20),
           room_type_id		 varchar(20),
           bed_type_id		 	varchar(20),
           description			text,
           notes				text,
           transit				text,
           accommodates		smallint,
           bathrooms		numeric(2,1),
           bedrooms		smallint,
           PRIMARY KEY  (properties_id),
           FOREIGN KEY  (list_id) REFERENCES list (list_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (host_id) REFERENCES hosts (host_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (location_id) REFERENCES locations (location_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (property_type_id) REFERENCES property_types (property_type_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (room_type_id) REFERENCES room_types (room_type_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE,
           FOREIGN KEY  (bed_type_id) REFERENCES bed_types (bed_type_id)
           ON DELETE CASCADE
           ON UPDATE CASCADE
);  ")

#read data
data = read.csv("new_data.csv")
review = read.csv("reviews (1).csv")

# Get data for list table
list <- data[, 2:3]
dbWriteTable(con, name="list", value=list, row.names=FALSE, append=TRUE)

# Get data for bed_types

bed_types <- data[c('bed_type')][!duplicated(data[c('bed_type')]),,drop= F]
bed_types$bed_type_id<-1:nrow(bed_types)
dbWriteTable(con, name="bed_types", value=bed_types, row.names=FALSE, append=TRUE)

# Get data for reviewers

reviewers <- review[c('reviewer_id','reviewer_name')][!duplicated(review[c('reviewer_id','reviewer_name')]),,drop= F]
dbWriteTable(con, name="reviewers", value= reviewers, row.names=FALSE, append=TRUE)

# Get data for reviews

reviews<- review[,c('comments','reviewer_id','listing_id','date')]
reviews$review_id<- 1:nrow(reviews)

names(reviews)[3]<-"list_id"
dbWriteTable(con, name="reviews", value= reviews, row.names=FALSE, append=TRUE)




# Create table room_types

room_types_df <- as.data.frame(data[c('room_type')][!duplicated(data[c('room_type')]),])
names(room_types_df)[1]<-"room_type"
room_types_df$room_type_id<-1:nrow(room_types_df)

dbWriteTable(con, name="room_types", value=room_types_df
             , row.names=FALSE, append=TRUE)

# Create table property_type

property_types_df <- as.data.frame(data[c('property_type')][!duplicated(data[c('property_type')]),])
names(property_types_df)[1]<-"property_type"
property_types_df$property_type_id<-1:nrow(property_types_df)

dbWriteTable(con, name="property_types", value=property_types_df
             , row.names=FALSE, append=TRUE)

# Create table responses

responses_df <- as.data.frame(data[c('response')][!duplicated(data[c('response')]),])
names(responses_df)[1]<-"response"
responses_df$response_id<-1:nrow(responses_df)

dbWriteTable(con, name="responses", value=responses_df
             , row.names=FALSE, append=TRUE)

# Create table hosts 

hosts_df <- as.data.frame(data[c('host_id', 'host_name', 'host_url', 'response')][!duplicated(data[c('host_id', 'host_name', 'host_url', 'response')]),])
hosts_df <- merge(hosts_df, responses_df, by.x = 'response', by.y = 'response')
hosts_df <- hosts_df[c("host_id", "host_name", "host_url", "response_id")]

dbWriteTable(con, name="hosts", value=hosts_df
             , row.names=FALSE, append=TRUE)




# Create table countries

data$country="Germany"
countries_df <- as.data.frame(data[c('country')][!duplicated(data[c('country')]),])
names(countries_df)[1]<-"country"
countries_df$country_id<-1:nrow(countries_df)
countries_df <- countries_df[c('country_id', 'country')]

dbWriteTable(con, name="countries", value=countries_df
             , row.names=FALSE, append=TRUE)


# Create table states

data$state="Berlin"
states_df <- as.data.frame(data[c('state')][!duplicated(data[c('state')]),])
names(states_df)[1]<-"state"
states_df$state_id<-1:nrow(states_df)
states_df <- states_df[c('state_id', 'state')]

dbWriteTable(con, name="states", value=states_df
             , row.names=FALSE, append=TRUE)

# Create table cities

data$city="Berlin"
cities_df <- as.data.frame(data[c('city')][!duplicated(data[c('city')]),])
names(cities_df)[1]<-"city"
cities_df$city_id<-1:nrow(cities_df)
cities_df <- cities_df[c('city_id', 'city')]

dbWriteTable(con, name="cities", value=cities_df
             , row.names=FALSE, append=TRUE)

# Create table neighborhood
names(data)[13]<-"neighborhood_group"
neighborhood_df <- as.data.frame(data[c('neighborhood_group','neighborhood_overview')][!duplicated(data[c('neighborhood_group','neighborhood_overview')]),])
neighborhood_df <- transform(neighborhood_df, id=match(neighborhood_group, unique(neighborhood_group)))
names(neighborhood_df)[3]<-"neighborhood_id"
neighborhood_df1 <- as.data.frame(neighborhood_df[,])
neighborhood_df <- neighborhood_df[c('neighborhood_id', 'neighborhood_group')]
neighborhood_df <- neighborhood_df[!duplicated(neighborhood_df),]

dbWriteTable(con, name="neighborhood", value=neighborhood_df
             , row.names=FALSE, append=TRUE)

# Create table neighborhood_overview

neighborhood_overview_df <- as.data.frame(neighborhood_df1[c('neighborhood_overview', 'neighborhood_id')][!duplicated(neighborhood_df1[c('neighborhood_overview', 'neighborhood_id')]),])
neighborhood_overview_df$neighborhood_overview_id<-1:nrow(neighborhood_overview_df)
neighborhood_overview_df <- neighborhood_overview_df[c('neighborhood_overview_id', 'neighborhood_overview', 'neighborhood_id')]

dbWriteTable(con, name="neighborhood_overview", value=neighborhood_overview_df
             , row.names=FALSE, append=TRUE)

# Create table locations

locations_df <- as.data.frame(data[c('longitude', 'latitude', 'neighborhood_group', 'city', 'state', 'country')]
                              [!duplicated(data[c('longitude', 'latitude', 'neighborhood_group', 'city', 'state', 'country')]),])
locations_df$location_id<-1:nrow(locations_df)
locations_df <- merge(locations_df, neighborhood_df, by.x = 'neighborhood_group', by.y = 'neighborhood_group') #neighborhood_id
locations_df <- merge(locations_df, cities_df, by.x = 'city', by.y = 'city') #city_id
locations_df <- merge(locations_df, states_df, by.x = 'state', by.y = 'state') #state_id
locations_df <- merge(locations_df, countries_df, by.x = 'country', by.y = 'country') #country_id
locations_df <- locations_df[c('location_id', 'neighborhood_id', 'latitude', 'longitude', 'city_id', 'state_id', 'country_id')]

dbWriteTable(con, name="locations", value=locations_df
             , row.names=FALSE, append=TRUE)

# Create table properties

properties_df <- as.data.frame(data[c('name', 'list_id','host_id','description', 'notes','transit','accommodates','bathrooms','bedrooms', 'latitude','longitude', 'property_type', 'room_type', 'bed_type')])
properties_df$properties_id<-1:nrow(properties_df)
properties_df$location_id <- 1:nrow(properties_df)
properties_df <- merge(properties_df, locations_df, by=c("latitude","longitude"))  #location_id
properties_df <- merge(properties_df, property_types_df, by.x = 'property_type', by.y = 'property_type') #property_type_id
properties_df <- merge(properties_df, room_types_df, by.x = 'room_type', by.y = 'room_type') #room_type_id
properties_df <- merge(properties_df, bed_types, by.x = 'bed_type', by.y = 'bed_type') #bed_type_id
properties_df$location_id <- properties_df$location_id.y
properties_df <- properties_df[c('properties_id','name', 'list_id','host_id', 'location_id','property_type_id','room_type_id','bed_type_id','description','notes','transit','accommodates','bathrooms','bedrooms')]

dbWriteTable(con, name="properties", value=properties_df
             , row.names=FALSE, append=TRUE)

dbDisconnect(con)