CREATE TABLE dbo.DimNewPlayer
(
	NewPlayerKey INT IDENTITY(1,1) NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	SecondName VARCHAR(50) NOT NULL,
	WebName VARCHAR(100) NOT NULL,
	PlayerName VARCHAR(100) NOT NULL,
	SeasonAddedKey INT NOT NULL,
	GameweekKey INT NOT NULL,
	PlayerKey INT NOT NULL DEFAULT (-1),
	CONSTRAINT [FK_DimNewPlayer_PlayerKey] FOREIGN KEY ([PlayerKey]) REFERENCES [dbo].[DimPlayer] ([PlayerKey]),
	CONSTRAINT PK_DimNewPlayer PRIMARY KEY CLUSTERED 
	(
		NewPlayerKey ASC
	)
);