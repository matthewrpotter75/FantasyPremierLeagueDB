CREATE FUNCTION [dbo].[fnSplit] 
(
	@String NVARCHAR(MAX), 
	@Delimiter NVARCHAR(4) = N','
)
RETURNS TABLE
AS
RETURN 
(
	WITH Ordinals(Ordinal, start, final) AS 
	(
		SELECT 1, 1, CAST(CHARINDEX(@Delimiter, @String,1) AS INTEGER)
		UNION ALL
		SELECT Ordinal + 1, final + 1, CAST(CHARINDEX(@Delimiter, @String, final + 1) AS INTEGER) 
		FROM Ordinals
		WHERE final > 0
	)
	,Terms (Ordinal, Term) AS
	(
		SELECT Ordinal, 
		LTRIM(RTRIM(SUBSTRING(@String, start, CASE WHEN final > 0 THEN final-start ELSE (LEN(@String)-start)+1 END))) AS Term 
		FROM Ordinals
	)
	SELECT Ordinal, Term FROM Terms WHERE COALESCE(Term,'') <> ''
)