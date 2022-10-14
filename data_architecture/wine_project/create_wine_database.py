import mysql.connector as msql
import json
from mysql.connector import Error

# Get credentials
with open("/Users/nicol/Documents/utils/sql_credentials.json") as f:
    creds = json.loads(f.read())

# Create data source table
# Establish connection
conn = msql.connect(
    user=creds["USER"],
    password=creds["PW"],
    host=creds["HOST"],
    database='wine')

cursor = conn.cursor()
cursor.execute("DROP TABLE IF EXISTS wine.data_sources;")
print('Creating data_sources table...')


