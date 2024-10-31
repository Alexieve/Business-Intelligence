USE master
GO

--IF DB_ID('AirPollution_NDS') IS NOT NULL
--	DROP DATABASE AirPollution_NDS
GO

CREATE DATABASE AirPollution_NDS
GO

USE AirPollution_NDS
GO
-- DELETE FROM State_NDS
CREATE TABLE State_NDS (
    state_code_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, -- Auto-increment and clustered index
    state_code_NK INT,
    state_id VARCHAR(50),
    state_name VARCHAR(50),
    created_date DATETIME,
    modified_date DATETIME
);

CREATE TABLE County_NDS (
    county_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,     -- Auto-increment and clustered index
    state_code_SK INT,                                     
    county_code_NK INT ,
    county_full VARCHAR(50),
    county_name VARCHAR(50),
    county_ascii VARCHAR(50),
    county_fips VARCHAR(10) ,
    created_date DATETIME,
    modified_date DATETIME,
    FOREIGN KEY (state_code_SK) REFERENCES State_NDS(state_code_SK)
);

CREATE TABLE Site_NDS (
    site_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,       -- Auto-increment and clustered index
    county_SK INT,
    site_number INT,
    created_date DATETIME,
    modified_date DATETIME,
    FOREIGN KEY (county_SK) REFERENCES County_NDS(county_SK)
);

CREATE TABLE AQI_Category_NDS (
    category_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,   -- Auto-increment and clustered index
    category_name VARCHAR(50),
    aqi_min_value INT NOT NULL,
    aqi_max_value INT NOT NULL,
    description VARCHAR(255),
    created_date DATETIME,
    modified_date DATETIME
);
Go

Go

CREATE TABLE Monitor_NDS (
    monitor_SK INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,    -- Auto-increment and clustered index
    site_SK INT,
    date DATE,
    defining_parameter VARCHAR(50),
    aqi INT,
    category_SK INT,
    number_of_sites_reporting INT,
    created DATETIME,
    last_updated DATETIME,
    FOREIGN KEY (site_SK) REFERENCES Site_NDS(site_SK),
    FOREIGN KEY (category_SK) REFERENCES AQI_Category_NDS(category_SK)
);
