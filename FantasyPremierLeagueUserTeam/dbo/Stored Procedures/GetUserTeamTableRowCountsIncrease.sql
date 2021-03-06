CREATE PROCEDURE dbo.GetUserTeamTableRowCountsIncrease
(
	@UserTableName VARCHAR(100) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @OneDayAgo DATETIME = DATEADD(HOUR,-24,GETDATE());

	SELECT Id
		  ,UserTableName
		  ,TableRowCount
		  ,CountDate
		  ,LAG(TableRowCount,1) OVER (PARTITION BY UserTableName ORDER BY UserTableName, Id) AS PreviousRowCount
		  ,TableRowCount - (LAG(TableRowCount,1) OVER (PARTITION BY UserTableName ORDER BY UserTableName, Id)) AS RowCountIncrease
	  FROM dbo.UserTeamTableCounts
	  WHERE CountDate >= @OneDayAgo
	  --WHERE UserTableName = @UserTableName
	  ORDER BY UserTableName, Id;

END