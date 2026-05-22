--CREATE DATABASE AND SCHEMA--

/* =====================================================================================
SCRIPTS PURPOSE: THE SCRIPSTS CREATE A DATABASE "SQL-WAREHOUSE" 
AND THE SCRIPTS SET UP THREE SCHEMAS WITHIN DATABASE,1.BRONEZE,2.SILVER,3.GOLD
=========================================================================================*/

--CREATE Database "SQL-WAREHOUSE"--
CREATE DATABASE sql-warehouse

-------CREATE SCHEMA ------
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
