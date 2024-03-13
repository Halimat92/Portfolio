use cyclistic;

SELECT * FROM january;
SELECT * FROM february feb;
SELECT * FROM march mar;
SELECT * FROM april apr;

ALTER TABLE january
ALTER COLUMN  ended_at smalldatetime;

ALTER TABLE february
ALTER COLUMN  ride_length TIME(0);

--- Maximum ride
SELECT  MAX(ride_length) AS Max_ride
FROM January;

SELECT  MAX(ride_length) AS Max_ride
FROM February;

SELECT  MAX(ride_length) AS Max_ride
FROM March;

SELECT  MAX(ride_length) AS Max_ride
FROM April;

--- Minimum ride
SELECT  MIN(ride_length) AS Min_ride
FROM January;

SELECT  MIN(ride_length) AS Min_ride
FROM February;

SELECT  MIN(ride_length) AS Min_ride
FROM March;

SELECT  MIN(ride_length) AS Min_ride
FROM April;


DROP VIEW IF EXISTS merge_table;
CREATE VIEW merge_table 
AS
SELECT ride_id, started_at, ended_at, membership_status, ride_length,day_of_week
FROM january 
union
SELECT ride_id, started_at, ended_at, membership_status, ride_length, day_of_week
FROM February
union
SELECT ride_id, started_at, ended_at, membership_status, ride_length, day_of_week
FROM march
union
SELECT ride_id, started_at, ended_at, membership_status, ride_length,day_of_week
FROM April;

SELECT *
FROM merge_table;

SELECT DISTINCT ride_length
FROM merge_table;


--- Maximum ride length vs membership 
SELECT  MAX(ride_length) AS Lowest_rider, membership_status
FROM merge_table
GROUP BY  membership_status;

--- Maximum ride length vs membership vs day
SELECT  MAX(ride_length) AS Higest_rider, membership_status,day_of_week
FROM merge_table
GROUP BY  membership_status, day_of_week;

--- Minimum ride length vs membership vs day
SELECT  MIN(ride_length) AS Lowest_rider, membership_status,day_of_week
FROM merge_table
GROUP BY  membership_status, day_of_week;


-- Day rider ride the lowest
SELECT membership_status, MIN(day_of_week)  AS AVG_day_ride
FROM merge_table
GROUP BY  membership_status;


--- Day rider ride the highest
SELECT membership_status, MAX(day_of_week)  AS AVG_day_ride
FROM merge_table
GROUP BY  membership_status;

-- Day rider ride on average
SELECT membership_status, AVG(day_of_week)  AS AVG_day_ride
FROM merge_table
GROUP BY  membership_status;



SELECT DISTINCT ride_length, membership_status
FROM merge_table;

SELECT DISTINCT ride_id AS ride_id_for_members
FROM merge_table
where membership_status = 'member';

SELECT DISTINCT ride_id AS ride_id_for_casual_members
FROM merge_table
where membership_status = 'casual';
  


 select time_to_seconds



