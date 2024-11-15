USE master
GO

-------------------------------- CREATE DATABASE
IF DB_ID('AirPollution_Metadata') IS NOT NULL
	DROP DATABASE AirPollution_Metadata;
GO
CREATE DATABASE AirPollution_Metadata
GO

USE AirPollution_Metadata
GO

-------------------------------- CREATE TABLE
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
    table_name VARCHAR(100) NOT NULL,         -- Table this rule applies to
    column_name VARCHAR(1024),                 -- Column this rule applies to (NULL if it applies to the entire row)
    rule_description NVARCHAR(1024),                    -- Description of the rule (e.g., "Email must match format")
    rule_expression NVARCHAR(1024),                     -- Expression to be used in SQL (e.g., "email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'")
    severity VARCHAR(10) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH')),  -- Rule severity level
    is_active BIT DEFAULT 1,                  -- Whether the rule is active or not
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

-------------------------------- INSERT INTO DATA_FLOW
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

-------------------------------- INSERT INTO data_quality_rules 
-- Insert Data Quality Rules for uscounties
INSERT INTO data_quality_rules (table_name, column_name, rule_description, rule_expression, severity)
VALUES 
-- Rule 1.1: All columns are not NULL
('uscounties', 'county_fips', 'All columns must not be NULL', 
 'county_fips IS NOT NULL AND county IS NOT NULL AND county_ascii IS NOT NULL AND county_full IS NOT NULL AND state_id IS NOT NULL AND state_name IS NOT NULL AND lat IS NOT NULL AND lng IS NOT NULL AND population IS NOT NULL', 
 'HIGH'),

-- Rule 1.2: county_fips must be a 5-character numeric string
('uscounties', 'county_fips', 'county_fips must be a 5-character numeric string', 
 'LEN(county_fips) = 5 AND county_fips NOT LIKE ''%[^0-9]%''', 
 'MEDIUM'),

-- Rule 1.3: No duplicate records based on county_fips
('uscounties', 'county_fips', 'No duplicate county_fips values', 
 'NOT EXISTS (SELECT county_fips FROM uscounties GROUP BY county_fips HAVING COUNT(*) > 1)', 
 'HIGH');

-- Insert Data Quality Rules for state_aqi
INSERT INTO data_quality_rules (table_name, column_name, rule_description, rule_expression, severity)
VALUES 
-- Rule 2.1: All columns are not NULL
('state_aqi', 'date', 'All columns must not be NULL', 
 'date IS NOT NULL AND defining_site IS NOT NULL AND defining_parameter IS NOT NULL AND state_code IS NOT NULL AND state_name IS NOT NULL AND county_code IS NOT NULL AND county_name IS NOT NULL AND aqi IS NOT NULL AND category IS NOT NULL AND number_of_sites_reporting IS NOT NULL AND created IS NOT NULL AND last_updated IS NOT NULL', 
 'HIGH'),

-- Rule 2.2: Validate date, created, and last_updated formats
('state_aqi', 'date', 'date must have a valid format', 
 'TRY_CAST(date AS DATE) IS NOT NULL', 
 'MEDIUM'),
('state_aqi', 'created', 'created must have a valid datetime2 format', 
 'TRY_CAST(created AS DATETIME2) IS NOT NULL', 
 'MEDIUM'),
('state_aqi', 'last_updated', 'last_updated must have a valid datetime2 format', 
 'TRY_CAST(last_updated AS DATETIME2) IS NOT NULL', 
 'MEDIUM'),

-- Rule 2.3: Validate category based on AQI value
('state_aqi', 'category', 'category must be valid based on AQI value', 
 '((aqi BETWEEN 0 AND 50 AND category = ''Good'') OR (aqi BETWEEN 51 AND 100 AND category = ''Moderate'') OR (aqi BETWEEN 101 AND 150 AND category = ''Unhealthy for Sensitive Groups'') OR (aqi BETWEEN 151 AND 200 AND category = ''Unhealthy'') OR (aqi BETWEEN 201 AND 300 AND category = ''Very Unhealthy'') OR (aqi > 300 AND category = ''Hazardous''))', 
 'HIGH'),

-- Rule 2.4:
('state_aqi', 
 NULL, 
 'state_name in state_aqi must exist in uscounties', 
 'NOT EXISTS (SELECT 1 FROM uscounties WHERE uscounties.state_name = state_aqi.state_name)', 
 'HIGH'),

 -- Rule 2.5
 ('state_aqi', 
 NULL, 
 'county_name in state_aqi must exist in uscounties for the same state_name', 
 'NOT EXISTS (SELECT 1 FROM uscounties WHERE uscounties.state_name = state_aqi.state_name AND uscounties.county = state_aqi.county_name)', 
 'HIGH');



use master