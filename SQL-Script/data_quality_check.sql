USE AirPollution_Stage;
GO


CREATE OR ALTER PROCEDURE sp_data_quality_check
AS
BEGIN
    -- Temporary tables to capture deleted rows for logging
    CREATE TABLE #Deleted_uscounties (
        county_fips VARCHAR(5),
        county VARCHAR(255),
        county_ascii VARCHAR(255),
        county_full VARCHAR(255),
        state_id VARCHAR(2),
        state_name VARCHAR(255),
        lat DECIMAL(9, 6),
        lng DECIMAL(9, 6),
        population INT
    );

    CREATE TABLE #Deleted_state_aqi (
        date DATE,
        defining_site VARCHAR(255),
        defining_parameter VARCHAR(255),
        state_code VARCHAR(2),
        state_name VARCHAR(255),
        county_code VARCHAR(3),
        county_name VARCHAR(255),
        aqi INT,
        category VARCHAR(50),
        number_of_sites_reporting INT,
        created DATETIME2,
        last_updated DATETIME2
    );

    -- Rule 1.1: Check for NULL values in uscounties table
    DELETE FROM uscounties
    OUTPUT deleted.county_fips, deleted.county, deleted.county_ascii, deleted.county_full, deleted.state_id,
           deleted.state_name, deleted.lat, deleted.lng, deleted.population INTO #Deleted_uscounties
    WHERE county_fips IS NULL
       OR county IS NULL
       OR county_ascii IS NULL
       OR county_full IS NULL
       OR state_id IS NULL
       OR state_name IS NULL
       OR lat IS NULL
       OR lng IS NULL
       OR population IS NULL;

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT	1, 
			'uscounties', 
			'county_fips, county, county_ascii, county_full, state_id, state_name, lat, lng, population',
			ROW_NUMBER() OVER (ORDER BY county_fips), 
			'All columns must not be NULL'
    FROM #Deleted_uscounties;

	TRUNCATE TABLE #Deleted_uscounties;

    -- Rule 1.2: Check if county_fips is a 5-character numeric string
    DELETE FROM uscounties
    OUTPUT deleted.county_fips, deleted.county, deleted.county_ascii, deleted.county_full, deleted.state_id,
           deleted.state_name, deleted.lat, deleted.lng, deleted.population INTO #Deleted_uscounties
    WHERE LEN(county_fips) != 5
       OR county_fips LIKE '%[^0-9]%';

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 2, 'uscounties', 'county_fips', ROW_NUMBER() OVER (ORDER BY county_fips), 'county_fips must be a 5-character numeric string'
    FROM #Deleted_uscounties;

	TRUNCATE TABLE #Deleted_uscounties;

    -- Rule 2.1: Check for NULL values in state_aqi table
    DELETE FROM state_aqi
    OUTPUT deleted.date, deleted.defining_site, deleted.defining_parameter, deleted.state_code, deleted.state_name,
           deleted.county_code, deleted.county_name, deleted.aqi, deleted.category, deleted.number_of_sites_reporting,
           deleted.created, deleted.last_updated INTO #Deleted_state_aqi
    WHERE date IS NULL
       OR defining_site IS NULL
       OR defining_parameter IS NULL
       OR state_code IS NULL
       OR state_name IS NULL
       OR county_code IS NULL
       OR county_name IS NULL
       OR aqi IS NULL
       OR category IS NULL
       OR number_of_sites_reporting IS NULL
       OR created IS NULL
       OR last_updated IS NULL;

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 4, 'state_aqi', 'date, defining_site, defining_parameter, state_code, state_name, county_code, county_name, aqi, category, number_of_sites_reporting, created, last_updated',
           ROW_NUMBER() OVER (ORDER BY date, defining_site), 'All columns must not be NULL'
    FROM #Deleted_state_aqi;

	TRUNCATE TABLE #Deleted_state_aqi;

    -- Rule 2.2: Validate date, created, and last_updated formats
    DELETE FROM state_aqi
    OUTPUT deleted.date, deleted.defining_site, deleted.defining_parameter, deleted.state_code, deleted.state_name,
           deleted.county_code, deleted.county_name, deleted.aqi, deleted.category, deleted.number_of_sites_reporting,
           deleted.created, deleted.last_updated INTO #Deleted_state_aqi
    WHERE TRY_CAST(date AS DATE) IS NULL
       OR TRY_CAST(created AS DATETIME2) IS NULL
       OR TRY_CAST(last_updated AS DATETIME2) IS NULL;

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 5, 'state_aqi', 'date', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'Invalid date format'
    FROM #Deleted_state_aqi
    WHERE TRY_CAST(date AS DATE) IS NULL;

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 6, 'state_aqi', 'created', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'Invalid datetime format for created'
    FROM #Deleted_state_aqi
    WHERE TRY_CAST(created AS DATETIME2) IS NULL;

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 7, 'state_aqi', 'last_updated', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'Invalid datetime format for last_updated'
    FROM #Deleted_state_aqi
    WHERE TRY_CAST(last_updated AS DATETIME2) IS NULL;

	TRUNCATE TABLE #Deleted_state_aqi;

    -- Rule 2.3: Validate category based on AQI value
    DELETE FROM state_aqi
    OUTPUT deleted.date, deleted.defining_site, deleted.defining_parameter, deleted.state_code, deleted.state_name,
           deleted.county_code, deleted.county_name, deleted.aqi, deleted.category, deleted.number_of_sites_reporting,
           deleted.created, deleted.last_updated INTO #Deleted_state_aqi
    WHERE NOT (
        (aqi BETWEEN 0 AND 50 AND category = 'Good') 
        OR (aqi BETWEEN 51 AND 100 AND category = 'Moderate') 
        OR (aqi BETWEEN 101 AND 150 AND category = 'Unhealthy for Sensitive Groups') 
        OR (aqi BETWEEN 151 AND 200 AND category = 'Unhealthy') 
        OR (aqi BETWEEN 201 AND 300 AND category = 'Very Unhealthy') 
        OR (aqi > 300 AND category = 'Hazardous')
    );

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 8, 'state_aqi', 'category', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'Invalid category based on AQI value'
    FROM #Deleted_state_aqi;

	TRUNCATE TABLE #Deleted_state_aqi;

    -- Rule 2.4: Validate state_name in state_aqi must exist in uscounties
    DELETE FROM state_aqi
    OUTPUT deleted.date, deleted.defining_site, deleted.defining_parameter, deleted.state_code, deleted.state_name,
           deleted.county_code, deleted.county_name, deleted.aqi, deleted.category, deleted.number_of_sites_reporting,
           deleted.created, deleted.last_updated INTO #Deleted_state_aqi
    WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
    );

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 9, 'state_aqi', 'state_name', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'state_name must exist in uscounties'
    FROM #Deleted_state_aqi;

	TRUNCATE TABLE #Deleted_state_aqi;

    -- Rule 2.5: Validate county_name in state_aqi must exist in uscounties for the same state_name
    DELETE FROM state_aqi
    OUTPUT deleted.date, deleted.defining_site, deleted.defining_parameter, deleted.state_code, deleted.state_name,
           deleted.county_code, deleted.county_name, deleted.aqi, deleted.category, deleted.number_of_sites_reporting,
           deleted.created, deleted.last_updated INTO #Deleted_state_aqi
    WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE	CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
				AND CAST(RIGHT(uscounties.county_fips, 3) AS INT) = state_aqi.county_code
    );

    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 10, 'state_aqi', 'county_name', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'county_name must exist in uscounties for the same state_name'
    FROM #Deleted_state_aqi;

	TRUNCATE TABLE #Deleted_state_aqi;

    -- Cleanup temporary tables
    DROP TABLE #Deleted_uscounties;
    DROP TABLE #Deleted_state_aqi;
END;
GO
