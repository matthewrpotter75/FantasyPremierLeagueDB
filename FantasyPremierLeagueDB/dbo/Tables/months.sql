CREATE TABLE [dbo].[months] (
    [id]          TINYINT      NOT NULL,
    [name]        VARCHAR (50) NOT NULL,
    [start_event] TINYINT      NOT NULL,
    [stop_event]  TINYINT      NOT NULL,
    CONSTRAINT [PK_months] PRIMARY KEY CLUSTERED ([id] ASC)
);

