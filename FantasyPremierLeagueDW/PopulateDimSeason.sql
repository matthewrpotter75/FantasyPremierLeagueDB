PRINT 'Updating dbo.DimSeason';

MERGE INTO dbo.DimSeason AS Target 
USING 
(
	VALUES 
	--(1,'2016/17','2016-08-01','2017-06-01'),
	--(2,'2017/18','2017-08-01','2018-06-01')
	(1,'2006/07','20060801','20070601'),
	(2,'2007/08','20070801','20080601'),
	(3,'2008/09','20080801','20090601'),
	(4,'2009/10','20090801','20100601'),
	(5,'2010/11','20100801','20110601'),
	(6,'2011/12','20110801','20120601'),
	(7,'2012/13','20120801','20130601'),
	(8,'2013/14','20130801','20140601'),
	(9,'2014/15','20140801','20150601'),
	(10,'2015/16','20150801','20160601'),
	(11,'2016/17','20160801','20170601'),
	(12,'2017/18','20170801','20180601')
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