CREATE TABLE [dbo].[formations] (
    [id]                TINYINT      IDENTITY (1, 1) NOT NULL,
    [formation_name]    VARCHAR (10) NOT NULL,
    [player_positionId] TINYINT      NOT NULL,
    [positionId]        TINYINT      NOT NULL,
    CONSTRAINT [PK_formations] PRIMARY KEY CLUSTERED ([id] ASC)
);

