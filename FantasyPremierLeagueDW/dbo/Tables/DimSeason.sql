﻿CREATE TABLE [dbo].[DimSeason]
(
	[SeasonKey] INT NOT NULL,
	[SeasonName] VARCHAR(10),
	[SeasonStartDate] SMALLDATETIME NOT NULL,
	[SeasonEndDate] SMALLDATETIME NOT NULL,
	CONSTRAINT [PK_DimSeason] PRIMARY KEY CLUSTERED ([SeasonKey] ASC)
)
