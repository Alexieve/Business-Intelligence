USE AirPollution_Stage;
GO


CREATE OR ALTER PROCEDURE sp_data_quality_check
AS
BEGIN
	TRUNCATE TABLE AirPollution_Metadata.dbo.data_quality_logs;

    -- Rule 1: Check if county_fips is a 5-character numeric string
	INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
	SELECT 1, 'uscounties', 'county_fips', ROW_NUMBER() OVER (ORDER BY county_fips), 'county_fips must be a 5-character numeric string'
	FROM uscounties
	WHERE LEN(county_fips) != 5
       OR county_fips LIKE '%[^0-9]%';

    -- Rule 2: Validate date <= created <= last_updated
	INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 2, 'state_aqi', 'date', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'date, created or last_updated is not correct'
    FROM state_aqi
    WHERE NOT ( date <= created AND created <= last_updated );

    -- Rule 3: Validate category based on AQI value
	INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 3, 'state_aqi', 'category', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'Category must be valid based on AQI value'
    FROM state_aqi
	WHERE NOT (
        (aqi BETWEEN 0 AND 50 AND category = 'Good') 
        OR (aqi BETWEEN 51 AND 100 AND category = 'Moderate') 
        OR (aqi BETWEEN 101 AND 150 AND category = 'Unhealthy for Sensitive Groups') 
        OR (aqi BETWEEN 151 AND 200 AND category = 'Unhealthy') 
        OR (aqi BETWEEN 201 AND 300 AND category = 'Very Unhealthy') 
        OR (aqi > 300 AND category = 'Hazardous')
    );

    -- Rule 4: Validate state_name in state_aqi must exist in uscounties
    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 4, 'state_aqi', 'state_name', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'state_name must exist in uscounties'
    FROM state_aqi
	WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
    );

    -- Rule 5: Validate county_name in state_aqi must exist in uscounties for the same state_name
    INSERT INTO AirPollution_Metadata.dbo.data_quality_logs (rule_id, table_name, column_name, row_id, error_msg)
    SELECT 5, 'state_aqi', 'county_name', ROW_NUMBER() OVER (ORDER BY date, defining_site), 'county_name must exist in uscounties for the same state_name'
    FROM state_aqi
	WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE	CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
				AND CAST(RIGHT(uscounties.county_fips, 3) AS INT) = state_aqi.county_code
    );
	
	
    -- Rule 1: Check if county_fips is a 5-character numeric string
    DELETE FROM uscounties
    WHERE LEN(county_fips) != 5
       OR county_fips LIKE '%[^0-9]%';

    -- Rule 2: Validate date <= created <= last_updated
    DELETE FROM state_aqi
    WHERE NOT ( date <= created AND created <= last_updated );

    -- Rule 3: Validate category based on AQI value
    DELETE FROM state_aqi
    WHERE NOT (
        (aqi BETWEEN 0 AND 50 AND category = 'Good') 
        OR (aqi BETWEEN 51 AND 100 AND category = 'Moderate') 
        OR (aqi BETWEEN 101 AND 150 AND category = 'Unhealthy for Sensitive Groups') 
        OR (aqi BETWEEN 151 AND 200 AND category = 'Unhealthy') 
        OR (aqi BETWEEN 201 AND 300 AND category = 'Very Unhealthy') 
        OR (aqi > 300 AND category = 'Hazardous')
    );

    -- Rule 4: Validate state_name in state_aqi must exist in uscountieS
	DELETE FROM state_aqi
	WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
    );

    -- Rule 5: Validate county_name in state_aqi must exist in uscounties for the same state_name
	DELETE FROM state_aqi
    WHERE NOT EXISTS (
        SELECT 1 FROM uscounties 
		WHERE	CAST(LEFT(uscounties.county_fips, 2) AS INT) = state_aqi.state_code
				AND CAST(RIGHT(uscounties.county_fips, 3) AS INT) = state_aqi.county_code
    );
END;
GO
