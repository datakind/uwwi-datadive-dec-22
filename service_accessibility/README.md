## Service accessibility EDA
#### Exploration of service accessibility and connecting call volume and call outcome.

- `data/` contains some cleaned data sites relevant to calculating distances from clients to sites
- `findservices/` contains Django project for an interactive web app to find closest 'N' sites to a given address using Google Maps API and site data
	- Need to create .env file with DB credentials and Django secret key
	- To migrate from sqlite db to snowflake, follow https://pythonfusion.com/switch-database-django/
	- Use Django version 3.2 to work with the latest release of the django-snowflake library
	- To access DB from CLI:
		- Run `python manage.py dbshell` in same folder as `manage.py`
		- Wait for DB interface to load, then run query e.g. `SELECT * from CLIENTS LIMIT 1;`
- `scripts/` contains some scripts for cleaning data and some queries for getting data into Snowflake database
- `requirements.txt` lists python packages required for cleaning scripts and Django project




