""""
Author: Nicole Davila
Date: 2022-05-26
Name: kaggle_api_test.py
Description: This script is an initial attempt at using Kaggle's API
"""

# Import libraries
import requests
import json
import kaggle
import zipfile
import pandas as pd
import os

# Variables
topic = 'wine'
# Get API key
print('Getting API key...\n')
with open('/Users/nicol/PycharmProjects/kaggleApiProject/api_key.txt') as f:
    api_key = f.readlines()

username = json.loads(api_key[0])['username']
key = json.loads(api_key[0])['key']

api = kaggle.api
api.get_config_value("username")

# Get list of datasets
print('Getting list of datasets related to '+topic+'...\n')
datasets = kaggle.api.dataset_list(search=topic)
print(str(len(datasets))+ ' datasets found!\n')
for i in datasets:
    print(i)

#TODO: Save list of wine datasets into database

# Get one dataset
data_to_get = datasets[2]
print('\nGetting "' + str(data_to_get) + '"...')

ds = data_to_get
ds_vars = vars(ds)
for var in ds_vars:
    print(f"{var} = {ds_vars[var]}")

file_result = kaggle.api.dataset_list_files(ds.ref)

# Save data
print('\nSaving data...')
file_name = str(data_to_get).split("/",1)[1]
kaggle.api.dataset_download_files(ds.ref, path="/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality")

# Unzip
with zipfile.ZipFile("/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/{file}.zip".format(
    file=file_name
    ),
        'r') as zip_ref:
    zip_ref.extractall("/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/")

# List files in directory
import os

# Get the list of all files and directories
path = "/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/"
dir_list = os.listdir(path)

# Remove zip file and load the csv into memory
for file in dir_list:
    if '.zip' in file:
        print("Deleting .zip file...")
        os.remove("/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/{file}".format(
        file=file
        ))
    elif '.csv' in file:
        print("Loading .csv...")
        data = pd.read_csv("/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/{file}".format(
        file=file
        ))
    elif '.xlsx' in file:
        print("Loading .xlsx...")
        data = pd.read_excel(file)
    else:
        os.remove("/Users/nicol/PycharmProjects/kaggleApiProject/data/wine_quality/{file}".format(
            file=file
        ))

# Load data into the database
print(data)