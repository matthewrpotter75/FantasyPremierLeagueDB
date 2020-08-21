CREATE TABLE [dbo].[Fixture] 
(
    [code]                   INT      NOT NULL,
    [gameweekid]             INT      NULL,
    [finished]               BIT      NULL,
    [finished_provisional]   BIT      NOT NULL,
    [id]                     INT      NOT NULL,
    [kickoff_time]           DATETIME NULL,
    [minutes]                INT      NOT NULL,
    [provisional_start_time] BIT      NOT NULL,
    [started]                BIT      NULL,
    [team_a]                 INT      NOT NULL,
    [team_a_score]           INT      NULL,
    [team_h]                 INT      NOT NULL,
    [team_h_score]           INT      NULL,
    [team_h_difficulty]      INT      NOT NULL,
    [team_a_difficulty]      INT      NOT NULL,
    CONSTRAINT [PK_Fixture] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_Fixture_gameweekid] FOREIGN KEY ([gameweekid]) REFERENCES [dbo].[Gameweeks] ([id]),
    CONSTRAINT [FK_Fixture_team_a] FOREIGN KEY ([team_a]) REFERENCES [dbo].[Teams] ([id]),
    CONSTRAINT [FK_Fixture_team_h] FOREIGN KEY ([team_h]) REFERENCES [dbo].[Teams] ([id])
);