CREATE PROCEDURE dbo.AddUser
(
	@UserName VARCHAR(100),
	@UserNameDescription VARCHAR(100) = ''
)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO dbo.DimUser (UserName, UserNameDescription)
	VALUES (@UserName, @UserNameDescription)

END;