USE master
GO

--DROP DATABASE AirPollution_Stage
--GO

CREATE DATABASE AirPollution_Stage
GO

USE AirPollution_Stage
GO

CREATE TABLE uscounties(
	county_fips varchar(10) NOT NULL,
	county varchar(50) NOT NULL,
	county_ascii varchar(50) NOT NULL,
	county_full varchar(50) NOT NULL,
	state_id varchar(10) NOT NULL,
	state_name varchar(50) NOT NULL,
	lat float NOT NULL,
	lng float NOT NULL,
	population int NOT NULL,
	CONSTRAINT PK_uscounties PRIMARY KEY CLUSTERED (county_fips)
)

CREATE TABLE state_aqi(
	defining_site varchar(50) NOT NULL,
	date date NOT NULL,
	defining_parameter varchar(50) NOT NULL,
	state_code int NOT NULL,
	state_name varchar(50) NOT NULL,
	county_code int NOT NULL,
	county_name varchar(50) NOT NULL,
	aqi int NOT NULL,
	category varchar(50) NOT NULL,
	number_of_sites_reporting int NOT NULL,
	created datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL,
	CONSTRAINT PK_state_aqi PRIMARY KEY	CLUSTERED(defining_site, date, defining_parameter)
 )
