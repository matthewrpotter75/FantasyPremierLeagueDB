CREATE TABLE dbo.Gameweeks 
(
    id                        INT	        NOT NULL,
    [name]                    VARCHAR (16)  NOT NULL,
    deadline_time             SMALLDATETIME NOT NULL,
    average_entry_score       INT			NOT NULL,
    finished                  BIT           NOT NULL,
    data_checked              BIT           NOT NULL,
    highest_scoring_entry     INT           NULL,
    deadline_time_epoch       INT           NOT NULL,
    deadline_time_game_offset INT           NOT NULL,
    highest_score             INT			NULL,
    is_previous               BIT           NOT NULL,
    is_current                BIT           NOT NULL,
    is_next                   BIT           NOT NULL,
    most_selected			  INT			NULL,
    most_transferred_in		  INT			NULL, 
    top_element 			  INT			NULL,
    transfers_made 			  INT			NOT NULL,
    most_captained 			  INT			NULL,
    most_vice_captained		  INT			NULL,
    CONSTRAINT PK_Gameweeks PRIMARY KEY CLUSTERED (id ASC)
);