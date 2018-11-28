/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
:r ".\Deployment\Post Deploy\PopulateDimSeason.sql"
:r ".\Deployment\Post Deploy\PopulateDimChip.sql"
:r ".\Deployment\Post Deploy\PopulateDimChipSeason.sql"
:r ".\Deployment\Post Deploy\PopulateDimUser.sql"
:r ".\Deployment\Post Deploy\PopulateDimUserTeam.sql"
:r ".\Deployment\Post Deploy\PopulateDimUserTeamGameweekChip.sql"
:r ".\Deployment\Post Deploy\DimUserTeamPlayer - Copy from MyTeam temp table.sql"
:r ".\Deployment\Post Deploy\PopulateDimDate.sql"