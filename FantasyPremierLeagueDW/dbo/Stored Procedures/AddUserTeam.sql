CREATE PROCEDURE dbo.AddUserTeam
(
	@UserKey INT,
	@SeasonKey INT,
	@UserTeamName VARCHAR(100),
	@UserTeamDescription VARCHAR(100) = ''
)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO dbo.DimUserTeam (UserKey, SeasonKey, UserTeamName, UserTeamDescription)
	VALUES (@UserKey, @SeasonKey, @UserTeamName, @UserTeamDescription)

END;