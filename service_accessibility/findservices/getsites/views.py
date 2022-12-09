import os
import requests
from json import load, dumps
import time
import folium
from folium.plugins import MarkerCluster, Search
from pyrosm import OSM, get_data
import pandas as pd
import geopandas as gpd
from itertools import tee
from dotenv import load_dotenv
from shapely.geometry import Point
from sklearn.neighbors import BallTree
import numpy as np
import mapclassify as mc
import networkx as nx
import igraph as ig
import osmnx as ox
import matplotlib.pyplot as plt
#%matplotlib inline

from django.shortcuts import render

# Create your views here.

def show_map(request):
    sites = {}
    template = "getsites/index.html"
    
    # Load site data
    # TODO: Do this only once on app start up
    # TODO: Remove sites outside wisconsin
    module_dir = os.path.dirname(__file__)  # get current directory
    file_path = os.path.join(module_dir, 'data/sites.json')
    with open(file_path) as f:
        sites = load(f)
    
    sites_json = dumps(sites)
    context = {"sites": sites_json}

    return render(request, template, context)


# NOT USED
"""def create_map():
    # Creating the map centered at Wisconsin state
    m = folium.Map(location=[44.808444, -89.673194], 
                tiles="cartodbpositron", 
                zoom_start=6.8)

    #Create feature group so we can toggle data visibility
    fg = folium.FeatureGroup(name="Sites", show=False)
    #m.add_child(fg)
    #marker_cluster = MarkerCluster().add_to(fg)
    addresses = []
    search_bar = Search(
        layer=addresses,
        geom_type="Point",
        placeholder="Search for a Wisconsin address",
        collapsed=False,
        search_label="name",
        weight=3,
    ).add_to(m)

    # Create a geometry list from the GeoDataFrame
    #site_points = [[point.xy[1][0], point.xy[0][0]] for point in sites_gdf.loc[0:100,"geometry"]] # Note: Doesn't work with projected CRS (Folium leaflet need EPSG:4326)

    # Note that Folium wants data in <Lat, Long> format
    #n = sites_gdf.shape[0]
    #for i in range(n-1):
    #    coords = (sites_gdf.loc[i, "site_lat"], sites_gdf.loc[i, "site_long"])
    #    folium.Marker(
    #        location= coords,
    #        popup="Coordinates: " + str(coords),
    #        control=True,
    #    ).add_to(marker_cluster)

    folium.LayerControl().add_to(m)

    # Render html
    m = m._repr_html_()

    return m
"""