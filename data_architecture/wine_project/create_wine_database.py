import mysql.connector as msql
import json
from mysql.connector import Error

# Get credentials
with open("sql_credentials.json") as f:
    data = json.loads(f.read())
    creds = data[0]

# Create database
try:
    # Establish connection
    conn = msql.connect(host=creds["HOST"], user=creds["USER"], password=creds["PW"], auth_plugin='mysql_native_password')
    if conn.is_connected():
        cursor = conn.cursor()
        # Make sure database doesn't exist before attempting to create it
        databases = ("SHOW DATABASES;")
        cursor.execute(databases)
        dbs = []
        for (databases) in cursor:
            dbs.append(databases[0])
        if "aic" in dbs:
            print("A database called aic already exists. Skipping database creation...")
        else:
            cursor.execute("CREATE DATABASE aic")
            print("aic database has been created!")
except Error as e:
    print("Error while connecting to MySQL", e)

# Create artworks table
try:
    # Establish connection
    conn = msql.connect(host=creds["HOST"], user=creds["USER"], password=creds["PW"], auth_plugin='mysql_native_password')
    if conn.is_connected():
        cursor = conn.cursor()
        cursor.execute("USE aic;")
        cursor.execute("DROP TABLE IF EXISTS artworks;")
        print('Creating artworks table...')
        cursor.execute("""
                        CREATE TABLE IF NOT EXISTS artworks (
                                                                id INT,
                                                                title TEXT,
                                                                main_reference_number VARCHAR(50), 
                                                                date_start INT,
                                                                date_end INT,
                                                                date_display VARCHAR(255),
                                                                artist_display TEXT,
                                                                place_of_origin VARCHAR(50),
                                                                dimensions TEXT,
                                                                medium_display TEXT,
                                                                inscriptions TEXT,
                                                                credit_line TEXT,
                                                                is_public_domain VARCHAR(10),
                                                                copyright_notice VARCHAR(100),
                                                                is_on_view VARCHAR(10),
                                                                on_loan_display VARCHAR(255),
                                                                gallery_title VARCHAR(50),
                                                                artwork_type_title VARCHAR(255),
                                                                department_title VARCHAR(50),
                                                                artist_id VARCHAR(50),
                                                                artist_title VARCHAR(100),
                                                                style_title VARCHAR(100),
                                                                classification_title VARCHAR(100)
                                                                )
                        """)
        print("artworks table has been created!")
except Error as e:
    print("Error while connecting to MySQL", e)

# Create artworks_api_errors table
try:
    # Establish connection
    conn = msql.connect(host=creds["HOST"], user=creds["USER"], password=creds["PW"], auth_plugin='mysql_native_password')
    if conn.is_connected():
        cursor = conn.cursor()
        cursor.execute("USE aic;")
        print('Creating artworks_api_errors table...')
        cursor.execute("""
                        CREATE TABLE IF NOT EXISTS artworks_api_errors (
                                                                        page_number INT,
                                                                        error_message TEXT
                                                                        );
                        """)
        print("artworks_api_errors table has been created!")
except Error as e:
    print("Error while connecting to MySQL", e)