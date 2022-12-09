-- Date: Dec 6, 2022
-- Author: Sashka Warner
-- Note: Selected commands to load data to snowflake DB - some commands are not SQL but including here for consistency
-- Follow https://quickstarts.snowflake.com/guide/getting_started_with_snowsql/index.html?index=..%2F..index#0
-- for other steps

USE DATABASE UWWI;

CREATE OR REPLACE TABLE UWWI.STAGING.SERVICES (
  SERVICE_ID NUMBER(38,0) NOT NULL,
  SITE_ID NUMBER(38,0),
  PAYMENTOPTIONS NUMBER(38,0),
  POPULATIONFOCUS NUMBER(38,0),
  LANGUAGESOTHERTHANENGLISHNEW NUMBER(38,0),
  DAYSOPTION NUMBER(38,0),
  MENTALHEALTHCONDITIONS NUMBER(38,0),
  MEDICALCONDITIONS NUMBER(38,0),
  COUNSELINGTYPESOFFERED NUMBER(38,0),
  AGEGROUP NUMBER(38,0),
  THERAPYANDSUPPORTIVEAPPROACHES NUMBER(38,0),
  ISSUEOFFOCUS NUMBER(38,0),
  AODA NUMBER(38,0),
	primary key (SERVICE_ID)
);

--create or replace warehouse services_wh with
--  warehouse_size='X-SMALL'
--  auto_suspend = 180
--  auto_resume = true
--  initially_suspended=true;

USE WAREHOUSE clients_wh;

CREATE STAGE service_csv_files;

-- Need to change path below to match what is on your computer
put file://<PATH TO FOLDER>/uwwi_dataset_services_cleaned.csv @service_csv_files;

LIST @service_csv_files;

copy into UWWI.STAGING.SERVICES
  from @service_csv_files
  file_format = (type = csv field_optionally_enclosed_by='"')
  pattern = '.*uwwi_dataset_services_cleaned.csv.gz'
  on_error = 'skip_file';

!exit