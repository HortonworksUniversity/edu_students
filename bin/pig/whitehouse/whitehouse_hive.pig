--wh_house.pig: transforms visits.txt for a Hive table

visits = LOAD '/user/centos/whitehouse/visits.txt' USING PigStorage(',');

potus = FILTER visits BY $19 MATCHES 'POTUS';

project_potus = FOREACH potus GENERATE
   (chararray) $0 AS lname,
   (chararray) $1 AS fname,
   (chararray) $6 AS time_of_arrival,
   (chararray) $11 AS appt_scheduled_time,
   (chararray) $21 AS location,
   (chararray) $25 AS comment;

STORE project_potus INTO '/apps/hive/warehouse/wh_visits/';

--Validate using hdfs or Ambari File View
--hdfs dfs -ls /apps/hive/warehouse/wh_visits