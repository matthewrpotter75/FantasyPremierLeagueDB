DECLARE @sScriptName VARCHAR(256) = N'PopulateDimSeason.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Starting at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO

SET NOCOUNT ON;

MERGE INTO dbo.DimSeason AS Target 
USING 
(
	VALUES 
	--(1,'2016/17','2016-08-01','2017-06-01'),
	--(2,'2017/18','2017-08-01','2018-06-01')
	(1,'2006/07','20060801','20070701'),
	(2,'2007/08','20070801','20080701'),
	(3,'2008/09','20080801','20090701'),
	(4,'2009/10','20090801','20100701'),
	(5,'2010/11','20100801','20110701'),
	(6,'2011/12','20110801','20120701'),
	(7,'2012/13','20120801','20130701'),
	(8,'2013/14','20130801','20140701'),
	(9,'2014/15','20140801','20150701'),
	(10,'2015/16','20150801','20160701'),
	(11,'2016/17','20160801','20170701'),
	(12,'2017/18','20170801','20180701'),
	(13,'2018/19','20180801','20190701'),
	(14,'2019/20','20190801','20200701'),
	(15,'2020/21','20200801','20210701'),
	(16,'2021/22','20210801','20220701'),
	(17,'2022/23','20220801','20230701'),
	(18,'2023/24','20230801','20240701')
)
AS Source ([SeasonKey], [SeasonName], [SeasonStartDate], [SeasonEndDate])
ON Target.[SeasonKey] = Source.SeasonKey
WHEN MATCHED THEN 
UPDATE SET [SeasonName] = Source.[SeasonName], [SeasonStartDate] = Source.[SeasonStartDate], [SeasonEndDate] = Source.[SeasonEndDate]
WHEN NOT MATCHED BY TARGET THEN 
INSERT ([SeasonKey], [SeasonName], [SeasonStartDate], [SeasonEndDate]) 
VALUES ([SeasonKey], [SeasonName], [SeasonStartDate], [SeasonEndDate])  
WHEN NOT MATCHED BY SOURCE THEN 
DELETE;

DECLARE @sScriptName VARCHAR(256) = N'PopulateDimSeason.sql';
DECLARE @sExecDate VARCHAR(32) = CONVERT(VARCHAR(32), GETDATE(), 126);                   
RAISERROR('*** %s - Finished at [%s] *** ' , 0, 1, @sScriptName, @sExecDate) WITH NOWAIT;
GO