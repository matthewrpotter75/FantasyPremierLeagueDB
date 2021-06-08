CREATE PROCEDURE dbo.UpdateUserTeam
AS
BEGIN

	UPDATE ut
	SET player_first_name = utus.player_first_name,
		  player_last_name = utus.player_last_name,
		  player_region_id = utus.player_region_id,
		  player_region_name = utus.player_region_name,
		  player_region_iso_code = utus.player_region_iso_code,
		  summary_overall_points = utus.summary_overall_points,
		  summary_overall_rank = utus.summary_overall_rank,
		  summary_gameweek_points = utus.summary_gameweek_points,
		  summary_gameweek_rank = utus.summary_gameweek_rank,
		  current_gameweekId = utus.current_gameweekId,
		  joined_time = utus.joined_time,
		  team_name = utus.team_name,
		  team_bank = utus.team_bank,
		  team_value = utus.team_value,
		  team_transfers = utus.team_transfers,
		  kit = utus.kit,
		  favourite_teamid = utus.favourite_teamid,
		  started_gameweekid = utus.started_gameweekid,
		  DateUpdated = utus.DateInserted
	FROM dbo.UserTeam ut
	INNER JOIN dbo.UserTeamUpdateStaging utus
	ON ut.id = utus.id;

END