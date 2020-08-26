CREATE TABLE dbo.DimUserPlayer
(
	UserPlayerKey INT NOT NULL,
	PlayerFirstName VARCHAR(500) NULL,
	PlayerLastName VARCHAR(500) NULL,
	CONSTRAINT PK_DimUserPlayer PRIMARY KEY CLUSTERED (UserPlayerKey ASC)
)
GO