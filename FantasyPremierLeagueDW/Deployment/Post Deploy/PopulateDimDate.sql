DECLARE @sScriptName VARCHAR(256) = N'PopulateDimDate.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;

DECLARE @StartDate DATE = '20140816', @NumberOfYears INT = 30;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;	--SUNDAY is first day of week
SET DATEFORMAT DMY;
--SET LANGUAGE US_ENGLISH;
SET LANGUAGE British;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:

IF NOT EXISTS (SELECT 1 FROM dbo.DimDate)
BEGIN

	IF OBJECT_ID('tempdb..#dim') IS NOT NULL
		DROP TABLE #dim;

	CREATE TABLE #dim
	(
	  [Date]       DATE PRIMARY KEY, 
	  [Day]        AS DATEPART(DAY,[Date]),
	  [Month]      AS DATEPART(MONTH,[Date]),
	  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [Date]), 0)),
	  [MonthName]  AS DATENAME(MONTH,[Date]),
	  [Week]       AS DATEPART(WEEK,[Date]),
	  [ISOweek]    AS DATEPART(ISO_WEEK,[Date]),
	  [DayOfWeek]  AS DATEPART(WEEKDAY,[Date]),
	  [Quarter]    AS DATEPART(QUARTER,[Date]),
	  [Year]       AS DATEPART(YEAR,[Date]),
	  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [Date]), 0)),
	  Style112     AS CONVERT(CHAR(8),   [Date], 112),
	  Style101     AS CONVERT(CHAR(10),  [Date], 101)
	);

	-- use the catalog views to generate as many rows as we need

	INSERT #dim([date]) 
	SELECT d
	FROM
	(
	  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
	  FROM 
	  (
		SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
		  rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
		FROM sys.all_objects AS s1
		CROSS JOIN sys.all_objects AS s2
		-- on my system this would support > 5 million days
		ORDER BY s1.[object_id]
	  ) AS x
	) AS y;

	;WITH Gameweeks AS
	(
		SELECT SeasonKey, GameweekKey, DeadlineTime, LAG(DeadlineTime,1,0) OVER (ORDER BY SeasonKey, GameweekKey) AS LastDeadlineTime
		FROM dbo.DimGameweek
	)
	INSERT dbo.DimDate WITH (TABLOCKX)
	(
		 [Date]
        ,[SeasonKey]
        ,[GameweekKey]
        ,[Day]
        ,[DaySuffix]
        ,[Weekday]
        ,[WeekDayName]
        ,[IsWeekend]
        ,[IsHoliday]
        ,[IsBankHoliday]
        ,[HolidayText]
        ,[DOWInMonth]
        ,[DayOfYear]
        ,[WeekOfMonth]
        ,[WeekOfYear]
        ,[ISOWeekOfYear]
        ,[Month]
        ,[MonthName]
        ,[Quarter]
        ,[QuarterName]
        ,[Year]
        ,[MMYYYY]
        ,[MonthYear]
        ,[FirstDayOfMonth]
        ,[LastDayOfMonth]
        ,[FirstDayOfQuarter]
        ,[LastDayOfQuarter]
        ,[FirstDayOfYear]
        ,[LastDayOfYear]
        ,[FirstDayOfNextMonth]
        ,[FirstDayOfNextYear]
		,[MonthShortName]
		,[DisplayDate]
	)
	SELECT
	  d.[Date],
	  gw.SeasonKey,
	  gw.GameweekKey,
	  [Day]         = CONVERT(TINYINT, [Day]),
	  DaySuffix     = CONVERT(CHAR(2), 
								CASE 
									WHEN [Day] / 10 = 1 THEN 'th' 
									ELSE 
										CASE RIGHT([Day], 1) 
											WHEN '1' THEN 'st' 
											WHEN '2' THEN 'nd' 
											WHEN '3' THEN 'rd' 
											ELSE 'th' 
										END 
								END
							),
	  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
	  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [Date])),
	  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
	  [IsHoliday]   = CONVERT(BIT, 0),
	  [IsBankHoliday] = CONVERT(BIT, 0),
	  HolidayText   = CONVERT(VARCHAR(64), NULL),
	  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [Date])),
	  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [Date])),
	  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER (PARTITION BY [Year], [Month] ORDER BY [Week])),
	  WeekOfYear    = CONVERT(TINYINT, [Week]),
	  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
	  [Month]       = CONVERT(TINYINT, [Month]),
	  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
	  [Quarter]     = CONVERT(TINYINT, [Quarter]),
	  QuarterName   = CONVERT(VARCHAR(6), 
								CASE [Quarter] 
									WHEN 1 THEN 'First' 
									WHEN 2 THEN 'Second' 
									WHEN 3 THEN 'Third' 
									WHEN 4 THEN 'Fourth' 
								END
							), 
	  [Year]        = [Year],
	  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
	  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
	  FirstDayOfMonth     = FirstOfMonth,
	  LastDayOfMonth      = MAX([Date]) OVER (PARTITION BY [Year], [Month]),
	  FirstDayOfQuarter   = MIN([Date]) OVER (PARTITION BY [Year], [Quarter]),
	  LastDayOfQuarter    = MAX([Date]) OVER (PARTITION BY [Year], [Quarter]),
	  FirstDayOfYear      = FirstOfYear,
	  LastDayOfYear       = MAX([Date]) OVER (PARTITION BY [Year]),
	  FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
	  FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
	  MonthNameShort  = LEFT(CONVERT(VARCHAR(10), [MonthName]),3),
	  DisplayDate     = LEFT(CONVERT(VARCHAR(10), [MonthName]),3) + ' ' + CONVERT(VARCHAR(2), [Day]) + ' ' + CONVERT(VARCHAR(4), [Year])
	FROM #dim d
	LEFT JOIN Gameweeks gw
	ON d.[Date] > gw.LastDeadlineTime AND d.[Date] <= gw.DeadlineTime
	WHERE gw.SeasonKey IS NOT NULL
	AND gw.GameweekKey IS NOT NULL
	ORDER BY d.[Date]
	OPTION (MAXDOP 1);

	/*===========================
	*	IsHoliday Updates
	============================*/
	;WITH x AS 
	(
		SELECT 
			DateKey, 
			[Date], 
			IsHoliday, 
			HolidayText, 
			FirstDayOfYear, 
			IsBankHoliday, 
			[Year],
			DOWInMonth, 
			[MonthName], 
			[WeekDayName], 
			[Day],
			LastDOWInMonth = ROW_NUMBER() OVER (PARTITION BY FirstDayOfMonth, [Weekday] ORDER BY [Date] DESC),
			FirstDOWInMonth = ROW_NUMBER() OVER (PARTITION BY FirstDayOfMonth, [Weekday] ORDER BY [Date] ASC)
		FROM dbo.DimDate
	)
	/*=================================
	*	UK Public Holidays
	=================================*/
	UPDATE x 
	SET
	IsHoliday = 1,
	HolidayText = 
		CASE
			WHEN ([Date] = FirstDayOfYear) 
			THEN 'New Year''s Day'
			WHEN ([DAY] = 29 AND [MonthName] = 'April' AND [Year] = 2011)
			THEN 'Royal Wedding Bank Holiday'			-- (Royal Wedding)
			WHEN ([FirstDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
			THEN 'Early May Bank Holiday'				-- (First Monday in May)
			WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday') AND [Year] <> 2012
			THEN 'Spring Bank Holiday'					-- (Last Monday in May)
			WHEN ([FirstDOWInMonth] = 1 AND [MonthName] = 'June' AND [WeekDayName] = 'Monday') AND [Year] = 2012
			THEN 'Spring Bank Holiday'					-- (Spring bank holiday (substitute day - Queen’s Diamond Jubilee year)
			WHEN ([FirstDOWInMonth] = 1 AND [MonthName] = 'June' AND [WeekDayName] = 'Tuesday') AND [Year] = 2012
			THEN 'Queen’s Diamond Jubilee Bank Holiday'	-- (Queen’s Diamond Jubilee (extra bank holiday)
			WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'August' AND [WeekDayName] = 'Monday')
			THEN 'Summer Bank Holiday'					-- (Last Monday in August)
			WHEN ([MonthName] = 'December' AND [Day] = 25)
			THEN 'Christmas Day'
			WHEN ([MonthName] = 'December' AND [Day] = 26)
			THEN 'Boxing Day'
		END
	WHERE 
		([Date] = FirstDayOfYear)
		OR ([DAY] = 29 AND [MonthName] = 'April' AND [Year] = 2011)
		OR ([FirstDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
		OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')  AND [Year] <> 2012
		OR ([FirstDOWInMonth] = 1 AND [MonthName] = 'June' AND [WeekDayName] = 'Monday') AND [Year] = 2012
		OR ([FirstDOWInMonth] = 1 AND [MonthName] = 'June' AND [WeekDayName] = 'Tuesday') AND [Year] = 2012
		OR ([LastDOWInMonth] = 1 AND [MonthName] = 'August'	AND [WeekDayName] = 'Monday')
		OR ([MonthName] = 'December' AND [Day] = 25)
		OR ([MonthName] = 'December' AND [Day] = 26);

	/*============================
	*	New Years Bank Holiday
	*	Calculate Substitute day
	=============================*/
	;WITH x AS
	(
		SELECT
			[Date], 
			[Day], 
			[WeekDay], 
			[WeekDayName], 
			[IsWeekEnd], 
			[IsHoliday], 
			[IsBankHoliday],
			CASE
				WHEN WeekDayName IN ('Saturday')
					THEN DATEADD(DAY, 2, [Date])
				WHEN WeekDayName IN ('Sunday')
					THEN DATEADD(DAY, 1, [Date])
				ELSE
					[Date]
			 END AS NewYearBankHoliday
		FROM dbo.DimDate
		WHERE [DayOfYear] = 1
	)
	UPDATE D
	SET
	IsHoliday = 1,
	IsBankHoliday = 1,
	HolidayText = 'New Year''s Bank Holiday'
	FROM dbo.DimDate D
	INNER JOIN x
	ON X.NewYearBankHoliday = D.[Date];

	/*===========================
	*	Calculate Days of Easter
	============================*/

	/*===========================
	*	Easter
	*	Calculate Bank Holidays
	============================*/
	;WITH x AS 
	(
		SELECT d.[Date], d.IsHoliday, d.HolidayText, h.HolidayName, IsBankHoliday
		FROM dbo.DimDate d
		CROSS APPLY dbo.fnGetEasterHolidays(d.[Year]) h
		WHERE d.[Date] = h.[Date]
	)
	UPDATE x
	SET
	IsHoliday = 1,
	IsBankHoliday = 
		CASE
			WHEN HolidayName IN ( 'Good Friday', 'Easter Monday') 
				THEN 1
			ELSE 0
		END,
	HolidayText = HolidayName;

	/*=========================
	*	Update IsBankHoliday
	*	for Bank Holidays
	=========================*/
	UPDATE dbo.DimDate
	SET IsBankHoliday = 1
	WHERE HolidayText LIKE '%Bank Holiday';

	/*=========================================
	*	Christmas 
	*	Calculate Substitute bank holiday
	==========================================*/
	;WITH X AS
	(
		SELECT
			[Date], 
			[Day], 
			[WeekDay], 
			WeekDayName, 
			IsWeekEnd, 
			IsHoliday, 
			HolidayText, 
			IsBankHoliday,
			CASE
				WHEN (WeekDayName IN ( 'Saturday') AND ([MonthName] = 'December' AND [Day] = 25))
					THEN DATEADD(DAY, 2, [Date])
				WHEN (WeekDayName IN ( 'Sunday') AND ([MonthName] = 'December' AND [Day] = 25))
					THEN DATEADD(DAY, 1, [Date])
				ELSE [Date]
			 END AS	XMas_BankHoliday
		FROM dbo.DimDate
		WHERE ([MonthName] = 'December' 
		AND [Day] = 25)
	)
	UPDATE D
	SET
	IsHoliday = 1
	,IsBankHoliday = 1
	,HolidayText = 'Christmas Day Bank Holiday'
	FROM dbo.DimDate D
	INNER JOIN X
	ON X.XMas_BankHoliday = D.[Date];

	/*=========================================
	*	Boxing Day 
	*	Calculate Substitute bank holiday
	==========================================*/
	;WITH X AS
	(
		SELECT
			[Date], 
			[Day], 
			[WeekDay], 
			WeekDayName, 
			IsWeekEnd, 
			IsHoliday, 
			HolidayText, 
			IsBankHoliday,
			CASE
				WHEN (WeekDayName IN ( 'Saturday') AND ([MonthName] = 'December' AND [Day] = 26))
					THEN DATEADD(DAY, 2, [Date])
				WHEN (WeekDayName IN ( 'Sunday') AND ([MonthName] = 'December' AND [Day] = 26))
					THEN DATEADD(DAY, 2, [Date])
				--to cater for Christmas Day Substitute bank holiday
				WHEN (WeekDayName IN ( 'Monday') AND ([MonthName] = 'December' AND [Day] = 26))
					THEN DATEADD(DAY, 1, [Date])
				ELSE [Date]
			 END AS BoxDay_BankHoliday
		FROM dbo.DimDate
		WHERE ([MonthName] = 'December' 
		AND [Day] = 26)
	)
	UPDATE D
	SET
	IsHoliday = 1
	,IsBankHoliday = 1
	,HolidayText = 'Boxing Day Bank Holiday'
	FROM dbo.DimDate	D
	INNER JOIN X
	ON X.BoxDay_BankHoliday = D.[Date];

	--SELECT * FROM dbo.DimDate WHERE HolidayText IS NOT NULL AND [Year] = 2008 ;
	--SELECT * FROM dbo.DateDimension WHERE [Year] = 2011 AND [MonthName] = 'April' ;
	--SELECT * FROM dbo.DateDimension WHERE IsBankHoliday = 1 AND [Year] = 2013;

	IF OBJECT_ID('tempdb..#dim') IS NOT NULL
		DROP TABLE #dim;

END

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimDate.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO