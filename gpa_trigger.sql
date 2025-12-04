USE af25stevc1_collegeDB_V4;
-- Drops my triggers because I had to change them
DROP TRIGGER IF EXISTS trg_cumulative_gpa_before;
DROP TRIGGER IF EXISTS trg_student_gpa_audit_insert;
DROP TRIGGER IF EXISTS trg_student_gpa_audit_update;

-- Validates GPA format (X.Y between 0.0 and 4.0) before inserting a student.
-- Also sets audit_user_id to the first part of CURRENT_USER().
Delimiter //
create TRIGGER trg_cumulative_gpa_before
Before insert on student
for each row
begin 
	IF NOT (NEW.cumulative_gpa REGEXP '^[0-4]\\.[0-9]$'
        AND NEW.cumulative_gpa <= 4.0) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'GPA must be a decimal between 0.0 and 4.0 (format X.Y)';
	END IF;
    
     SET NEW.audit_user_id = SUBSTRING_INDEX(CURRENT_USER(), '@', 1);
     
END//
DELIMITER ;

-- Creates an audit entry whenever a new student is inserted.
-- Logs the new GPA value with action_type = 'INSERT'.
Delimiter //
CREATE TRIGGER trg_student_gpa_audit_insert
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_gpa_audit (
        student_id,
        action_type,
        cumulative_gpa ,
        new_student_gpa
    )
    VALUES (
        NEW.student_id,       -- this exists on student table
        'INSERT',
        NULL,                 -- no old GPA on insert
        NEW.cumulative_gpa
    );
END//
DELIMITER ;


-- Logs GPA updates by recording old and new GPA values.
-- Only inserts an audit record if the GPA actually changes.
DELIMITER //
CREATE TRIGGER trg_student_gpa_audit_update
AFTER UPDATE ON student
FOR EACH ROW
BEGIN
    IF OLD.cumulative_gpa <> NEW.cumulative_gpa THEN
        INSERT INTO student_gpa_audit (
            student_id, action_type, cumulative_gpa, new_student_gpa
        )
        VALUES (
            NEW.student_id, 'UPDATE', OLD.cumulative_gpa, NEW.cumulative_gpa    
        );
    END IF;
END//

DELIMITER ;

-- Monthly cleanup for student GPA audit
CREATE EVENT ev_student_gpa_audit_monthly_cleanup
ON SCHEDULE EVERY 1 MONTH
DO
    TRUNCATE TABLE student_gpa_audit;


---TEST CASES

-- Should work:
CALL add_new_student(
    'Steven',
    'Cain',
    'stcain01@wsc.edu',
    '2002-08-20',
    'm',
    '123 Test St',
    '555-5555',
    3.7,
    2
);
-- Should work:
UPDATE student
SET cumulative_gpa = 3.8
WHERE student_id = 1007;

SELECT *
FROM student_gpa_audit;

-- Should FAIL: direct insert with invalid GPA
INSERT INTO student (people_id, cumulative_gpa, advisor_id)
VALUES (1, 5.0, 2);

-- Should FAIL: negative GPA
CALL add_new_student(
    'Bad',
    'Negative',
    'bad4@example.com',
    '2000-01-01',
    'f',
    '000 Bad St',
    '555-0004',
    -1.0,
    2
);

-- Should FAIL: GPA has 2 decimal places (3.75)
CALL add_new_student(
    'Bad',
    'TwoDecimals',
    'bad2@example.com',
    '2000-01-01',
    'f',
    '456 Bad St',
    '555-0002',
    3.75,
    2
);

-- Should FAIL: GPA is above 4.0
CALL add_new_student(
    'Bad',
    'TooHigh',
    'bad3@example.com',
    '2000-01-01',
    'm',
    '789 Bad St',
    '555-0003',
    4.5,
    2
);

