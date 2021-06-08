CREATE PROCEDURE dbo.GetChipIdFromName
(
	@ChipName VARCHAR(20)
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT chipid AS id 
	FROM dbo.Chip utc 
	WHERE chipname = @ChipName;

END