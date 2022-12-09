# UWWi_DataDive_Dec22

#### In this datadive the team focused on 4 workstreams:
- Clients:
   - Understanding the clientele of UWW through EDA 
   - Understanding the relationship between clients' primary and secondary needs
   - Creating possible peronas/archetypes through clustering and customer segmentation
- Call Centers:
   - Mapping out hours of operations
   - Visualizing call volume based on hours of the day/day of the week etc
   - Modeling and predicting call volumne based on historic trends, news headlines, tweets, etc.
- Identifying "Cold Spots" (areas of high need and few help centers)
   - Visualizing the distribution of help centers based on the services they provide
   - Mapping out the distances between the call centers and the clients 
   - Creating visuals of general cold spots (i.e. in general there are few services in the area) and thematic cold spots (e.g. in this area we lack shelters)
- Making it easier for clients to find services they require 
   - Building out a web application that maps services near by based on the address entered
   - At a later time, once we learn more about the clientele and their secondary needs the web app can become 'smarter'  

#### Folder Structure
Due to the nature of the DataDive Event, there are many folders containing independent work that is connected by the workstream for which it was completed. Below we give a brief run through of the folders in this repository
- `Cold zone identification/` contains the two Jupyter notebooks that create a distribution map of centers (both generic and thematic). There is also a "generic" cold spots map created. Creating a cold spots map based on theme should not be an issue once the two pieces of work are combined. The key question is how to define a "cold spot". We used the Area Deprivation Index in our calculations but are open to other definitions/possibilities. 
- `PowerBI Visualizations/` contains two PowerBI files. One shows a map with each individual location mapped. Another PowerBI file visualizes the interactions data based  on caller's need. The table that showcases the relationship between the primary and the secondary need has been redone in Python to create a visual representation.
- `building_client_persona/` contains a cleanning notebook that maps misrepresented counties to proper ones as well as EDA on the client data in terms of age, demographics, ADI etc.
- `clustering/` first strides in client data EDA
- `docs/` contains some html files with the output of time series modeling efforts for predicting call center volume. It also includes a visual of tweet volume vs. number of calls coming in.
- `external_datasets/` are the datasets the team sourced during the event. These include:
   - Wisconsin daily weather data
   - Socioeconomic ADI data
   - Google news
   - Twitter extreme event warnings data from readywisconsin 
- `service_accessibility/` contains everything needed to run the webapp 
- `uwwi_datasets/` datasets provided by UWW as well as a few R scripts to clean-up the data and the cleaned files themselves
- `United Way of Wisconsin Primary and ` contains some scripts for cleaning data and some queries for getting data into Snowflake database
- `United_Way_WI.ipynb` - a starter notebook that eventually broke off into other folders and files 
- `United_Way_WI_KW_Analysis.ipynb` - EDA on the interactions data
- `calculate_distance_from_lat_long_corrdinates` calculates the distance between two points in miles
- `volume_modeling.ipynb`time series model of call center volume
