CREATE TABLE dbo.UserTeamLeague
(
	id INT NOT NULL,
	league_name VARCHAR(100) NOT NULL,
	short_name VARCHAR(50) NULL,
	created SMALLDATETIME NOT NULL,
	league_type CHAR(1) NOT NULL,
	scoring VARCHAR(2) NOT NULL,
	admin_userTeamid INT NULL,
	CONSTRAINT PK_UserTeamLeague PRIMARY KEY CLUSTERED (id ASC)
);