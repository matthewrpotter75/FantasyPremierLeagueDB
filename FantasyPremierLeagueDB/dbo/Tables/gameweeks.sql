CREATE TABLE [dbo].[Gameweeks] (
    [id]                        INT	          NOT NULL,
    [name]                      VARCHAR (16)  NOT NULL,
    [deadline_time]             SMALLDATETIME NOT NULL,
    [average_entry_score]       INT			  NOT NULL,
    [finished]                  BIT           NOT NULL,
    [data_checked]              BIT           NOT NULL,
    [highest_scoring_entry]     INT           NULL,
    [deadline_time_epoch]       INT           NOT NULL,
    [deadline_time_game_offset] INT           NOT NULL,
    [deadline_time_formatted]   VARCHAR (16)  NOT NULL,
    [highest_score]             INT			  NULL,
    [is_previous]               BIT           NOT NULL,
    [is_current]                BIT           NOT NULL,
    [is_next]                   BIT           NOT NULL,
    CONSTRAINT [PK_Gameweeks] PRIMARY KEY CLUSTERED ([id] ASC)
);

