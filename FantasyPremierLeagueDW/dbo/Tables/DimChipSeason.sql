CREATE TABLE dbo.DimChipSeason
(
	ChipKey INT NOT NULL,
	SeasonKey INT NOT NULL,
	CONSTRAINT [PK_DimChipSeason] PRIMARY KEY CLUSTERED ([ChipKey] ASC, [SeasonKey] ASC),
	CONSTRAINT [FK_DimChipSeason_ChipKey] FOREIGN KEY ([ChipKey]) REFERENCES [dbo].[DimChip] ([ChipKey]),
	CONSTRAINT [FK_DimChipSeason_SeasonKey] FOREIGN KEY ([SeasonKey]) REFERENCES [dbo].[DimSeason] ([SeasonKey])
);