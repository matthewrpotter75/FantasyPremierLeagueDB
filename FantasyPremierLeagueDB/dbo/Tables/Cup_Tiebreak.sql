CREATE TABLE dbo.Cup_Tiebreak
(
	id INT IDENTITY(1,1) NOT NULL,
	cupid INT NOT NULL,
	tiebreak_name VARCHAR(20) NOT NULL,
	tiebreak_choice CHAR(1) NOT NULL,
	CONSTRAINT PK_Cup_Tiebreak PRIMARY KEY CLUSTERED (id ASC)
);