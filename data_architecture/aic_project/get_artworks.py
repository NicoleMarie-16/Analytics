# Import Libraries
import httplib2
import json
import pandas as pd
import mysql.connector as msql
import sqlalchemy
from sqlalchemy import create_engine
from mysql.connector import Error
from pandas import json_normalize
from pprint import pprint

# Get SQL credentials
print("Getting SQL credentials...")
with open("sql_credentials.json") as f:
    data = json.loads(f.read())
    creds = data[0]

### API: artworks
# Establish connection
print("Establishing API connection...")
h = httplib2.Http()

# Get number to loop through
resp, content = h.request("https://api.artic.edu/api/v1/artworks?fields=pagination")
assert resp.status == 200
assert resp['content-type'] == 'application/json'

# How many records per page?
content_str = content.decode('utf-8')
d = json.loads(content_str)
total_pages = d["pagination"]["total_pages"]

# Define API function
def get_artworks(total_pages, start=1, verbose=False):
    if start > total_pages:
        total_pages = start
    try:
        # Establish connection
        conn = msql.connect(host=creds["HOST"], user=creds["USER"], password=creds["PW"], auth_plugin='mysql_native_password')
        if conn.is_connected():
            cursor = conn.cursor()
    except Error as e:
        print("Error while connecting to MySQL", e)
    # Create engine
    engine = create_engine("mysql+mysqlconnector://{user}:{password}@{host}/aic?auth_plugin=mysql_native_password".format(user=creds["USER"],
                                                                                        password=creds["PW"],
                                                                                        host=creds["HOST"]))
    try:
        engine.connect()
    except Exception as e:
        print("Error connecting to database: ", e)

    failed_pages = pd.DataFrame(columns = ['page_number', 'error_message'])
    for i in range(start, total_pages + 1):
        # Make the API requests
        request_string = "https://api.artic.edu/api/v1/artworks?fields=id,title,main_reference_number,date_start,date_end,date_display,artist_display,place_of_origin,dimensions,medium_display,inscriptions,credit_line,is_public_domain,copyright_notice,is_on_view,on_loan_display,gallery_title,artwork_type_title,department_title,artist_id,artist_title,style_title,classification_title&page={page_num}".format(
            page_num=i)
        if verbose:
            print("Retrieving results from page {page_num}".format(page_num=i))
        resp, content = h.request(request_string)

        # Parse results
        results_list = []
        content_str = content.decode('utf-8')
        d = json.loads(content_str)
        results_list.append(d)
        last_page = i

        # Convert to data frame
        data = pd.DataFrame()
        for i in results_list:
            data_single = json_normalize(i['data'])
            data = data.append(data_single)

        # Load to database
        if verbose:
            print("Loading data to database...")
        try:
            data.to_sql('artworks', con=engine, if_exists='append', chunksize=1000, index=False)
        except Exception as e:
            print("Error loading data: ", e)
            failed_pages.append({'page_number': i, 'error_message': e})

    return data, last_page, failed_pages

# Get artworks
print("Retrieving API data...")
results = get_artworks(total_pages = total_pages, verbose=True)

# Error handling
print("Error handling...")
last_page = results[1]
if last_page == total_pages:
    print("Successfully retrieved all artworks!")
else:
    print("An error occurred while retrieving the artworks. The process errored out on page {page}. Will re-try getting the remainder of the data.".format(page=last_page))
    results = get_artworks(total_pages = total_pages, start = last_page)

if failed_pages.empty:
    print("Successfully loaded all artworks!")
else:
    print("{num_failures} pages had load errors. Page numbers and error messages have been documented in the artworks_api_errors table.")
    try:
        failed_pages.to_sql('artworks_api_errors', con=engine, if_exists='append', chunksize=1000, index=False)
    except Exception as e:
        print("Error loading errors to SQL: ", e)
        print(failed_pages)