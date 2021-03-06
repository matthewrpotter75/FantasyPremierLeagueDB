﻿CREATE TABLE [dbo].[DimTeamAttribute]
(
	[TeamAttributeKey] INT IDENTITY(1,1) NOT NULL,
	[TeamKey] INT NOT NULL,
	[SeasonKey] INT NOT NULL,
    [Strength] INT NULL,
    [Position] INT NOT NULL,
    [Played] INT NOT NULL,
    [Win] INT NOT NULL,
    [Loss] INT NOT NULL,
    [Draw] INT NOT NULL,
    [Points] INT NOT NULL,
    [Form] INT NULL,
    [LinkURL] VARCHAR (50) NOT NULL,
    [StrengthOverallHome] INT NOT NULL,
    [StrengthOverallAway] INT NOT NULL,
    [StrengthAttackHome] INT NOT NULL,
    [StrengthAttackAway] INT NOT NULL,
    [StrengthDefenceHome] INT NOT NULL,
    [StrengthDefenceAway] INT NOT NULL,
    [TeamDivision] INT NOT NULL,
	CONSTRAINT [PK_DimTeamAttribute] PRIMARY KEY CLUSTERED ([TeamAttributeKey] ASC),
	CONSTRAINT [FK_DimTeamAttribute_TeamKey_SeasonKey] FOREIGN KEY ([TeamKey],[SeasonKey]) REFERENCES [dbo].[DimTeamSeason] ([TeamKey],[SeasonKey]),
	CONSTRAINT [FK_DimTeamAttribute_TeamKey] FOREIGN KEY ([TeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_DimTeamAttribute_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);