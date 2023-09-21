------------------ EDITING THE MAP PICKED TABLE ------------------------

-- Query to see everything in the Map Picked Table
select * from ValorantProject.dbo.MapPicked;

-- Updating the Total Column to Total Times Picked
EXEC sp_rename 'mappicked.total', 'Total Time Picked', 'COLUMN';

-- There are duplicate rows in the Map Picked Table
-- Creating a CTE to remove the duplicates from a table
WITH CTE([Map],
	[Total Times Picked],
	[Group D],
	[Group B],
	[Group C],
	[Group A],
	[Playoffs],
	duplicatecount)
AS (Select [Map],
	[Total Times Picked],
	[Group D],
	[Group B],
	[Group C],
	[Group A],
	[Playoffs],
	Row_Number() Over(Partition by [Map],
								   [Total Times Picked],
								   [Group D],
								   [Group B],
								   [Group C],
								   [Group A],
								   [Playoffs]
	Order By [Total Times Picked]) as DuplicateCount
	From Valorantproject.dbo.Mappicked)

delete
from CTE
where duplicatecount > 1;

--select *
--from CTE

-- Updating the Group Column Names to Total Times Picked
EXEC sp_rename 'dbo.mappicked.[Group D]',  'Group D Picks', 'COLUMN';
EXEC sp_rename 'dbo.mappicked.[Group B]',  'Group B Picks', 'COLUMN';
EXEC sp_rename 'dbo.mappicked.[Group C]',  'Group C Picks', 'COLUMN';
EXEC sp_rename 'dbo.mappicked.[Group A]',  'Group A Picks', 'COLUMN';

-- Updating the Playoffs Coloumn
EXEC sp_rename 'dbo.mappicked.[playoffs]',  'Playoff Appearances', 'COLUMN';

------------------ EDITING THE MAP BANNED TABLE ------------------------

-- Query to see everything in the MapBanned Table	
select * from ValorantProject.dbo.MapBanned;

-- MappBanned table is showing a row with a blank map name. I'm going to remove it since there is no data here
delete from ValorantProject.dbo.MapBanned
where Map='-';

-- Updating the Total Column to Total Times Banned
EXEC sp_rename 'dbo.mapbanned.[Number of Times Banned]',  'Times Banned', 'COLUMN';

-- Updating the Group Column Names to Total Times Banned
EXEC sp_rename 'dbo.mapbanned.[Group D]',  'Group D Bans', 'COLUMN';
EXEC sp_rename 'dbo.mapbanned.[Group B]',  'Group B Bans', 'COLUMN';
EXEC sp_rename 'dbo.mapbanned.[Group C]',  'Group C Bans', 'COLUMN';
EXEC sp_rename 'dbo.mapbanned.[Group A]',  'Group A Bans', 'COLUMN';

-- Updating the Playoffs Coloumn
EXEC sp_rename 'dbo.mapbanned.[playoffs]',  'Playoff Bans', 'COLUMN';


------------------ EDITING THE MAP Side Statistics TABLE ------------------------

-- Query to see everything in the Side Statistics Table	
select * from ValorantProject.dbo.SideStatistics;

-- Adding a column that will say whether if a map is attack or defense sided
ALTER TABLE ValorantProject.dbo.SideStatistics
ADD Atk_Def_Sided varchar(255);

UPDATE ValorantProject.dbo.SideStatistics
SET Atk_Def_Sided =
    CASE 
        when dbo.SideStatistics.[Atk Wins] > dbo.SideStatistics.[Def Wins] then 'Attack Sided'
		else 'Defense Sided'
    END;

------------------ JOINING THE Map Banned, Map Picked, Side Statistics Tables ------------------------

-- Query to look at all tables. Trying to see the best column to join the tables on
select * from ValorantProject.dbo.MapPicked;
select * from ValorantProject.dbo.SideStatistics;
select * from ValorantProject.dbo.MapBanned;

use valorantProject

Select SideStatistics.Map, SideStatistics.[Atk Wins], SideStatistics.[Def Wins],
MapPicked.[Group A Picks], MapPicked.[Group B Picks], MapPicked.[Group C Picks], MapPicked.[Group D Picks], MapPicked.[Playoff Appearances],
MapBanned.[Group A Bans], MapBanned.[Group B Bans], MapBanned.[Group C Bans], MapBanned.[Group D Bans], MapBanned.[Playoff Bans]
From SideStatistics
left join MapPicked 
on SideStatistics.Map = MapPicked.Map
left join MapBanned
on SideStatistics.Map = MapBanned.Map


------------------ EDITING THE PLAYERSTATS TABLE ------------------------

Select * from PlayerStats;

-- Updating the K,D,A Column Names to Kills, Deaths, Assists
EXEC sp_rename 'dbo.playerstats.[K]',  'Kills', 'COLUMN';
EXEC sp_rename 'dbo.playerstats.[D]',  'Deaths', 'COLUMN';
EXEC sp_rename 'dbo.playerstats.[A]',  'Assists', 'COLUMN';

-- Updating the K/MAP,D/MAP,A/MAP, ACS/MAP Column Names to {Name} Per Map
EXEC sp_rename 'dbo.playerstats.[K/MAP]',  'Kills Per Map', 'COLUMN';
EXEC sp_rename 'dbo.playerstats.[D/MAP]',  'Deaths Per Map', 'COLUMN';
EXEC sp_rename 'dbo.playerstats.[A/MAP]',  'Assists Per Map', 'COLUMN';
EXEC sp_rename 'dbo.playerstats.[ACS/MAP]',  'ACS Per Map', 'COLUMN';


------------------------ COMBINING ALL OF THE MAP RELATED TABLES INTO ONE VIEW ------------------------------

Create View [Maps Stats] AS
Select SideStatistics.Map, SideStatistics.[Atk Wins], SideStatistics.[Def Wins],
MapPicked.[Group A Picks], MapPicked.[Group B Picks], MapPicked.[Group C Picks], MapPicked.[Group D Picks], MapPicked.[Playoff Appearances],
MapBanned.[Group A Bans], MapBanned.[Group B Bans], MapBanned.[Group C Bans], MapBanned.[Group D Bans], MapBanned.[Playoff Bans]
From SideStatistics
left join MapPicked 
on SideStatistics.Map = MapPicked.Map
left join MapBanned
on SideStatistics.Map = MapBanned.Map

select * From [Maps Stats]

------------------------ ALL TABLE QUERIES ------------------------------

select * from ValorantProject.dbo.MapPicked;
select * from ValorantProject.dbo.SideStatistics;
select * from ValorantProject.dbo.MapBanned;
Select * from PlayerStats;