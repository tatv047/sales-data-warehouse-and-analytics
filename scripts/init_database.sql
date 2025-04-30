/*
============================================================================
Creata Database and Schemas
============================================================================

Script Purpose:
	This script creates a new database named 'DataWarehouse' after chekcing if it already exists.
	If the database exists,it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze','silver' and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it already exists.
	All data in the database will be permanently deleted. Process with caution and ensure that 
	you have proper backups before running the script.

*/



USE master;
GO

--Drop and recreate the "DataWarehouse" database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse') 
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO


USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

