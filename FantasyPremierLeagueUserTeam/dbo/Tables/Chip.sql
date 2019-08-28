CREATE TABLE dbo.Chip 
(
    chipid INT NOT NULL,
    chip_name VARCHAR(28) NOT NULL,
    CONSTRAINT PK_Chip PRIMARY KEY CLUSTERED (chipid ASC)
);