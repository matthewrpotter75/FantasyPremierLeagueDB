CREATE TABLE dbo.PlayerPrices
(
	playerid INT NOT NULL,
	web_name VARCHAR(50) NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	second_name VARCHAR(50) NOT NULL,
	influence DECIMAL(6, 2) NOT NULL,
	creativity DECIMAL(6, 2) NOT NULL,
	threat DECIMAL(6, 2) NOT NULL,
	ict_index DECIMAL(6, 2) NOT NULL,
	ea_index SMALLINT NOT NULL,
	playerPositionId INT NOT NULL,
	teamId INT NOT NULL,
	cost TINYINT NOT NULL,
	CONSTRAINT PK_PlayerPrices PRIMARY KEY CLUSTERED (playerid ASC)
);


