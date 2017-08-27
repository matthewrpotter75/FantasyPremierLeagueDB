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
    [Selected]                        INT            NOT NULL,
    [TransfersIn]                     INT            NOT NULL,
    [TransfersOut]                    INT            NOT NULL,
    [LoanedIn]                        INT			 NOT NULL,
    [LoanedOut]                       INT			 NOT NULL,
    [Minutes]                         INT			 NOT NULL,
    [GoalsScored]                     TINYINT        NOT NULL,
    [Assists]                         TINYINT        NOT NULL,
    [CleanSheets]                     TINYINT        NOT NULL,
    [GoalsConceded]                   TINYINT        NOT NULL,
    [OwnGoals]                        TINYINT        NOT NULL,
    [PenaltiesSaved]                  TINYINT        NOT NULL,
    [PenaltiesMissed]                 TINYINT        NOT NULL,
    [YellowCards]                     TINYINT        NOT NULL,
    [RedCards]                        TINYINT        NOT NULL,
    [Saves]                           TINYINT        NOT NULL,
    [Bonus]                           TINYINT        NOT NULL,
    [BPS]                             SMALLINT       NOT NULL,
    [Influence]                       DECIMAL(6,2)   NOT NULL,
    [Creativity]                      DECIMAL(6,2)   NOT NULL,
    [Threat]                          DECIMAL(6,2)   NOT NULL,
    [ICTIndex]                        DECIMAL(6,2)   NOT NULL,
    [EAIndex]                         SMALLINT       NOT NULL,
    [OpenPlayCrosses]                 TINYINT        NOT NULL,
    [BigChancesCreated]               TINYINT        NOT NULL,
    [ClearancesBlocksInterceptions]   TINYINT        NOT NULL,
    [Recoveries]                      TINYINT        NOT NULL,
    [KeyPasses]                       TINYINT        NOT NULL,
    [Tackles]                         TINYINT        NOT NULL,
    [WinningGoals]                    TINYINT        NOT NULL,
    [AttemptedPasses]                 TINYINT        NOT NULL,
    [CompletedPasses]                 TINYINT        NOT NULL,
    [PenaltiesConceded]               TINYINT        NOT NULL,
    [BigChancesMissed]                TINYINT        NOT NULL,
    [ErrorsLeadingToGoal]             TINYINT        NOT NULL,
    [ErrorsLeadingToGoalAttempt]      TINYINT        NOT NULL,
    [Tackled]                         TINYINT        NOT NULL,
    [Offside]                         TINYINT        NOT NULL,
    [TargetMissed]                    TINYINT        NOT NULL,
    [Fouls]                           TINYINT        NOT NULL,
    [Dribbles]                        TINYINT        NOT NULL,
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

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_PlayerId_GameweekId_SeasonId_WasHome_OpponentTeamId_Inc_TotalPoints_Minutes
ON [dbo].[FactPlayerHistory] ([PlayerKey],[GameweekKey],[SeasonKey],[WasHome],[OpponentTeamKey])
INCLUDE ([TotalPoints],[Minutes]);
GO

CREATE NONCLUSTERED INDEX IX_FactPlayerHistory_Minutes_Inc_PlayerKey_SeasonKey_WasHome_TotalPoints_OpponentTeamKey
ON [dbo].[FactPlayerHistory] ([Minutes])
INCLUDE ([PlayerKey],[SeasonKey],[WasHome],[TotalPoints],[OpponentTeamKey])
GO