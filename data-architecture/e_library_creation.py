"""
Created on Fri Feb  7 08:18:06 2020
@author: Nicole Davila
MongoDB: Creating a database for an eLibrary Sample
"""

# Import required packages
from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient('localhost', 27017)

### Part I: Creating the database

# Create the database
db = client['e_library']

# Ensure it does not exist
db.list_collection_names()

# Create the books collection
db.createCollection("books", {
	validator: {$jsonSchema: {
		bsonType: "object",
		required: ["_id", "title", "primary_author", "publication_date", "page_number", "publisher", "topic"],
		properties: {
			_id: {
			bsonType: "string"
			},
			title: {
			bsonType: "string"
			},
			primary_author: {
			bsonType: "string"
			},
			secondary_authors: {
			bsonType: "array"
			},
			publication_date: {
			bsonType: "int"
			},
			page_number: {
			bsonType: "int"
			},
			publisher: {
			bsonType: "string"
			},
			translator: {
			bsonType: "string"
			},
			topic: {
			bsonType: "string"
			}
			}
		}
	}
})

# Create users collection
db.createCollection("users", {
	validator: {$jsonSchema: {
		bsonType: "object",
		required: ["_id", "name", "phone", "address"],
		properties: {
			_id: {
			bsonType: "string"
			},
			name: {
			bsonType: "string"
			},
			phone: {
			bsonType: "string"
			},
			address: {
			bsonType: "string"
			},
			uni_affiliation: {
			bsonType: "string"
			}
			}
		}
	}})

# Create book_checkouts collection
db.createCollection("book_checkouts", {
	validator: {$jsonSchema: {
		bsonType: "object",
		required: ["_id", "checkout_date", "book_title", "book_topic", "user_name"],
		properties: {
			_id: {
			bsonType: "string"
			},
			checkout_date: {
			bsonType: "date"
			},
			book_title: {
			bsonType: "string"
			},
			book_topic: {
			bsonType: "string"
			},
			user_name: {
			bsonType: "string"
			},
			user_uni_affiliation: {
			bsonType: "string"
			}
			}
		}
	}
})


### Part II: Inserting records into the collections

# Insert documents into books
db.books.insert([{"_id":"0001","title":"Don Quixote","primary_author":"Miguel de Cervantes","publication_date": NumberInt(1605),
		"page_number": NumberInt(800),"publisher":"Wordsworth Editions Ltd","translator":"Pepito del Monte","topic":"Fiction"},
		{"_id":"0002","title":"Learning R","primary_author":"Jon Doe","secondary_authors": ["Jane Doe", "Maria del Pueblo"],
		"publication_date": NumberInt(2015),"page_number": NumberInt(200),"publisher":"Nicole Eds","topic":"Machine Learning"},
		{"_id":"0003","title":"Business 101","primary_author":"Jimmy Smith","publication_date": NumberInt(1995),
		"page_number": NumberInt(150),"publisher":"PublishMe","topic":"Business"}])

#Insert documents into users
db.users.insert([{"_id": "100", "name": "Nicole Davila", "phone": "787-121-2342", "address": "12 E 42nd St, Apt 3D, New York, NY 10017",
		"uni_affiliation": "Columbia University"},
		{"_id": "101", "name": "Maritza Melendez", "phone": "210-234-4543", "address": "27 W 36th St, Suite 300, New York, NY, 10009",
		"uni_affiliation": "Columbia University"},
		{"_id": "102", "name": "Coralys Marquez", "phone": "210-556-6543", "address": "15 E Walnut St, Unit 2, New York, NY, 10010",
		"uni_affiliation": "Universidad de Puerto Rico"},
		{"_id": "103", "name": "James Arthur", "phone": "989-084-8549", "address": "18 Wabash Ln, Apt 303, Chicago, IL, 60635",
		"uni_affiliation": "Rutgers University"},
		{"_id": "104", "name": "Juanita Hernandez", "phone": "121-343-6543", "address": "54 N 65th St, Apt 15, New York, NY, 10013",
		"uni_affiliation": "George Washington University"}])

# Insert documents into book_checkouts
db.book_checkouts.insert([{"_id": "200", "book_title": "Don Quixote", "checkout_date": new Date("2019-01-15"),
		"book_topic": "Fiction", "user_name": "Nicole Davila", "user_uni_affiliation": "Columbia University"},
		{"_id": "201", "book_title": "Learning R", "checkout_date": new Date("2019-02-15"),
		"book_topic": "Machine Learning", "user_name": "Maritza Melendez", "user_uni_affiliation": "Columbia University"},
		{"_id": "203", "book_title": "Business 101", "checkout_date": new Date("2019-03-15"),
		"book_topic": "Business", "user_name": "Coralys Marquez", "user_uni_affiliation": "Universidad de Puerto Rico"},
		{"_id": "204", "book_title": "Learning R", "checkout_date": new Date("2019-04-15"),
		"book_topic": "Machine Learning", "user_name": "James Arthur", "user_uni_affiliation": "Rutgers University"},
		{"_id": "202", "book_title": "Business 101", "checkout_date": new Date("2019-05-15"),
		"book_topic": "Business", "user_name": "Juanita Hernandez", "user_uni_affiliation": "George Washington University"}])


### Basic querying

# Which books have been checked out since 2019-02-15 and 2019-04-15?
db.book_checkouts.find({"checkout_date": { $gte: new Date("2019-02-15"), $lte: new Date("2019-04-15") } })

# Which users have checked out Don Quixote and Learning R?
db.book_checkouts.find({"book_title": {$in: ["Don Quixote", "Learning R"]}})

# How many books does the library have on Fiction and Business?
db.books.count({"topic": {$in: ["Fiction", "Business"]}}) 

# Which users from Columbia University have checked out books on Machine Learning between 2019-01-15 and 2019-03-15?
db.book_checkouts.find({"user_uni_affiliation": "Columbia University", "book_topic": "Machine Learning", "checkout_date":
	{$gte: new Date("2019-01-15"), $lte: new Date("2019-03-15")}})
