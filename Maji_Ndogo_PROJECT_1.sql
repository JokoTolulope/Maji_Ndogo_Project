/*MCQ SQL PROJECT 1*/

USE md_water_services;

SHOW TABLES;
/*Selecting the first 5 rows of each table to get familiar with the dataset.*/
SELECT *
FROM data_dictionary
LIMIT 5;

SELECT *
FROM employee
LIMIT 5;

SELECT *
FROM global_water_access
LIMIT 5;

SELECT *
FROM location
LIMIT 5;

SELECT *
FROM visits
LIMIT 5;

SELECT *
FROM water_quality
LIMIT 5;

SELECT *
FROM water_source
LIMIT 5;

SELECT *
FROM well_pollution
LIMIT 5;

/* Retrieving all unique type of water sources*/
SELECT DISTINCT type_of_water_source
FROM water_source;

/* Retrieving all records of visits where the time in queue is more than 500 minutes*/
SELECT *
FROM visits
WHERE time_in_queue > 500;
/*Retrieving all records without the where clause to take note of zero minute time in queue also*/
SELECT *
FROM visits;

/* finding the source_id in the water resource table to take note of the type of water source causing so much delay*/
SELECT *
FROM water_source
WHERE source_id IN ('AkKi00881224',
                  'SoRu37635224',
                  'SoRu36096224',
                  'AkRu05234224',
                  'HaZa21742224',
                  'AkLu01628224',
                  'HaRu19601224',
                  'SoRu38776224');
                  
/* Retrieving records of water quality score and the number of visits*/
SELECT *
FROM water_quality
WHERE subjective_quality_score = 10 AND
	  visit_count > 1;

/*Retrieving records of well pollution where the results shows 'clean' and the biological is greater than 0.01
to confirm there are no inconsistencies in the results*/      
SELECT *
FROM well_pollution
WHERE results = 'Clean' AND biological > 0.01;

/*RETRIEVING RECORDS TO SHOWS THE NUMBER OF WELLS THAT ARE CLEAN FROM THE TOTAL NUMBER OF WELLS SURVEYED(17383)*/
SELECT *
FROM well_pollution
WHERE results = 'Clean' AND biological < 0.01;

/*Retrieving records of well polution that have incorrect decription staring with "clean"*/
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean%_';

/*Testing the update queries out on a new created copy table to be sure there are no errors in our query*/
CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);

SET SQL_SAFE_UPDATES = 0;
UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';

UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy
SET results = 'contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

/*Update descriptions that mistakenly mention Clean Bacteria: E. coli to Bacteria: E. coli on the original well pollution table*/
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

SELECT *
FROM well_pollution
WHERE description LIKE 'Clean%_';

SELECT *
FROM well_pollution
WHERE biological > 0.01 AND results = 'Clean';

SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%' OR (biological > 0.01 AND results = 'Clean');

/* dropped the created copy table of well pollution*/
DROP TABLE well_pollution_copy;

