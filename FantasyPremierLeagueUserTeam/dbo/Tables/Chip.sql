CREATE TABLE dbo.Chip 
(
    chipid INT NOT NULL,
    chipname VARCHAR(28) NOT NULL,
	chipdesc VARCHAR(28) NOT NULL,
    CONSTRAINT PK_Chip PRIMARY KEY CLUSTERED (chipid ASC)
);