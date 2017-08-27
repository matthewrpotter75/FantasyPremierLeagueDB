CREATE TABLE [dbo].[element_type] (
    [id]                     TINYINT IDENTITY (1, 1) NOT NULL,
    [scoring_clean_sheets]   TINYINT NOT NULL,
    [squad_min_play]         TINYINT NOT NULL,
    [scoring_goals_conceded] TINYINT NOT NULL,
    [scoring_goals_scored]   TINYINT NOT NULL,
    [squad_max_play]         TINYINT NOT NULL,
    [bps_goals_scored]       TINYINT NOT NULL,
    [bps_clean_sheets]       TINYINT NOT NULL,
    [squad_select]           TINYINT NOT NULL,
    CONSTRAINT [PK_element_type] PRIMARY KEY CLUSTERED ([id] ASC)
);

