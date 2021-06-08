CREATE TABLE dbo.DimUserPlayer
(
	UserPlayerKey INT IDENTITY(1,1) NOT NULL,
	PlayerFirstName NVARCHAR(500) NOT NULL,
	PlayerLastName NVARCHAR(500) NOT NULL,
	RegionKey INT NOT NULL,
	FromUserTeamId INT NOT NULL,
	FromSeasonKey INT NOT NULL,
	CONSTRAINT PK_DimUserPlayer PRIMARY KEY CLUSTERED (UserPlayerKey ASC)
)
GO