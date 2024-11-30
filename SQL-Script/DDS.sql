USE master
GO

IF DB_ID('AirPollution_DDS') IS NOT NULL
	DROP DATABASE AirPollution_DDS;
GO

CREATE DATABASE AirPollution_DDS
GO

USE AirPollution_DDS
GO

 

CREATE TABLE Dim_Date (
	 date_SK                      INT          NOT NULL, 
	 full_date                    DATE     NOT NULL,
	 year_number				  INT          NOT NULL,
	 quarter_number				  TINYINT      NOT NULL,
	 quarter_name				  VARCHAR (6)  NOT NULL,
	 month_number				  TINYINT      NOT NULL,
	 month_name					  VARCHAR (9)  NOT NULL,
	 day_number                   TINYINT      NOT NULL,
	 day_light_saving             BIT          NULL,
	 CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED (date_SK ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE Dim_State (
    state_SK INT PRIMARY KEY CLUSTERED,
    state_code_NK INT,
	source_id INT,
	state_id VARCHAR(5),
    state_name VARCHAR(50),
	status BIT,
	created_date datetime2(7),
	last_updated datetime2(7)
);

CREATE TABLE Dim_County (
    county_SK INT PRIMARY KEY CLUSTERED,
    state_SK INT,
	source_id INT,
    county_code INT,
	county_name VARCHAR(50),
	status BIT,
	created_date datetime2(7),
	last_updated datetime2(7),
	CONSTRAINT FK__Dim_County__Dim_State FOREIGN KEY (state_SK) 
		REFERENCES Dim_State(state_SK),
);

CREATE TABLE Dim_Parameter(
	parameter_SK INT PRIMARY KEY CLUSTERED,
	parameter_name varchar(50) NOT NULL,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL
);

CREATE TABLE Dim_AQI_Category (
	category_SK INT PRIMARY KEY CLUSTERED,
	category_name varchar(50) NOT NULL,
	aqi_min_value int NOT NULL,
	aqi_max_value int NOT NULL,
	description varchar(255) NOT NULL,
	status BIT,
	created_date datetime2(7) NOT NULL,
	last_updated datetime2(7) NOT NULL
);

CREATE TABLE Fact_AQI_Monitor (
	monitor_SK INT PRIMARY KEY CLUSTERED,
	date_SK INT,
	county_SK INT, 
	site_code_DD INT,
	parameter_SK INT,
	aqi INT,
	category_SK INT,
	number_of_sites_reporting INT,
	created_date datetime2(7),
	last_updated datetime2(7),
	CONSTRAINT FK_Fact_AQI_Monitor__Dim_Date FOREIGN KEY (date_SK) 
		REFERENCES Dim_Date(date_SK),
	CONSTRAINT FK_Fact_AQI_Monitor__Dim_County FOREIGN KEY (county_SK) 
		REFERENCES Dim_County(county_SK),
	CONSTRAINT FK_Fact_AQI_Monitor__Dim_Parameter FOREIGN KEY (parameter_SK) 
		REFERENCES Dim_Parameter(parameter_SK),
	CONSTRAINT FK_Fact_AQI_Monitor__Dim_Category FOREIGN KEY (category_SK) 
		REFERENCES Dim_AQI_Category(category_SK)
)

 
DECLARE @tmpDOW TABLE (DOW  INT, Cntr INT); --Table for counting DOW occurance in a month
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (1, 0); --Used in the loop below
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (2, 0);
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (3, 0);
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (4, 0);
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (5, 0);
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (6, 0);
INSERT INTO @tmpDOW (DOW, Cntr) VALUES (7, 0);

 

DECLARE @StartDate AS DATETIME,
		@EndDate AS DATETIME,
		@Date AS DATETIME,
		@WDofMonth AS INT,
		@CurrentMonth AS INT,
		@CurrentDate AS DATE = getdate();
			
 

SELECT  @StartDate = '2021-01-01', -- Set The start and end date
		@EndDate = '2024-01-01', --Non inclusive. Stops on the day before this.
		@Date = @StartDate,
		@CurrentMonth = DATEPART(MONTH, @StartDate);

 

WHILE @Date < @EndDate
BEGIN
	INSERT INTO Dim_Date (date_SK, full_date, year_number, quarter_number, quarter_name, month_number, month_name, day_number, day_light_saving)
	SELECT CONVERT (VARCHAR, @Date, 112) AS date_SK,
	@Date AS full_date,
	DATEPART(YEAR, @Date) AS year_number,
	DATEPART(qq, @DATE) AS quarter_number,
	CASE DATEPART(qq, @DATE)
		WHEN 1 THEN 'First'
		WHEN 2 THEN 'Second'
		WHEN 3 THEN 'Third'
		WHEN 4 THEN 'Fourth'
	END AS quarter_name,
	DATEPART(MONTH, @DATE) AS month_number, 
	DATENAME(MONTH, @DATE) AS month_name,
	DATEPART(DAY, @DATE) AS day_number,
	CASE 
		WHEN @Date BETWEEN '2023-03-12' AND '2023-11-05' THEN 1  -- day_light_saving is True
		ELSE 0  -- day_light_saving is False
    END AS day_light_saving;

	SET @Date = DATEADD(DAY, 1, @Date);
END



GO
PRINT CONVERT (VARCHAR, GETDATE(), 113); --USED FOR CHECKING RUN TIME.

 

--DimDate indexes——————————————————————————————E
CREATE UNIQUE NONCLUSTERED INDEX [IDX_DimDate_Date]
ON Dim_Date(full_date ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_Day]
ON Dim_Date(day_number ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_Month]
ON Dim_Date(month_number ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_MonthName]
ON Dim_Date(month_name ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_Quarter]
ON Dim_Date(quarter_number ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_QuarterName]
ON Dim_Date(quarter_name ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

CREATE NONCLUSTERED INDEX [IDX_DimDate_Year]
ON Dim_Date(year_number ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)
ON [PRIMARY];

 

PRINT CONVERT (VARCHAR, getdate(), 113); --USED FOR CHECKING RUN TIME


USE master
