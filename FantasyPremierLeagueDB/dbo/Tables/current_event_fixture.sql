CREATE TABLE [dbo].[current_event_fixture] (
    [teamId]    INT  NOT NULL,
    [is_home]   BIT      NOT NULL,
    [day]       TINYINT  NOT NULL,
    [event_day] TINYINT  NOT NULL,
    [month]     TINYINT  NOT NULL,
    [id]        SMALLINT NOT NULL,
    [opponent]  TINYINT  NOT NULL,
    CONSTRAINT [PK_current_event_fixture] PRIMARY KEY CLUSTERED ([teamId] ASC),
    CONSTRAINT [FK_current_event_fixture_teamId] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Teams] ([id])
);

