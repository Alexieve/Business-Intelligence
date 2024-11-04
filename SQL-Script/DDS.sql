USE master
GO

CREATE DATABASE AirPollution_DDS
GO

-- DROP DATABASE AirPollution_DDS

USE AirPollution_DDS
GO
-- DELETE FROM AirPollution_DDS
CREATE TABLE DIM_DATE (
    Date_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, -- Auto-increment and clustered index
    FullDate DATETIME,
    DayOfMonthNumber INT,
    MonthNumber VARCHAR(50),
    MonthName VARCHAR(50),
    QuarterNumber INT,
	QuarterName VARCHAR(50),
	YearNumber INT,
	DayLightSaving BIT
);

CREATE TABLE DIM_SITE (
    site_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, -- Auto-increment and clustered index
    state_code_NK INT,
    county_code_NK INT,
    site_code_NK VARCHAR(50),
    county_name VARCHAR(50),
    state_name VARCHAR(50),
	created_date DATETIME,
	modifed_date DATETIME
);

CREATE TABLE FactAQIReport (
	ReportKey INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	site_SK INT,
	date_SK INT,
	defining_parameter_DD VARCHAR(50),
	AQI INT,
	Category_Name VARCHAR(50),
	created_date DATETIME,
	modifed_date DATETIME
)