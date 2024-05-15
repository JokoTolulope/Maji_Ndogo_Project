DROP TABLE IF EXISTS auditor_report;

/*Created auditor_report table in the maji ndogo water services database*/
CREATE TABLE auditor_report (
             location_id VARCHAR(32),
             type_of_water_source VARCHAR(64),
             true_water_source_score INT DEFAULT NULL,
             statements VARCHAR(255)
             );
             
SELECT *
FROM auditor_report;

/*want to retrieve records from both the auditor table and the water quality table to compare the water quality score recorded in each table*/
/*There's no connection btwn auditors table and water quality table to join the tables together*/
/*Joined the auditor's table with the visit table first since there's a link in the visit table to bothe auditors table and water quality table*/
SELECT a.location_id AS audit_location_id,
       a.true_water_source_score AS audit_water_source_score,
       v.record_id AS visit_record_id,
       v.location_id AS visit_location_id
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id;
   
/*further joined the water quality table and to retrieve only the records where the score in both tables are the same*/
SELECT a.location_id AS audit_location_id,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS type_of_water_source,
       v.record_id AS visit_record_id,
       v.location_id AS visit_location_id,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
WHERE a.true_water_source_score = w.subjective_quality_score AND
      v.visit_count = 1;

/*Retrieving the records that the water quality score is not the same*/
SELECT a.location_id AS audit_location_id,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS type_of_water_source,
       v.record_id AS visit_record_id,
       v.location_id AS visit_location_id,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1;
      
/*Joined the water source table to retrieve the surveyor's type of water source records*/
SELECT a.location_id AS audit_location_id,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score,
       v.record_id AS visit_record_id,
       v.location_id AS visit_location_id
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id;

/*retrieved records including the type of water source where the water source quality is not the same in both the auditor and water quality table*/
SELECT a.location_id AS audit_location_id,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score,
       v.record_id AS visit_record_id,
       v.location_id AS visit_location_id
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1;
      
/*Joining the assigned employee id from the visit table to the result set*/
SELECT a.location_id AS audit_location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       v.record_id AS visit_record_id,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1;

/*To retrieve the employees names from the employee table*/
SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1;
      
/*Creating a CTE*/
WITH Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
  SELECT COUNT(DISTINCT Assigned_employee_id) -- Retrieving the unique number of employees involved
  FROM Incorrect_records;
  
/*Retrieved each employees name and the number of times their name appeared in the record*/
WITH Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
  SELECT Employee_name,
         COUNT(Employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY Employee_name;

/*Embedding the previous query as a subquery to get the average number of mistakes*/
SELECT AVG(number_of_mistakes)
FROM (
       WITH Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
  SELECT Employee_name,
         COUNT(Employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY Employee_name
) AS Error_count;

/*Creating a view for the average error count per employee*/
CREATE VIEW  Avg_error_count_per_emp AS (
           SELECT AVG(number_of_mistakes)
FROM (
       WITH Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
  SELECT Employee_name,
         COUNT(Employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY Employee_name
) AS Error_count
);


/*Creating view for the Error count(number of mistakes per employee result)*/
CREATE VIEW Error_count AS(
       WITH Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
  SELECT Employee_name,
         COUNT(Employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY Employee_name
);

DROP VIEW IF EXISTS number_of_mistakes;

/*Comparing each employee error count with the average error count*/
SELECT Employee_name,
        number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes)
                            FROM error_count);
                            
/*Saved the Incorrect records as a view instead of a CTE*/
CREATE VIEW Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
);

SELECT *
FROM incorrect_records;

/*Creating a view for the result of employees with thire number of mistakes greater than the avg no of mistake*/
WITH suspect_list AS(
     SELECT Employee_name,
        number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes)
                            FROM error_count)
),
  -- SELECT Employee_name
  -- FROM suspect_list
  
  /*Added the statement column from the auditor's table to the Incorrect_records CTE, so as to retrieve the records of employees with above avg number of mistakes*/
   Incorrect_records AS(
     SELECT a.location_id AS Location_id,
       v.assigned_employee_id AS Assigned_employee_id,
       e.employee_name AS Employee_name,
       a.true_water_source_score AS audit_water_quality_score,
       a.type_of_water_source AS audit_type_of_water_source,
       s.type_of_water_source AS surveyor_type_water_source,
       w.subjective_quality_score AS employee_water_quality_score,
       a.statements AS statements
FROM auditor_report AS a
JOIN visits AS v
   ON a.location_id = v.location_id
JOIN water_quality AS w
ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
JOIN employee AS e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE a.true_water_source_score != w.subjective_quality_score AND
      v.visit_count = 1
)
   SELECT Employee_name,
          Location_id,
          statements
   FROM Incorrect_records
   WHERE Employee_name IN(SELECT Employee_name
                              FROM suspect_list)
	AND	 statements LIKE '%cash%';