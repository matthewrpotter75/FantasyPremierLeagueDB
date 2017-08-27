CREATE TABLE [dbo].[PlayerPositions] (
    [id]                  INT      NOT NULL,
    [singular_name]       VARCHAR (16) NOT NULL,
    [singular_name_short] VARCHAR (3)  NOT NULL,
    [plural_name]         VARCHAR (16) NOT NULL,
    [plural_name_short]   VARCHAR (3)  NOT NULL,
    CONSTRAINT [PK_PlayerPositions] PRIMARY KEY CLUSTERED ([id] ASC)
);