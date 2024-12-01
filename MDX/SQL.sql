-- MDX 2
select DD.year_number, DD.quarter_number, DS.state_name, AVG(CAST(aqi as float)) as mean_aqi, STDEV(aqi) as std_aqi
from Fact_AQI_Monitor F
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
GROUP BY DD.year_number, DD.quarter_number, DS.state_name

-- MDX 3
SELECT DS.state_name, DC.county_name, COUNT(*) day_numbers, AVG(CAST(aqi AS FLOAT)) mean_aqi
FROM Fact_AQI_Monitor F
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_State DS ON DC.state_SK = DS.state_SK
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
JOIN Dim_AQI_Category DA ON F.category_SK = DA.category_SK
WHERE F.category_SK > 4
GROUP BY DS.state_name, DC.county_name
ORDER BY DS.state_name, DC.county_name
