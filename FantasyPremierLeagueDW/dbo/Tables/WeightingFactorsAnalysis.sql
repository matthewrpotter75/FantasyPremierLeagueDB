CREATE TABLE dbo.WeightingFactorsAnalysis
(
	WeightingFactorsAnalysisKey INT IDENTITY(1,1) NOT NULL,
	SeasonKey INT,
	GameweekStartKey INT,
	Gameweeks INT,
	PlayerPositionKey INT,
	PredictionPointsAllWeighting INT,
	PredictionPoints5Weighting INT,
	PredictionPoints10Weighting INT,
	PlayerKey INT,
	PlayerName VARCHAR(100),
	Cost INT,
	PlayerPosition VARCHAR(3),
	TeamName VARCHAR(50),
	TotalPlayerGames INT,
	TotalPlayerMinutes INT,
	CurrentPoints INT,
	PredictedPointsAll DECIMAL(6,2),
	PredictedPoints5 DECIMAL(6,2),
	PredictedPoints10 DECIMAL(6,2),
	OverallPPGPredictionPoints DECIMAL(10,6),
	OverallTeamPPGPredictionPoints DECIMAL(10,6),
	OverallDifficultyPPGPredictionPoints DECIMAL(10,6),
	OverallFractionOfMinutesPlayed DECIMAL(10,6),
	Prev5FractionOfMinutesPlayed DECIMAL(10,6),
	StartingProbability DECIMAL(10,6),
	TotalGames INT,
	TeamTotalGames INT,
	DifficultyTotalGames INT,
	PredictedPointsPath INT,
	PredictedPoints DECIMAL(10,6),
	PredictedPointsWeighted DECIMAL(10,6),
	ChanceOfPlayingNextRound DECIMAL(6,2),
	CONSTRAINT [PK_WeightingFactorsAnalysis] PRIMARY KEY CLUSTERED (WeightingFactorsAnalysisKey ASC)
	--CONSTRAINT [UC_WeightingFactorsAnalysis_PlayerPositionKey_SeasonKey_GameweekStartKey_Gameweeks_PredictionPointsWeightings] 
		--UNIQUE (PlayerKey, PlayerPositionKey, SeasonKey, GameweekStartKey, Gameweeks, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting)
);
GO

CREATE INDEX IX_WeightingFactorsAnalysis_PlayerPositionKey_SeasonKey_GameweekStartKey_PredictionPointsWeightings ON dbo.WeightingFactorsAnalysis (PlayerPositionKey, SeasonKey, GameweekStartKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting);
GO

CREATE UNIQUE INDEX UX_WeightingFactorsAnalysis_PlayerKey_PlayerPositionKey_SeasonKey_GameweekStartKey_Gameweeks_PredictionPointsWeightings ON dbo.WeightingFactorsAnalysis (PlayerKey, PlayerPositionKey, SeasonKey, GameweekStartKey, PredictionPointsAllWeighting, PredictionPoints5Weighting, PredictionPoints10Weighting);
GO