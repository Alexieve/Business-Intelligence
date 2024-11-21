USE master
GO

IF DB_ID('AirPollution_NDS') IS NOT NULL
	DROP DATABASE AirPollution_NDS;
GO


CREATE DATABASE AirPollution_NDS
GO

USE AirPollution_NDS
GO

CREATE TABLE Source_DB(
	sor_sk int IDENTITY(1,1),
	sor_name VARCHAR(50),
	CONSTRAINT PK_Source_DB PRIMARY KEY CLUSTERED (sor_sk)
);

CREATE TABLE State_NDS(
	state_SK int IDENTITY(1,1),
	source_id int NOT NULL,
	state_code_NK int NOT NULL,
	state_id varchar(5) NOT NULL,
	state_name varchar(50) NOT NULL,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL,
	CONSTRAINT PK_State_NDS PRIMARY KEY CLUSTERED (state_SK),
	CONSTRAINT FK_State_NDS__Source_DB FOREIGN KEY (source_id) 
		REFERENCES Source_DB(sor_sk),
	CONSTRAINT U_State_NDS_1 UNIQUE(source_id, state_code_NK)
);

CREATE TABLE County_NDS(
	county_SK int IDENTITY(1,1),
	source_id int NOT NULL,
	state_SK int NOT NULL,
	county_fips_NK varchar(5) NULL,
	county_code int NOT NULL,
	county_full varchar(50) NOT NULL,
	county_name varchar(50) NOT NULL,
	county_ascii varchar(50) NOT NULL,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL,
	CONSTRAINT PK_County_NDS PRIMARY KEY CLUSTERED (county_SK),
	CONSTRAINT FK_County_NDS__Source_DB FOREIGN KEY (source_id) 
		REFERENCES Source_DB(sor_sk),
	CONSTRAINT FK_County_NDS__State_NDS FOREIGN KEY (state_SK) 
		REFERENCES State_NDS(state_SK),
	CONSTRAINT U_County_NDS_1 UNIQUE(source_id, county_fips_NK),
	CONSTRAINT U_County_NDS_2 UNIQUE(source_id, state_SK, county_code)
);


CREATE TABLE AQI_Category_NDS(
	category_SK int IDENTITY(1,1),
	category_name varchar(50) NOT NULL,
	aqi_min_value int NOT NULL,
	aqi_max_value int NOT NULL,
	description varchar(255) NOT NULL,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL,
	CONSTRAINT PK_AQI_Category_NDS PRIMARY KEY CLUSTERED (category_SK)
);

CREATE TABLE Monitor_NDS(
	monitor_SK int IDENTITY(1, 1),
	source_id int NOT NULL,
	date date NOT NULL,
	county_SK int NOT NULL,
	site_code int NOT NULL,
	defining_parameter varchar(50) NOT NULL,
	aqi int NOT NULL,
	category_SK int NOT NULL,
	number_of_sites_reporting int NOT NULL,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL,
	CONSTRAINT PK_Monitor_NDS PRIMARY KEY CLUSTERED(monitor_SK),
	CONSTRAINT FK_Monitor_NDS__Source_DB FOREIGN KEY (source_id) 
		REFERENCES Source_DB(sor_sk),
	CONSTRAINT FK_Monitor_NDS__County_NDS FOREIGN KEY (county_SK) 
		REFERENCES County_NDS(county_SK),
	CONSTRAINT FK_Monitor_NDS__AQI_Category_NDS FOREIGN KEY (category_SK) 
		REFERENCES AQI_Category_NDS(category_SK),
	CONSTRAINT U_Monitor_NDS_1 UNIQUE(source_id, date, county_SK, site_code)
);



-- Insert DEFAULT Source_DB
INSERT INTO Source_DB (sor_name) VALUES('Default');

-- Insert into AQI_Category_NDS
INSERT INTO AQI_Category_NDS VALUES('Good', 0, 50, 'Air quality is satisfactory, and air pollution poses little or no risk.', GETDATE(), GETDATE())
INSERT INTO AQI_Category_NDS VALUES('Moderate', 51, 100, 'Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.', GETDATE(), GETDATE())
INSERT INTO AQI_Category_NDS VALUES('Unhealthy for Sensitive Groups', 101, 150, 'Members of sensitive groups may experience health effects. The general public is less likely to be affected.', GETDATE(), GETDATE())
INSERT INTO AQI_Category_NDS VALUES('Unhealthy', 151, 200, 'Some memebers of the general public may experience health effects; members of sensitive groups may experience more serious health effects.', GETDATE(), GETDATE())
INSERT INTO AQI_Category_NDS VALUES('Very Unhealthy', 201, 300, 'Health alert: The risk of health effects is increased for everyone.', GETDATE(), GETDATE())
INSERT INTO AQI_Category_NDS VALUES('Hazardous', 301, 999999, 'Health warning of emergency conditions: everyone is more likely to be affected.', GETDATE(), GETDATE())


USE master
