CREATE TYPE dbo.UDTPlayersToChangeTable AS TABLE 
(
	Id INT IDENTITY(1,1), 
	PlayerKey INT, 
	PlayerPositionKey INT, 
	PlayerName VARCHAR(100), 
	Cost INT, 
	TotalPoints INT
    PRIMARY KEY (PlayerKey)
);