-- Date: Dec 2, 2022
-- Author: Sashka Warner
-- Note: Selected commands to load data to snowflake DB - some commands are not SQL but including here for consistency
-- Follow https://quickstarts.snowflake.com/guide/getting_started_with_snowsql/index.html?index=..%2F..index#0
-- for other steps

USE DATABASE UWWI;

CREATE OR REPLACE TABLE UWWI.STAGING.CLIENTS (
    CLIENT_ID NUMBER(38,0) NOT NULL,
    CLIENT_CREATESTAMP TIMESTAMP_TZ,
    CLIENT_EDITSTAMP TIMESTAMP_TZ,
    CLIENT_ZIPCODE_TRUNC CHAR(5),
	primary key (CLIENT_ID)
);

create or replace warehouse clients_wh with
  warehouse_size='X-SMALL'
  auto_suspend = 180
  auto_resume = true
  initially_suspended=true;

CREATE STAGE client_csv_files;

-- Need to change path below to match what is on your computer
put file://<PATH TO FOLDER>/uwwi_dataset_clients_cleaned.csv @client_csv_files;

LIST @client_csv_files;

copy into UWWI.STAGING.CLIENTS
  from @client_csv_files
  file_format = (type = csv field_optionally_enclosed_by='"')
  pattern = '.*uwwi_dataset_clients_cleaned.csv.gz'
  on_error = 'skip_file';

!exit