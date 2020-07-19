CREATE PROCEDURE my_proc
as
begin
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'date_dimension'))
   BEGIN
		DECLARE @StartDate DATETIME
		set @StartDate =  (SELECT TOP 1 Date1 FROM date_dimension ORDER BY Date DESC)
		declare @start1 DATETIME = convert(date, @StartDate)
		declare @end1 DATETIME = convert(date, @StartDate+365)

		CREATE TABLE [dbo].[my_table]([Date] date primary key,[Year] CHAR(4),[Week] VARCHAR(30) ,[DayName] VARCHAR(9),[DayNum] char(1),[DayName_short] varchar(9),
						[Quarter] CHAR(1),[FiscalYear] CHAR(4), [FiscalPeriod] varchar(3),DAY_MONTH VARChaR(2),WEEK_YEAR VARChar(3) )
				WHILE @start1 <= @end1
					BEGIN
						INSERT INTO [dbo].[my_table]
							SELECT
								CONVERT (date, @start1) AS Date1,  DATEPART(YYYY, @start1) AS Year,
								DATEPART(WW, @start1) AS Week,    DATENAME(DW, @start1) AS DayName,
								DATEPART(DW, @start1) AS DayNumb, CAST(DATENAME(DW, @start1) AS CHAR(3)) AS DayName_short,
								DATEPART(QQ, @start1) AS Quarter,
								CASE 
									WHEN DATEPART(MM,@start1)>3
									THEN DATEPART(YYYY,@start1)
									ELSE DATEPART(YYYY,@start1)+1
									END AS FiscalYear,
								DATEPART(MM, @start1) AS FiscalPeriod,
								DATEPART(DD , @start1) AS DAY_MONTH,
								DATEPART(WW, @start1) AS WEEK_YEAR
							SET	@start1 = DATEADD(DD, 1, @start1)
					END

						INSERT INTO [dbo].[date_dimension] SELECT * from [dbo].[my_table]  WHERE my_table.Date NOT IN (SELECT Date FROM [dbo].[date_dimension])

					drop table [dbo].[my_table]
	END
ELSE
	BEGIN
	DECLARE @StartDate DATETIME = CONVERT (date, GETDATE())
	DECLARE @EndDate DATETIME = CONVERT (date, GETDATE()+365)
		CREATE TABLE [dbo].[date_dimension]
			(	[Date1] date primary key,[Year] CHAR(4),[Week] VARCHAR(30) ,[DayName] VARCHAR(9),[DayNum] char(1),[DayName_short] varchar(9),
				[Quarter] CHAR(1),[FiscalYear] CHAR(4), [FiscalPeriod] varchar(3),DAY_MONTH VARChaR(2),WEEK_YEAR VARChar(3)	)
		--if @last_value = @StartDate
		WHILE @StartDate <= @EndDate
		BEGIN
			INSERT INTO [dbo].[date_dimension]
				SELECT
					CONVERT (date, @StartDate) AS Date1,  DATEPART(YYYY, @StartDate) AS Year,
					DATEPART(WW, @StartDate) AS Week,    DATENAME(DW, @StartDate) AS DayName,
					DATEPART(DW, @StartDate) AS DayNumb, CAST(DATENAME(DW, @StartDate) AS CHAR(3)) AS DayName_short,
					DATEPART(QQ, @StartDate) AS Quarter,
					CASE 
						WHEN DATEPART(MM,@StartDate)>3
						THEN DATEPART(YYYY,@StartDate)
						ELSE DATEPART(YYYY,@StartDate)+1
						END AS FiscalYear,
					DATEPART(MM, @StartDate) AS FiscalPeriod,
					DATEPART(DD , @StartDate) AS DAY_MONTH,
					DATEPART(WW, @StartDate) AS WEEK_YEAR
				SET @StartDate = DATEADD(DD, 1, @StartDate)
		END
	END
select * from date_dimension
end
