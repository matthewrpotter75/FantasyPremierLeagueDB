/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
:r ".\Deployment\Pre Deploy\DimUserTeamPlayer - Copy MyTeam into temp table.sql"
:r ".\Deployment\Pre Deploy\Update FactPlayerGameweekNews to have PlayerNewsKey - Copy FactPlayerGameweekNews into temp table.sql"