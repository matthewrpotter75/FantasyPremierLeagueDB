CREATE PROCEDURE dbo.GetUserTeamCountsIncrease
(
	@UserTableName VARCHAR(100) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @OneDayAgo DATETIME = DATEADD(HOUR,-24,GETDATE());

	SELECT Id
		  ,UserTableName
		  ,UserTeamCount
		  ,CountDate
		  ,LAG(UserTeamCount,1) OVER (PARTITION BY UserTableName ORDER BY UserTableName, Id) AS PreviousRowCount
		  ,UserTeamCount - (LAG(UserTeamCount,1) OVER (PARTITION BY UserTableName ORDER BY UserTableName, Id)) AS UserTeamCountIncrease
	  FROM dbo.UserTeamCounts
	  WHERE CountDate >= @OneDayAgo
	  --WHERE UserTableName = @UserTableName
	  ORDER BY UserTableName, Id;

END