-- Date: Dec 6, 2022
-- Author: Sashka Warner
-- Note: Selected commands to load data to snowflake DB - some commands are not SQL but including here for consistency
-- Follow https://quickstarts.snowflake.com/guide/getting_started_with_snowsql/index.html?index=..%2F..index#0
-- for other steps

USE DATABASE UWWI;

CREATE OR REPLACE TABLE UWWI.STAGING.SITES_CLEANED (
    AGENCY_SYSTEMNAME VARCHAR(255),
    SITE_SYSTEMNAME VARCHAR(255),
    AGENCY_ID NUMBER(38,0),
    SITE_ID NUMBER(38,0) NOT NULL,
    SITE_AGENCY_ID NUMBER(38,0),
    SITE_STATUS VARCHAR(255),
    SITE_LAT FLOAT,
    SITE_LONG FLOAT,
    SITE_ZIP_LAT FLOAT,
    SITE_ZIP_LONG FLOAT,
    SITE_ADDRESS VARCHAR(255),
	primary key (SITE_ID)
);

--create or replace warehouse sites_wh with
--  warehouse_size='X-SMALL'
--  auto_suspend = 180
--  auto_resume = true
--  initially_suspended=true;

USE WAREHOUSE clients_wh;

CREATE STAGE site_csv_files;

-- Need to change path below to match what is on your computer
put file://<PATH TO FOLDER>/uwwi_dataset_sites_cleaned.csv @site_csv_files;

LIST @site_csv_files;

copy into UWWI.STAGING.SITES_CLEANED
  from @site_csv_files
  file_format = (type = csv field_optionally_enclosed_by='"')
  pattern = '.*uwwi_dataset_sites_cleaned.csv.gz'
  on_error = 'skip_file';

!exit