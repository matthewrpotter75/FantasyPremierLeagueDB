CREATE TABLE dbo.UserTeamTableCounts
(
	Id INT IDENTITY(1,1) NOT NULL,
	UserTableName VARCHAR(100) NOT NULL,
	TableRowCount INT NOT NULL,
	CountDate DATETIME NOT NULL,
	CONSTRAINT PK_UserTeamTableCounts PRIMARY KEY CLUSTERED (Id ASC)
);