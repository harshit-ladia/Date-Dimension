CREATE PROCEDURE my_proc134
as
begin
IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'aADDate1'))
   BEGIn
		DECLARE @StartDate1 DATETIME
		set @StartDate1 =  (SELECT TOP 1 Date1 FROM aADDate1 ORDER BY Date1 DESC)
		declare @start1 DATETIME = convert(date, @StartDate1)
		declare @end1 DATETIME = convert(date, @StartDate1+365)

		CREATE TABLE [dbo].[my_table]([Date1] date primary key,[Year] CHAR(4),[Week] VARCHAR(30) ,[DayName] VARCHAR(9),[DayNum] char(1),[DayName_short] varchar(9),
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
					ENd

						INSERT INTO [dbo].[aADDate1] SELECT * from [dbo].[my_table]  WHERE my_table.Date1 NOT IN (SELECT Date1 FROM [dbo].[aADDate1])

					drop table [dbo].[my_table]
	ENd
ELSE
	BEGIN
	DECLARE @StartDate DATETIME = CONVERT (date, GETDATE())
	DECLARE @EndDate DATETIME = CONVERT (date, GETDATE()+365)
		CREATE TABLE [dbo].[aADDate1]
			(	[Date1] date primary key,[Year] CHAR(4),[Week] VARCHAR(30) ,[DayName] VARCHAR(9),[DayNum] char(1),[DayName_short] varchar(9),
				[Quarter] CHAR(1),[FiscalYear] CHAR(4), [FiscalPeriod] varchar(3),DAY_MONTH VARChaR(2),WEEK_YEAR VARChar(3)	)
		--if @last_value = @StartDate
		WHILE @StartDate <= @EndDate
		BEGIN
			INSERT INTO [dbo].[aADDate1]
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
select * from aADDate1
end