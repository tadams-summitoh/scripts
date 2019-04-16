--collect database sizes

use master
IF OBJECT_ID('dbinfo') IS NULL
  EXEC ('Create Table dbInfo (dId smallint, dbName sysname, gId smallint NULL, segName varchar(256) NULL, 
       filName varchar(520) NULL, sizeMg decimal(10,2) null, 
       usedMg decimal(10,2) null, freeMg decimal(10,2) null, 
       pcntUsed decimal(10,2) null, pcntFree decimal(10,2) null);');

Declare @sSql varchar(1000)
if object_id('dbinfo') is not null
  exec ('truncate table dbInfo;');
Set @sSql = 'Use [?];
Insert master..dbinfo (dId, dbName, gid, segName, filName, sizeMg, usedMg)
Select db_id(), db_name(), groupid, rtrim(name), filename, Cast(size/128.0 As Decimal(10,2)), 
Cast(Fileproperty(name, ''SpaceUsed'')/128.0 As Decimal(10,2))
From dbo.sysfiles Order By groupId Desc;'
Exec sp_MSforeachdb @sSql
Update dbInfo Set freeMg = sizeMg - usedMg, pcntUsed = (usedMg/sizeMg)*100, pcntFree = ((sizeMg-usedMg)/sizeMg)*100

--retrieve database info
if object_id('database_info') is not null
	exec ('truncate table database_info;');

--insert database_info (DBName, RecoveryModel, CompatiblityLevel, create_date, [MDF_Used(in MB)], [LDF_Used(in MB)], LastBackupCompleted, state_desc, Date_Retrieved)
SELECT  d.name AS DBName ,
	    recovery_model_Desc AS RecoveryModel ,
	    d.Compatibility_level AS CompatiblityLevel ,
	    create_date ,
		mdf.usedMG [MDF_Used(in MB)],
		ldf.usedMG [LDF_Used(in MB)],
		MAX(b.backup_finish_date) AS LastBackupCompleted, 
	    state_desc, getdate() as Date_Retrieved
into database_info
FROM    sys.databases d
Left JOIN dbinfo MDF on d.database_id = mdf.DID and mdf.gId = 1
left JOIN dbinfo LDF on d.database_id = ldf.DID and ldf.gID = 0
LEFT OUTER JOIN msdb..backupset b
	    ON b.database_name = d.name
	                    AND b.[type] = 'D'
group by d.name, recovery_model_desc, d.compatibility_level,create_date,state_desc, mdf.usedmg, ldf.usedmg
ORDER BY d.Name; 