CREATE OR ALTER VIEW V_Data_Mining AS
SELECT 
    DD.full_date, 
    DC.county_name,
    F.site_code_DD,
    DP.parameter_name,
    DAC.category_name,
    F.aqi
FROM Fact_AQI_Monitor F
JOIN Dim_Date DD ON F.date_SK = DD.date_SK
JOIN Dim_County DC ON F.county_SK = DC.county_SK
JOIN Dim_Parameter DP ON F.parameter_SK = DP.parameter_SK
JOIN Dim_AQI_Category DAC ON F.category_SK = DAC.category_SK;