-- MDX 2
SELECT 
	DD.year_number, 
	DD.quarter_number, 
	DS.state_name, 
	AVG(CAST(aqi AS FLOAT)) AS mean_aqi, 
	STDEV(aqi) AS std_aqi
FROM Fact_AQI_Monitor F
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
GROUP BY DD.year_number, DD.quarter_number, DS.state_name;

-- MDX 3
SELECT DS.state_name, DC.county_name, COUNT(*) day_numbers, AVG(CAST(aqi AS FLOAT)) mean_aqi
FROM Fact_AQI_Monitor F
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
JOIN Dim_AQI_Category DA ON F.category_SK = DA.category_SK
WHERE F.category_SK > 4
GROUP BY DS.state_name, DC.county_name
ORDER BY DS.state_name, DC.county_name;

-- MDX 5
SELECT DS.state_name, DD.year_number, DD.quarter_number, AVG(fact.aqi) as AVG_AQI FROM Fact_AQI_Monitor Fact
JOIN Dim_Date DD ON DD.date_SK = Fact.date_SK
JOIN Dim_County DC ON DC.county_SK = Fact.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
WHERE DS.state_name IN ('Hawaii', 'Alaska', 'Illinois', 'Delaware')
GROUP BY DS.state_name, DD.year_number, DD.quarter_number

-- MDX 7
SELECT DS.state_name, DD.year_number, DD.month_number, AVG(fact.aqi) as AVG_AQI FROM Fact_AQI_Monitor Fact
JOIN Dim_Date DD ON DD.date_SK = Fact.date_SK
JOIN Dim_County DC ON DC.county_SK = Fact.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
GROUP BY DS.state_name, DD.year_number, DD.month_number

-- MDX 9
SELECT 
	DD.year_number, 
	DD.quarter_number, 
	DS.state_name, 
	DC.county_name,
	AVG(CAST(aqi AS FLOAT)) AS mean_aqi, 
	STDEV(aqi) AS std_aqi,
	MIN(aqi) AS min_aqi,
	MAX(aqi) AS max_aqi
FROM Fact_AQI_Monitor F
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
GROUP BY DD.year_number, DD.quarter_number, DS.state_name, DC.county_name;

-- MDX 11
WITH Fact_AQI_By_State
AS
(
	SELECT 
		F.date_SK,
		DS.state_SK AS state_SK, 
		AVG(F.aqi) AS mean_aqi
	FROM Fact_AQI_Monitor F
	JOIN Dim_County DC ON F.county_SK = DC.county_SK
	JOIN Dim_State DS ON DC.state_SK = DS.state_SK
	JOIN Dim_Date DD ON F.date_SK = DD.date_SK
	JOIN Dim_AQI_Category DAC ON F.category_SK = DAC.category_SK
	GROUP BY 
		F.date_SK,
		DS.state_SK
),
group_by_state_and_category 
AS
(
	SELECT
		date_SK,
		state_SK,
		CASE
			WHEN mean_aqi <= 50 THEN 'Good'
			WHEN mean_aqi <= 100 THEN 'Moderate'
			WHEN mean_aqi <= 150 THEN 'Unhealthy for Sensitive Group'
			WHEN mean_aqi <= 200 THEN 'Unhealthy'
			WHEN mean_aqi <= 300 THEN 'Very Unhealthy'
			ELSE 'Hazardous'
		END AS category_name
	FROM Fact_AQI_By_State
)
SELECT 
	DD.year_number,
	DD.month_number,
	DS.state_name,
	GR.category_name,
	COUNT(*) AS number_of_days
FROM group_by_state_and_category GR
JOIN Dim_State DS ON GR.state_SK = DS.state_SK
JOIN Dim_Date DD ON GR.date_SK = DD.date_SK
GROUP BY 
	DD.year_number,
	DD.month_number,
	DS.state_name,
	GR.category_name
ORDER BY 
	DD.year_number,
	DD.month_number,
	DS.state_name,
	GR.category_name