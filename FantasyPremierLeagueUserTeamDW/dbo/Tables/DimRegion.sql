CREATE TABLE dbo.DimRegion
(
	RegionKey INT NOT NULL,
	RegionName VARCHAR(100) NULL,
	RegionISOCode VARCHAR(3) NULL,
	RegionId INT NOT NULL,
	CONSTRAINT PK_DimRegion PRIMARY KEY CLUSTERED (RegionKey ASC)
)
GO