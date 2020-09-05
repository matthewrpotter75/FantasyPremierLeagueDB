CREATE TABLE [dbo].[DimGameweek]
(
	[GameweekKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[DeadlineTime] SMALLDATETIME NOT NULL,
	[SeasonPart] AS 
	CASE
		WHEN [GameweekKey] = -1 THEN -1
		WHEN [GameweekKey] > 0 AND [GameweekKey] <= 9 THEN 1
		WHEN [GameweekKey] > 9 AND [GameweekKey] <= 19 THEN 2
		WHEN [GameweekKey] > 19 AND [GameweekKey] <= 29 THEN 3
		ELSE 4
	END,
	[SeasonHalf] AS 
	CASE
		WHEN [GameweekKey] = -1 THEN -1
		WHEN [GameweekKey] >= 1 AND [GameweekKey] <= 19 THEN 1
		WHEN [GameweekKey] > 19 THEN 2
		ELSE 0
	END,
	CONSTRAINT [PK_DimGameweek] PRIMARY KEY CLUSTERED ([GameweekKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimGameweek_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);
GO