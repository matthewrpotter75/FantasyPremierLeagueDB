CREATE TABLE dbo.DimChip
(
	ChipKey INT NOT NULL,
	ChipName VARCHAR(20) NOT NULL,
	CONSTRAINT [PK_DimChip] PRIMARY KEY CLUSTERED ([ChipKey] ASC)
);