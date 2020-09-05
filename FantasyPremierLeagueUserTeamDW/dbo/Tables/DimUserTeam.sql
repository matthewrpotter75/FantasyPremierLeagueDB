CREATE TABLE dbo.DimUserTeam
(
	UserTeamKey INT IDENTITY(1,1) NOT NULL,
	SeasonKey INT NOT NULL,
	UserPlayerKey INT NOT NULL,
	RegionKey INT NULL,
	OverallPoints INT NOT NULL,
	OverallRank INT NULL,
	JoinedTime SMALLDATETIME NOT NULL,
	TeamName NVARCHAR(200) NOT NULL,
	TeamBank INT NOT NULL,
	TeamValue INT NOT NULL,
	TeamTransfers INT NOT NULL,
	Kit VARCHAR(500) NULL,
	FavouriteTeamKey INT NULL,
	StartedGameweekKey INT NOT NULL,
	UserTeamId INT NOT NULL,
	CONSTRAINT PK_DimUserTeam PRIMARY KEY CLUSTERED (UserTeamKey ASC)
)
GO

CREATE NONCLUSTERED INDEX IX_DimUserTeam_SeasonKey_UserPlayerKey
ON dbo.DimUserTeam (SeasonKey,UserPlayerKey)
GO