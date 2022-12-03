import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import geopy
import geopandas
import math

# convert degrees to radians
def degreesToRadians(degrees): 
  return degrees * math.pi / 180

# compute the distance in miles between a pair of (latitude,longitude) coordinates 
def distanceInMilesBetweenEarthCoordinates(lat1, lon1, lat2, lon2):
  earth_radius_miles = 6371 * 0.62137119

  lat_diff = degreesToRadians(lat2-lat1)
  lon_diff = degreesToRadians(lon2-lon1)

  lat1 = degreesToRadians(lat1)
  lat2 = degreesToRadians(lat2)

  a = math.sin(lat_diff/2) * math.sin(lat_diff/2) + \
     math.sin(lon_diff/2) * math.sin(lon_diff/2) * math.cos(lat1) * math.cos(lat2); 
  c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a)); 
  return earth_radius_miles * c


# set path to the data
interactions = "UUWI_Interactions_2020-2022.csv"
agencies = "uwwi_dataset_agencies.csv"
services = "uwwi_dataset_services.csv"
sites = "uwwi_dataset_sites.csv"

# import data into a dataframe
interactions = pd.read_csv(interactions)
sites = pd.read_csv(sites)
print()
print("Sites")
print(sites.head())
print(sites.info())
print()
site_geo_locs = pd.concat([sites['SiteAddressus_SiteAddressus_zip_latitude'],  \
                sites['SiteAddressus_SiteAddressus_zip_longitude'], \
                   sites['Site_Id']], axis=1, ignore_index=True)

site_geo_locs.columns = ['latitude', 'longitude', 'Site_Id']
site_geo_locs.dropna(axis=0, how='any', inplace=True)
print(site_geo_locs.info())
print()

lat1, lon1 = site_geo_locs.iloc[0][:2]
lat2, lon2 = site_geo_locs.iloc[1][:2]

distance = distanceInMilesBetweenEarthCoordinates(lat1,lon1,lat2,lon2)
print(round(distance, 2))






