﻿CREATE TABLE [dbo].[FactPlayerHistoryPastSeasons]
(
	[FactPlayerHistoryPastSeasonKey] INT IDENTITY(1,1) NOT NULL,
	[PlayerKey]         INT            NOT NULL,
	[SeasonKey]         INT			  NOT NULL,
    [ElementCode]      INT            NOT NULL,
    [StartCost]        TINYINT        NOT NULL,
    [EndCost]          TINYINT        NOT NULL,
    [TotalPoints]      SMALLINT       NOT NULL,
    [Minutes]          SMALLINT       NOT NULL,
    [GoalsScored]      TINYINT        NOT NULL,
    [Assists]          TINYINT        NOT NULL,
    [CleanSheets]      TINYINT        NOT NULL,
    [GoalsConceded]    TINYINT        NOT NULL,
    [OwnGoals]         TINYINT        NOT NULL,
    [PenaltiesSaved]   TINYINT        NOT NULL,
    [PenaltiesMissed]  TINYINT        NOT NULL,
    [YellowCards]      TINYINT        NOT NULL,
    [RedCards]         TINYINT        NOT NULL,
    [Saves]            TINYINT        NOT NULL,
    [Bonus]            TINYINT        NOT NULL,
    [BPS]              SMALLINT       NOT NULL,
    [Influence]        DECIMAL (6, 2) NOT NULL,
    [Creativity]       DECIMAL (6, 2) NOT NULL,
    [Threat]           DECIMAL (6, 2) NOT NULL,
    [ICTIndex]         DECIMAL (6, 2) NOT NULL,
    [EAIndex]          SMALLINT       NULL,
    CONSTRAINT [PK_FactPlayerHistoryPastSeasons] PRIMARY KEY CLUSTERED ([FactPlayerHistoryPastSeasonKey] ASC),
	CONSTRAINT [FK_FactPlayerHistoryPastSeasons_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT [FK_FactPlayerHistoryPastSeasons_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);