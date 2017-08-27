CREATE TABLE [dbo].[next_event_fixture] (
    [teamId]    INT  NOT NULL,
    [is_home]   BIT      NULL,
    [day]       TINYINT  NULL,
    [event_day] TINYINT  NULL,
    [month]     TINYINT  NULL,
    [id]        SMALLINT NULL,
    [opponent]  INT      NOT NULL,
    CONSTRAINT [PK_next_event_fixture] PRIMARY KEY CLUSTERED ([teamId] ASC),
    CONSTRAINT [FK_next_event_fixture_teamId] FOREIGN KEY ([teamId]) REFERENCES [dbo].[Teams] ([id])
);

