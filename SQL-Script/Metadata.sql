USE master
GO

-- CREATE DATABASE
IF DB_ID('AirPollution_Metadata') IS NOT NULL
	DROP DATABASE AirPollution_Metadata;
GO
CREATE DATABASE AirPollution_Metadata
GO

USE AirPollution_Metadata
GO

-- CREATE TABLE
CREATE TABLE DATA_FLOW (
	ID INT NOT NULL IDENTITY(1, 1),
	TABLE_NAME VARCHAR(30) NULL,
	LSET DATETIME NULL,
	CET DATETIME NULL,
	CONSTRAINT PK_DATA_FLOW PRIMARY KEY CLUSTERED (ID)
)
GO

CREATE TABLE data_quality_rules (
    rule_id INT IDENTITY(1, 1) PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,         
    column_name VARCHAR(1024),                 
    rule_description NVARCHAR(1024),                    
    severity VARCHAR(10) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH')),  
    is_active BIT DEFAULT 1,                
    created_date DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE data_quality_logs (
    log_id INT IDENTITY(1, 1) PRIMARY KEY,
    rule_id INT FOREIGN KEY REFERENCES data_quality_rules(rule_id) ON DELETE SET NULL,
    table_name NVARCHAR(100),
    column_name NVARCHAR(1024),    
	row_id INT,
    error_msg NVARCHAR(1024),
    log_timestamp DATETIME DEFAULT GETDATE()
);

-- INSERT INTO DATA_FLOW
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('uscounties', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('state_aqi', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Dim_County', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
INSERT INTO DATA_FLOW (TABLE_NAME, LSET, CET) VALUES ('Fact_AQI_Monitor', '2020-01-01 00:00:00.000', '2020-01-01 00:00:00.000');
GO

-- INSERT INTO data_quality_rules 
INSERT INTO data_quality_rules (table_name, column_name, rule_description, severity)
VALUES 
-- Rule 1: county_fips must be a 5-character numeric string
('uscounties', 'county_fips', 'county_fips must be a 5-character numeric string', 'MEDIUM'),

-- Rule 2: Validate date <= created <= last_updated
('state_aqi', 'date, created, last_updated', 'date, created or last_updated is not correct', 'LOW'),

-- Rule 3: Validate category based on AQI value
('state_aqi', 'category', 'category must be valid based on AQI value', 'HIGH'),

-- Rule 4: Check for existence of state in state_aqi with uscounties
('state_aqi', 'state_code', 'state_name in state_aqi must exist in uscounties', 'HIGH'),

-- Rule 5: Check for existence of county in state_aqi with uscounties
 ('state_aqi', 'state_code, county_code', 'county_name in state_aqi must exist in uscounties for the same state_name', 'HIGH');



use master