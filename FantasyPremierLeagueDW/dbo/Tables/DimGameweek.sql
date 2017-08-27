CREATE TABLE [dbo].[DimGameweek]
(
	[GameweekKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
	[DeadlineTime] SMALLDATETIME NOT NULL,
	[SeasonPart] AS 
	CASE
		WHEN [GameweekKey] <= 9 THEN 1
		WHEN [GameweekKey] > 9 AND [GameweekKey] <= 19 THEN 2
		WHEN [GameweekKey] > 20 AND [GameweekKey] <= 29 THEN 3
		ELSE 4
	END,
	CONSTRAINT [PK_DimGameweek] PRIMARY KEY CLUSTERED ([GameweekKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimGameweek_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);