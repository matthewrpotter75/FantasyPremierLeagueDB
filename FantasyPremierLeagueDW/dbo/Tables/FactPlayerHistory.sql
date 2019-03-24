CREATE TABLE [dbo].[FactPlayerHistory]
(
	[PlayerHistoryKey]				  INT IDENTITY(1,1) NOT NULL,
	[PlayerKey]						  INT NOT NULL,
	[GameweekKey]					  INT NOT NULL,
	[SeasonKey]						  INT NOT NULL,
    [WasHome]						  BIT            NOT NULL,
    [TotalPoints]                     SMALLINT       NOT NULL,
    [Value]                           TINYINT        NOT NULL,
    [TransfersBalance]                INT            NOT NULL,
    [Selected]                        INT            NULL,
    [TransfersIn]                     INT            NULL,
    [TransfersOut]                    INT            NULL,
    [LoanedIn]                        INT			 NULL,
    [LoanedOut]                       INT			 NULL,
    [Minutes]                         INT			 NOT NULL,
    [GoalsScored]                     TINYINT        NOT NULL,
    [Assists]                         TINYINT        NOT NULL,
    [CleanSheets]                     TINYINT        NOT NULL,
    [GoalsConceded]                   TINYINT        NOT NULL,
    [OwnGoals]                        TINYINT        NULL,
    [PenaltiesSaved]                  TINYINT        NULL,
    [PenaltiesMissed]                 TINYINT        NULL,
    [YellowCards]                     TINYINT        NOT NULL,
    [RedCards]                        TINYINT        NOT NULL,
    [Saves]                           TINYINT        NOT NULL,
    [Bonus]                           TINYINT        NOT NULL,
    [BPS]                             SMALLINT       NOT NULL,
    [Influence]                       DECIMAL(6,2)   NULL,
    [Creativity]                      DECIMAL(6,2)   NULL,
    [Threat]                          DECIMAL(6,2)   NULL,
    [ICTIndex]                        DECIMAL(6,2)   NULL,
    [EAIndex]                         SMALLINT       NULL,
    [OpenPlayCrosses]                 TINYINT        NULL,
    [BigChancesCreated]               TINYINT        NULL,
    [ClearancesBlocksInterceptions]   TINYINT        NULL,
    [Recoveries]                      TINYINT        NULL,
    [KeyPasses]                       TINYINT        NULL,
    [Tackles]                         TINYINT        NULL,
    [WinningGoals]                    TINYINT        NULL,
    [AttemptedPasses]                 TINYINT        NULL,
    [CompletedPasses]                 TINYINT        NULL,
    [PenaltiesConceded]               TINYINT        NULL,
    [BigChancesMissed]                TINYINT        NULL,
    [ErrorsLeadingToGoal]             TINYINT        NULL,
    [ErrorsLeadingToGoalAttempt]      TINYINT        NULL,
    [Tackled]                         TINYINT        NULL,
    [Offside]                         TINYINT        NULL,
    [TargetMissed]                    TINYINT        NULL,
    [Fouls]                           TINYINT        NULL,
    [Dribbles]                        TINYINT        NULL,
    [GameweekFixtureKey]               INT		     NOT NULL,
    [OpponentTeamKey]                  INT			 NOT NULL,
	CONSTRAINT [PK_FactPlayerHistory] PRIMARY KEY CLUSTERED ([PlayerHistoryKey] ASC),
	CONSTRAINT [FK_FactPlayerHistory_GameweekKey_SeasonKey] FOREIGN KEY ([GameweekKey], [SeasonKey]) REFERENCES [dbo].[DimGameweek] ([GameweekKey], [SeasonKey]),
	CONSTRAINT [FK_FactPlayerHistory_GameweekFixtureKey] FOREIGN KEY ([GameweekFixtureKey]) REFERENCES [dbo].[FactGameweekFixture] ([GameweekFixtureKey]),
	CONSTRAINT [FK_FactPlayerHistory_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey]),
    CONSTRAINT [FK_FactPlayerHistory_OpponentTeamKey] FOREIGN KEY ([OpponentTeamKey]) REFERENCES [dbo].[DimTeam] ([TeamKey]),
	CONSTRAINT [FK_FactPlayerHistory_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey])
);
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_PlayerKey_GameweekKey_SeasonKey_WasHome_OpponentTeamKey_Inc_TotalPoints_Minutes
ON [dbo].[FactPlayerHistory] ([PlayerKey],[GameweekKey],[SeasonKey],[WasHome],[OpponentTeamKey])
INCLUDE ([TotalPoints],[Minutes]);
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_Minutes_Inc_PlayerKey_SeasonKey_WasHome_TotalPoints_OpponentTeamKey
ON [dbo].[FactPlayerHistory] ([Minutes])
INCLUDE ([PlayerKey],[SeasonKey],[WasHome],[TotalPoints],[OpponentTeamKey])
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_Minutes_Inc_PlayerHistoryKey_PlayerKey_GameweekKey_SeasonKey_WasHome_TotalPoints_OpponentTeamKey
ON [dbo].[FactPlayerHistory] ([Minutes])
INCLUDE ([PlayerHistoryKey],[PlayerKey],[GameweekKey],[SeasonKey],[WasHome],[TotalPoints],[OpponentTeamKey])
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_SeasonKey_Inc_PlayerKey_TotalPoints_Minutes
ON [dbo].[FactPlayerHistory] ([SeasonKey])
INCLUDE ([PlayerKey],[TotalPoints],[Minutes])
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_GameweekKey_SeasonKey
ON [dbo].[FactPlayerHistory] ([GameweekKey],[SeasonKey])
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_GameweekKey_SeasonKey_Inc_PlayerKey_TotalPoints
ON [dbo].[FactPlayerHistory] ([GameweekKey],[SeasonKey])
INCLUDE ([PlayerKey],[TotalPoints])
GO

CREATE UNIQUE INDEX UX_FactPlayerHistory_PlayerKey_GameweekFixtureKey ON dbo.FactPlayerHistory (PlayerKey, GameweekFixtureKey)
GO