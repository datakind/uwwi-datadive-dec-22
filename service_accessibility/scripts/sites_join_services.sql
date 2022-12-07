-- Date: Dec 6, 2022
-- Author: Sashka Warner
-- Note: Left join services to sites and create new table
-- Follow https://quickstarts.snowflake.com/guide/getting_started_with_snowsql/index.html?index=..%2F..index#0
-- for other steps

USE DATABASE UWWI;
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE SITE_SERVICES AS (
  SELECT  si_cl.SITE_ID,
          serv.SITE_ID AS JOIN_SITE_ID,
          si_cl.SITE_LAT,
          si_cl.SITE_LONG,
          si_cl.SITE_ADDRESS,
          serv.SERVICE_ID,
          serv.PAYMENTOPTIONS,
          serv.POPULATIONFOCUS,
          serv.LANGUAGESOTHERTHANENGLISHNEW,
          serv.DAYSOPTION,
          serv.MENTALHEALTHCONDITIONS,
          serv.MEDICALCONDITIONS,
          serv.COUNSELINGTYPESOFFERED,
          serv.AGEGROUP,
          serv.THERAPYANDSUPPORTIVEAPPROACHES,
          serv.ISSUEOFFOCUS,
          serv.AODA
  FROM SITES_CLEANED si_cl
  LEFT JOIN SERVICES serv
  ON si_cl.SITE_ID = serv.SITE_ID
);

!exit