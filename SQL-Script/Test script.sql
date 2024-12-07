SELECT * FROM AirPollution_Stage.DBO.uscounties;
SELECT * FROM AirPollution_Stage.DBO.state_aqi;

SELECT * FROM AirPollution_Metadata.DBO.data_quality_rules;
SELECT * FROM AirPollution_Metadata.DBO.data_quality_logs;
SELECT * FROM AirPollution_Metadata.DBO.DATA_FLOW;

SELECT * FROM AirPollution_NDS.DBO.AQI_Category_NDS;
SELECT * FROM AirPollution_NDS.DBO.Parameter_NDS;
SELECT * FROM AirPollution_NDS.DBO.State_NDS;
SELECT * FROM AirPollution_NDS.DBO.County_NDS;
SELECT * FROM AirPollution_NDS.DBO.Monitor_NDS;


SELECT * FROM AirPollution_DDS.DBO.Dim_AQI_Category;
SELECT * FROM AirPollution_DDS.DBO.Dim_Parameter;
SELECT * FROM AirPollution_DDS.DBO.Dim_State;
SELECT * FROM AirPollution_DDS.DBO.Dim_County;
SELECT * FROM AirPollution_DDS.DBO.Fact_AQI_Monitor;