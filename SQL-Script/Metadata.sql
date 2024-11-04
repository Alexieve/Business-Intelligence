USE master
GO

--DROP DATABASE AirPollution_Metadata
--GO

CREATE DATABASE AirPollution_Metadata
GO

USE AirPollution_Metadata
GO

CREATE TABLE DATA_FLOW (
	ID INT NOT NULL IDENTITY(1, 1),
	TABLE_NAME VARCHAR(30) NULL,
	LSET DATETIME NULL,
	CET DATETIME NULL,
	CONSTRAINT PK_DATA_FLOW PRIMARY KEY CLUSTERED (ID)
)
GO

TRUNCATE TABLE DATA_FLOW

INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('uscounties', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('state_aqi', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('State_NDS', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('County_NDS', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Site_NDS', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('AQI_Category_NDS', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Monitor_NDS', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Dim_Site', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Fact_AQI_Monitor', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
GO

use master