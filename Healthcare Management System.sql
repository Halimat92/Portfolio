CREATE DATABASE Healthcare;

USE Healthcare;

SELECT * FROM Patients;
SELECT * FROM Conditions;
SELECT * FROM careplans;
SELECT * FROM Allergies;
SELECT * FROM Medications;
SELECT * FROM Immunization;
SELECT * FROM Procedures;
SELECT * FROM Observation;

UPDATE conditions
SET stop_date = '1982-01-26'
WHERE P_ID = '4A50C';

SELECT P_ID, DATEDIFF(STOP_DATE,START_DATE)
FROM CONDITIONS;

ALTER TABLE Patients DROP COLUMN Myunknowncolumn;

ALTER TABLE Careplans RENAME COLUMN ReasonDescription TO REASON_DESCRIPTION;
ALTER TABLE Careplans DROP COLUMN Reasoncode;

ALTER TABLE Allergies DROP COLUMN code;

ALTER TABLE Careplans RENAME COLUMN start TO START_DATE;
ALTER TABLE Careplans RENAME COLUMN STOP TO STOP_DATE;

ALTER TABLE CONDITIONS RENAME COLUMN start TO START_DATE;
ALTER TABLE CONDITIONS RENAME COLUMN STOP TO STOP_DATE;

ALTER TABLE Allergies RENAME COLUMN start TO START_DATE;
ALTER TABLE Allergies RENAME COLUMN STOP TO STOP_DATE;

UPDATE Patients
SET birth_date = STR_TO_DATE(birth_date, '%d/%m/%Y');
UPDATE Patients
SET death_date = STR_TO_DATE(death_date, '%d/%m/%Y');

UPDATE Conditions
SET START_DATE = STR_TO_DATE(START_DATE, '%d/%m/%Y');
UPDATE Conditions
SET STOP_DATE = STR_TO_DATE(STOP_DATE, '%d/%m/%Y');

UPDATE Careplans
SET START_DATE = STR_TO_DATE(START_DATE, '%d/%m/%Y');
UPDATE Careplans
SET STOP_DATE = STR_TO_DATE(STOP_DATE, '%d/%m/%Y');


UPDATE Allergies
SET START_DATE = STR_TO_DATE(START_DATE, '%d/%m/%Y');
UPDATE Allergies
SET STOP_DATE = STR_TO_DATE(STOP_DATE, '%d/%m/%Y');

ALTER TABLE  careplans
ADD CONSTRAINT care_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);


ALTER TABLE  conditions 
ADD CONSTRAINT cond_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);

ALTER TABLE  allergies
ADD CONSTRAINT ALLE_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);

ALTER TABLE  procedures
ADD CONSTRAINT PRO_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);

ALTER TABLE  immunization
ADD CONSTRAINT IMMU_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);

ALTER TABLE  Medications
ADD CONSTRAINT MED_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);

ALTER TABLE  observation
ADD CONSTRAINT OBS_FK
FOREIGN KEY (P_ID) REFERENCES Patients (P_ID);


--- Patient medical record patients
DROP VIEW IF EXISTS Medical_Records ;
CREATE VIEW Medical_Records AS
SELECT p.p_id,p.first_name, p.last_name, co.description AS condition_desc, ob.description AS observ_description, 
	 pro.description AS Procedure_desc, pro.reason AS Procedure_reason, ca.description AS careplan_desc,
	ca.reason_description AS careplan_reason, ca.start_date AS Care_Start,ca.stop_date AS Care_Stop, me.medication
FROM patients AS p
left JOIN conditions AS co ON p.p_id = co.p_id
left JOIN observation AS ob ON p.p_id = ob.p_id
left join procedures AS pro ON p.p_id = pro.p_id
left JOIN careplans AS ca ON  p.p_id = ca.p_id 
left JOIN medications AS me ON p.p_id = me.p_id;

SELECT * FROM Medical_Records ;
---- Top 5 people who stayed the longest in hopital
SELECT p_id, first_name, last_name, Care_Start, Care_Stop, careplan_desc, DATEDIFF(Care_Stop, Care_Start) AS days_stayed
FROM Medical_Records
ORDER BY days_stayed DESC
LIMIT 5;

-- Patients with long time illness. 
SELECT p_id, first_name, last_name, Care_Start, careplan_reason, Care_Stop, careplan_desc
FROM Medical_Records
WHERE care_stop IS NULL;


--- Top 3 most persistence allergies 
SELECT DISTINCT description AS Allergies, DATEDIFF(stop_date, start_date) AS Most_Persistent_Allergies
FROM Allergies
ORDER BY Most_Persistent_Allergies DESC
LIMIT 3; 

-- Max hospital cost (SUB QUERY)
SELECT p.p_id, p.first_name, p.last_name, p.healthcare_expenses
FROM Patients p
JOIN (
    SELECT MAX(healthcare_expenses) AS max_hospital_cost
    FROM Patients
) max_expenses
ON p.healthcare_expenses = max_expenses.max_hospital_cost;


-- Min time spent in hospital

DROP PROCEDURE Patient_info_with_Conditions;

