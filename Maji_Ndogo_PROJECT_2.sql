USE md_water_services;

/*Checking if any of the email row is filled or if everything is blank*/
SELECT *
FROM employee
WHERE email IS NOT NULL;

/*Updating the email column with this format: first_name.last_name@ndogowater.gov*/
SELECT employee_name,  /*Used REPLACE to change the space between the names to dot*/
 CONCAT(               /*Used LOWER to change the alphabets to lowercases, Used CONCAT to join everything together in a seperate column with the Alias*/
  LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
FROM employee;

/*Now using the created new_email and 
updating it permanentely in the employee table and in the email column*/
UPDATE employee
SET email = CONCAT(
                    LOWER(REPLACE(employee_name, ' ', '.')),
                    '@ndogowater.gov');
                    
/*To determine the length of the phone number*/
SELECT
LENGTH(phone_number)
FROM employee;

/*Used TRIM to correct the extra space in the phone number column*/
SELECT LENGTH(phone_number),
       TRIM(phone_number),
       LENGTH(TRIM(phone_number))
FROM employee;

/*Updating the phone number column using TRIM*/
UPDATE employee
SET phone_number = TRIM(phone_number);

/*Checking the employee address and grouping the number of employees byaddress and town name*/
SELECT employee_name, address
FROM employee;

SELECT COUNT(employee_name) AS number_of_employee_with_same_address,
       address
FROM employee
GROUP BY(address);

SELECT COUNT(employee_name) AS number_of_employee_in_a_town,
       town_name
FROM employee
GROUP BY(town_name);

SELECT *
FROM visits;

/*Checked for the number of times an employee visited and the top 3 employees with the largest total number of visits*/
SELECT COUNT(visit_count) AS number_of_times_employee_visited,
       assigned_employee_id
FROM visits
GROUP BY(assigned_employee_id)
ORDER BY COUNT(visit_count) DESC
LIMIT 3;

/*I checked for the number of employees that visited once, twices and so on...I also figured 
the highest visit count for a day is 8(i just tried the query out)*/
SELECT COUNT(assigned_employee_id),
       visit_count
FROM visits
GROUP BY(visit_count);

/*Retrieving information of the top 3 employees with the highest total no of visits*/
SELECT assigned_employee_id,
       employee_name,
       email,
       phone_number
FROM employee
WHERE assigned_employee_id IN(1, 30, 34);

SELECT *
FROM location;

/*Counting the number of records per town
to determine where most of the water source in the survey are situated*/
SELECT COUNT(location_id) AS number_of_records_per_town,
       town_name
FROM location
GROUP BY(town_name);

/*Counting the number of records per province
to determine where most of the water source in the survey are situated*/
SELECT COUNT(location_id) AS number_of_records_per_province,
       province_name
FROM location
GROUP BY(province_name);

/*counting number of records by both province and town*/
SELECT province_name,
       town_name,
	   COUNT(location_id) AS records_per_town
FROM location
GROUP BY province_name,
         town_name
ORDER BY province_name,
         COUNT(location_id) DESC;
         
/*Checked the number of records for each location type*/
SELECT COUNT(location_id) AS Records_per_location_type,
	   location_type
FROM location
GROUP BY location_type;

/*Calculating the percentage of records per location type*/
SELECT (23740/(15910 + 23740)) * 100 AS per_records_of_rural_per_location_type,
       (15910/(15910 + 23740)) * 100 AS per_records_of_urban_per_location_type;
       
SELECT *
FROM water_source;

/*Calculated the total number of people surveyed using the water source table*/
SELECT SUM(number_of_people_served) AS Total_people_surveyed
FROM water_source;

/*The number of wells, taps and rivers in the dataset*/
SELECT COUNT(source_id) AS no_of_sources,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source;

/*retrieving records on average number of people being served by a particular water source*/
SELECT COUNT(source_id) AS no_of_water_source,
       AVG(number_of_people_served) AS avg_no_of_people_served_by_the_source,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source;

/*Number of people served by  each type of water source*/
SELECT COUNT(source_id) AS no_of_water_source,
       SUM(number_of_people_served) AS no_of_people_served_by_the_source,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source;

/*Calculating the percentage of people served per water source type*/
SELECT *,
       (no_of_people_served_by_the_source/27628140) * 100 AS percentage_served
FROM 
      (SELECT COUNT(source_id) AS no_of_water_source,
       SUM(number_of_people_served) AS no_of_people_served_by_the_source,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source) AS subquery_alias;

/*Rounding the % off to zero decimal place*/
SELECT *,
       ROUND((no_of_people_served_by_the_source/27628140) * 100, 0) AS percentage_served
FROM 
      (SELECT COUNT(source_id) AS no_of_water_source,
       SUM(number_of_people_served) AS no_of_people_served_by_the_source,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source) AS subquery_alias;


/*Ranking the water source by thhe number of people served using the RANK windows function*/
SELECT type_of_water_source,
       SUM(number_of_people_served) AS no_of_people_served_by_the_source,
       RANK() OVER (PARTITION BY type_of_water_source
                    ORDER BY SUM(number_of_people_served) DESC) AS type_ranked_by_people_served
FROM water_source
GROUP BY source_id,
         type_of_water_source;

SELECT *,
       RANK() OVER (PARTITION BY type_of_water_source
                    ORDER BY no_of_people_served_by_the_source DESC) AS type_ranked_by_people_served
FROM 
      (SELECT COUNT(source_id) AS no_of_water_source,
       SUM(number_of_people_served) AS no_of_people_served_by_the_source,
       type_of_water_source
FROM water_source
GROUP BY type_of_water_source) AS subquery_alias;

SELECT type_of_water_source,
	   SUM(number_of_people_served) OVER(PARTITION BY type_of_water_source) AS no_people_served
       -- RANK() OVER(PARTITION BY type_of_water_source ORDER BY SUM(number_of_people_served) OVER(PARTITION BY type_of_water_source)) AS ranked
FROM water_source;

SELECT *,
	   DENSE_RANK() OVER(PARTITION BY type_of_water_source ORDER BY no_people_served) AS ranked
FROM (
       SELECT type_of_water_source,
	   SUM(number_of_people_served) OVER(PARTITION BY type_of_water_source) AS no_people_served
FROM water_source) AS t;

SELECT type_of_water_source,
       SUM(number_of_people_served),
       RANK() OVER(ORDER BY SUM(number_of_people_served)DESC)
FROM water_source
GROUP BY type_of_water_source;