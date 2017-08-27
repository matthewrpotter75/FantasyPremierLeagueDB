CREATE TABLE [dbo].[sub_positions_locked] (
    [element_typeId]       TINYINT NOT NULL,
    [sub_positions_locked] TINYINT NULL,
    CONSTRAINT [PK_sub_positions_locked] PRIMARY KEY CLUSTERED ([element_typeId] ASC),
    CONSTRAINT [FK_sub_positions_locked_element_typeId] FOREIGN KEY ([element_typeId]) REFERENCES [dbo].[element_type] ([id])
);