DELIMITER //
CREATE PROCEDURE Patient_info_with_Conditions(IN p_id VARCHAR(100))
BEGIN
    SELECT p.p_id, p.first_name, p.last_name, p.race, p.ethnicity, p.birthplace, p.address, p.city, p.state, p.county,
		c.description AS condition_desc, a.description AS allergy, m.medication
    FROM Patients p
    JOIN Conditions c ON p.p_id = c.p_id
    JOIN Allergies a ON p.p_id = a.p_id
    JOIN Medications m ON p.p_id = m.p_id
    WHERE p.p_id = p_id;
END //
DELIMITER ;

-- since our parameter is variable we need to set it before calling
SET @patient_id = '2DC29';

-- let's call our stored procedure with the variable
CALL Patient_info_with_Conditions(@patient_id);


-- 	 create a stored procedure and demonstrate how it runs
-- All patients by a specific race to understand patient demographics

DELIMITER //

CREATE PROCEDURE PatientsByRace(
    IN raceName VARCHAR(20)
)
BEGIN
    SELECT *
    FROM patients
    WHERE race = raceName;
END //

DELIMITER ;

CALL PatientsByRace('black');
CALL PatientsByRace('white');
CALL PatientsByRace('asian');


-- Avg healthcare ecpenses
SELECT c.description AS condition_desc,
       ROUND(AVG(p.healthcare_expenses), 2) AS avg_healthcare_expenses
FROM Patients p
JOIN Conditions c ON p.p_id = c.p_id
GROUP BY c.description
HAVING AVG(p.healthcare_expenses) > 4000 ;


-- Create a function to calculate minimum time spent in the hospital
DROP FUNCTION  CalculateMinTimeInHospital;

DELIMITER //
CREATE FUNCTION CalculateMinTimeInHospital()
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE min_time DECIMAL(10, 2);

    SELECT MIN(DATEDIFF(stop_date, start_date))
    INTO min_time
    FROM Conditions;

    RETURN min_time;
END //
DELIMITER ;


SELECT CalculateMinTimeInHospital() AS min_time_spent_in_hospital;

-- Max time spent in hospital
DROP FUNCTION CalculateMaxTimeInHospital;

DELIMITER //
CREATE FUNCTION CalculateMaxTimeInHospital()
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE min_time_in_hospital DECIMAL(10, 2);
    
    SELECT MAX(DATEDIFF(stop_date,start_date))
    INTO min_time_in_hospital
    FROM Conditions
	WHERE p_id = p_id;

    RETURN min_time_in_hospital;
END //
DELIMITER ;

SELECT CalculateMaxTimeInHospital() AS maxn_time_spent_in_hospital;


-- Function to calculate outstanding balance
DROP FUNCTION Balance;

DELIMITER //
CREATE FUNCTION Balance(healthcare_expenses INT, healthcare_coverage FLOAT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE Patient_outstanding VARCHAR(50);
    DECLARE calculated_balance DECIMAL(10, 2);

    SET calculated_balance = healthcare_expenses - healthcare_coverage;

    IF healthcare_coverage >= healthcare_expenses THEN
        SET Patient_outstanding = 'Your fee has been covered';
    ELSE 
        SET Patient_outstanding = CONCAT('You have ', ROUND(calculated_balance, 2), ' balance to pay');
    END IF;

    RETURN Patient_outstanding;
END //
DELIMITER ;


SELECT p_id, first_name, last_name, healthcare_expenses, healthcare_coverage,
       balance(healthcare_expenses, healthcare_coverage) AS 'Outsanding Balance'
FROM patients;



-- Create a table to store event
CREATE TABLE monitor_patient_drug_usage_event (
    Event_ID INT NOT NULL AUTO_INCREMENT,
    Patient_ID VARCHAR(10) NOT NULL,
    Last_Update TIMESTAMP,
    PRIMARY KEY (Event_ID),
    FOREIGN KEY (Patient_ID) REFERENCES patients(P_ID)
);

-- Create the event to run the function every day
SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT patient_event
ON SCHEDULE EVERY 1 DAY
DO BEGIN
    INSERT INTO monitor_patient_drug_usage_event (Patient_ID, Last_Update)
    SELECT P_ID, NOW()
    FROM patients;
END //
DELIMITER ;


-- Select the patient information with personalized reminders
SELECT mhve.Event_ID, p.P_ID AS Patient_ID, p.first_name, p.last_name,
    CONCAT('Dear ', p.first_name, ' ', p.last_name, ', don''t forget to use your drug(s) today.') AS Reminder_Message
FROM monitor_patient_drug_usage_event mhve

JOIN patients p ON mhve.Patient_ID = p.P_ID
WHERE  p.P_ID IN ('2DC29', 'FCA31')
ORDER BY mhve.Event_ID;



-- Create trigger to delete patient record from immunization on patient's request.
DROP TRIGGER delete_patient_records;

DELIMITER //
CREATE TRIGGER delete_patient_records
AFTER DELETE ON patients
FOR EACH ROW
BEGIN
    DELETE FROM immunization WHERE p_id = OLD.p_id;
END;

//
DELIMITER ;

 
 DELETE FROM immunization WHERE P_ID = '1C0E9';

SELECT * FROM Medications;




