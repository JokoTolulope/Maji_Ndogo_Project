USE md_water_services;

/*Joining location table and water source table with the visits table 
to retrieve records of specific provinces, or towns where some sources are more abundant*/
SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       v.visit_count AS visit_count,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       l.location_id AS location_id,
       w.source_id AS source_id
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id;


/*To retrieve records of where the surveyors visited more than once to collect 
additional information but happend at the same location/source*/
SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       v.visit_count AS visit_count,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       l.location_id AS location_id,
       w.source_id AS source_id
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id
WHERE v.location_id = 'AkHa00103';

/*To correct the error in the previous result*/
SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       v.visit_count AS visit_count,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       l.location_id AS location_id,
       w.source_id AS source_id
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id
WHERE v.visit_count = 1;

/*Adding location type and time in queue columns to the result set*/
SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       l.location_type AS location_type,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       v.time_in_queue AS time_in_queue
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id
WHERE v.visit_count = 1;

/*Joining records from the well pollution table*/
SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       l.location_type AS location_type,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       v.time_in_queue AS time_in_queue,
       wp.results AS results
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id
LEFT JOIN well_pollution AS wp
ON v.source_id = wp.source_id
WHERE v.visit_count = 1;

/*Creating a view of the previous result set and calling it "combined analysis table"*/
CREATE VIEW combined_analysis_table AS
-- This view assemble data from different tables into one to simplify analysis
   SELECT l.province_name AS province_name,
       l.town_name AS town_name,
       l.location_type AS location_type,
       w.type_of_water_source AS type_of_water_source,
       w.number_of_people_served AS number_of_people_served,
       v.time_in_queue AS time_in_queue,
       wp.results AS results
FROM visits AS v
JOIN location AS l
ON v.location_id = l.location_id
JOIN water_source AS w
ON v.source_id = w.source_id
LEFT JOIN well_pollution AS wp
ON v.source_id = wp.source_id
WHERE v.visit_count = 1;

/*Creating a pivot table to break down our data into province/town and source type
inorder to understand where the problems are and where we need to improve*/
WITH province_totals AS (  -- This CTE calculate the number of population per province
     SELECT province_name,
            SUM(number_of_people_served) AS Total_pple_served
     FROM combined_analysis_table
     GROUP BY province_name)
SELECT ct.province_name,
-- These case statement create columns for each type of sources
-- The results are aggregated and percentages are calculated
        ROUND((SUM(CASE WHEN type_of_water_source = 'river'
       THEN number_of_people_served ELSE 0 END) * 100/ pt.Total_pple_served), 0) AS river,
       ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
       THEN number_of_people_served ELSE 0 END) * 100/ pt.Total_pple_served), 0) AS shared_tap,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
       THEN number_of_people_served ELSE 0 END) * 100/ pt.Total_pple_served), 0) AS tap_in_home,
       ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
       THEN number_of_people_served ELSE 0 END) * 100/ pt.Total_pple_served), 0) AS tap_in_home_broken,
       ROUND((SUM(CASE WHEN type_of_water_source = 'well'
       THEN number_of_people_served ELSE 0 END) * 100/ pt.Total_pple_served), 0) AS well
FROM combined_analysis_table AS ct
JOIN province_totals AS pt
     ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;

/*grouping by town name*/
WITH town_totals AS(  -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, 
       town_name, 
       SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals AS tt 
ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

/*Creating a temp table of the previous query*/
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS(  -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, 
       town_name, 
       SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals AS tt 
ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

SELECT *
FROM town_aggregated_water_access
ORDER BY shared_tap DESC;

SELECT *
FROM town_aggregated_water_access
WHERE province_name = 'Amanzi'
ORDER BY province_name;

/*Pulling out records of town with the highest ratio of people who have taps but have no running water*/
SELECT province_name,
       town_name,
       ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps,
       ROUND(tap_in_home / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_working_taps
FROM town_aggregated_water_access
WHERE ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) < 50
AND ROUND(tap_in_home / (tap_in_home_broken + tap_in_home) *100,0) < 50

/*Creating a table for the solution plan and progess check in for the employees*/
CREATE TABLE Project_progress (
                Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same source more than once in the future.*/
                source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist, and should refer to the source table. This ensures data integrity.*/
                Address VARCHAR(50), -- Street address
                Town VARCHAR(30),
                Province VARCHAR(30),
                Source_type VARCHAR(50),
                Improvement VARCHAR(50), -- What the engineers should do at that place
                Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.*/
              Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
              Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

/*Project progress query*/
SELECT location.address,
       location.town_name,
       location.province_name,
       water_source.source_id,
       water_source.type_of_water_source,
       well_pollution.results,
       CASE WHEN well_pollution.results LIKE '%Chemical%' THEN /*Improvement =*/ 'Install RO filter'
            WHEN well_pollution.results LIKE '%Bio%' THEN /*Improvement =*/ 'Install UV and RO filter'
            WHEN water_source.type_of_water_source = 'river' THEN /*Improvement =*/ 'Drill well'
            WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN /*Improvement =*/ CONCAT('Install', ' ', FLOOR(time_in_queue/30), ' ', 'taps nearby')
            WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN /*Improvement =*/ 'Diagnose local infrastructure'
            ELSE 'NULL' END AS Improvement
FROM water_source
LEFT JOIN well_pollution 
     ON water_source.source_id = well_pollution.source_id
INNER JOIN visits 
	 ON water_source.source_id = visits.source_id
INNER JOIN location 
     ON location.location_id = visits.location_id
WHERE visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
);

/*Inserting the above query into te progress table*/
INSERT INTO project_progress(
                              source_id,
                              Address,
                              Town,
                              Province,
                              Source_type,
                              Improvement)
SELECT water_source.source_id,
       location.address,
       location.town_name,
       location.province_name,
       water_source.type_of_water_source,
       CASE WHEN well_pollution.results LIKE '%Chemical%' THEN /*Improvement =*/ 'Install RO filter'
            WHEN well_pollution.results LIKE '%Bio%' THEN /*Improvement =*/ 'Install UV and RO filter'
            WHEN water_source.type_of_water_source = 'river' THEN /*Improvement =*/ 'Drill well'
            WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN /*Improvement =*/ CONCAT('Install', ' ', FLOOR(time_in_queue/30), ' ', 'taps nearby')
            WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN /*Improvement =*/ 'Diagnose local infrastructure'
            ELSE 'NULL' END AS Improvement
FROM water_source
LEFT JOIN well_pollution 
     ON water_source.source_id = well_pollution.source_id
INNER JOIN visits 
	 ON water_source.source_id = visits.source_id
INNER JOIN location 
     ON location.location_id = visits.location_id
WHERE visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
);

SELECT *
FROM project_progress;

/*SQLTEST 4*/
SELECT COUNT(Improvement)
FROM project_progress
WHERE Improvement LIKE '%Install UV%';

SELECT *
FROM town_aggregated_water_access
WHERE town_name 
ORDER BY province_name;

SELECT province_name,
       town_name,
       ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_broken_taps,
       ROUND(tap_in_home / (tap_in_home_broken + tap_in_home) *100,0) AS Pct_working_taps
FROM town_aggregated_water_access
WHERE ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *100,0) < 50
AND ROUND(tap_in_home / (tap_in_home_broken + tap_in_home) *100,0) < 50;

SELECT
project_progress.Project_id, 
project_progress.Town, 
project_progress.Province, 
project_progress.Source_type, 
project_progress.Improvement,
Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;
