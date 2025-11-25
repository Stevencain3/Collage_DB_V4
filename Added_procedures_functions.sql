DELIMITER $$

CREATE FUNCTION get_full_name(p_people_id INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(255);

    SELECT CONCAT(first_name, ' ', last_name)
    INTO full_name
    FROM people
    WHERE people_id = p_people_id;

    RETURN full_name;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION dept_student_count(p_department_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT COUNT(*)
    INTO total
    FROM student s
    JOIN faculty f ON s.advisor_id = f.faculty_id
    WHERE f.department_id = p_department_id;

    RETURN total;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE add_new_student(
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_date_of_birth DATE,
    IN p_gender VARCHAR(45),
    IN p_address VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_gpa DECIMAL(3,2),
    IN p_advisor_id INT
)
BEGIN
    -- Insert into people
    INSERT INTO people (first_name, last_name, email, date_of_birth, gender, address, phone_number)
    VALUES (p_first_name, p_last_name, p_email, p_date_of_birth, p_gender, p_address, p_phone);

    -- Insert into student using the new people_id
    INSERT INTO student (people_id, cumulative_gpa, advisor_id)
    VALUES (LAST_INSERT_ID(), p_gpa, p_advisor_id);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_student(
    IN p_student_id INT
)
BEGIN
    DELETE FROM student 
    WHERE student_id = p_student_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE enroll_student_locked(
    IN p_student_id INT,
    IN p_course_offering_id INT,
    IN p_letter_grade_id INT
)
BEGIN
    START TRANSACTION;

    -- Lock the enrollment table row for this student & offering
    SELECT * FROM enrollment
    WHERE student_id = p_student_id
      AND course_offering_id = p_course_offering_id
    FOR UPDATE;

    -- Insert enrollment
    INSERT INTO enrollment (letter_grade_id, student_id, course_offering_id)
    VALUES (p_letter_grade_id, p_student_id, p_course_offering_id);

    COMMIT;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE update_faculty_assignment_locked(
    IN p_faculty_id INT,
    IN p_new_department_id INT
)
BEGIN
    START TRANSACTION;

    SELECT * FROM faculty 
    WHERE faculty_id = p_faculty_id
    FOR UPDATE;

    UPDATE faculty
    SET department_id = p_new_department_id
    WHERE faculty_id = p_faculty_id;

    COMMIT;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE add_new_course(
	p_course_code VARCHAR(255), -- parameters for new course
	p_course_title VARCHAR(255),  -- 'p' = procedure
	p_credits INT, 
	p_department_id INT
)
BEGIN

	-- invalid message that pops up if something is invalid
	DECLARE invalid_message VARCHAR(255);
    
    -- these are validation checks that check if parameters are empty
    IF p_course_code IS NULL OR p_course_code = '' THEN 
		SET invalid_message = 'Course code must be filled';
	ELSEIF p_course_title IS NULL OR p_course_title = '' THEN 
		SET invalid_message = 'Course title must be filled';
	ELSEIF p_credits IS NULL OR p_credits = '' THEN 
		SET invalid_message = 'Credits must be filled';
	ELSEIF p_department_id IS NULL OR p_department_id = '' THEN 
		SET invalid_message = 'Credits must be filled';
	END IF;
	
    -- if invalid message is null, proceed to create new course
    IF invalid_message IS NULL THEN
		INSERT INTO course (course_code, course_title, credits, department_id)
		VALUES (p_course_code, p_course_title, p_credits, p_department_id);
	ELSE 
		-- if it isn't null, error message. IDK
		SELECT invalid_message AS error_message;
	END IF;
END $$

DELIMITER ; 

DELIMITER $$

CREATE PROCEDURE delete_course(
	IN p_course_id INT, -- parameter to delete course
    OUT p_message VARCHAR (255) -- input output thing with validation
)
BEGIN
	-- counter that will validate if course already exists or doesn't
	DECLARE course_id_counter INT;
    
    -- Error message for validation. Just read the code.
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET p_message = 'Error: An Error Occurred. Check Error Number.';
	END;
    
    SELECT COUNT(*) INTO course_id_counter -- increment the counter in course and find given p_course_code
    FROM course
    WHERE course_id = p_course_id;
    
    IF course_id_counter = 0 THEN
		SET p_message = 'Error: Course Does Not Exist.';
	ElSE
		-- go ahead and delete this course			    
		DELETE FROM course WHERE course_id = p_course_id;
        SET p_message = 'Course Deleted Successfully!';
	END IF;
END $$

DELIMITER ; 

DELIMITER $$
CREATE FUNCTION get_advisor_by_student(
    p_student_id INT -- giving student's ID to get the advisor 
)
RETURNS VARCHAR(255)-- idk why I need this but it does return a varchar
DETERMINISTIC
BEGIN
DECLARE advisor_name VARCHAR(255); -- this will store the advisor's name 
    SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name -- concat so that we can see full name 
    INTO advisor_name -- store that name into this 
    FROM student s
    JOIN faculty f 
        ON s.advisor_id = f.faculty_id -- joining the tables was a bit painful. But I started from student
    JOIN people p                      -- made my way to faculty, then from faculty to people
        ON f.people_id = p.people_id
    WHERE s.student_id = p_student_id; -- filter to get the student's selected advisor where the student = student searched/

    RETURN advisor_name;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION get_department_name_by_course(
p_course_title VARCHAR(255) -- giving course's title to get the department 
)
RETURNS VARCHAR(255) -- idk why I need this but it does return a varchar
DETERMINISTIC
BEGIN
DECLARE dep_name VARCHAR(255); -- this will store the department's name by 
    SELECT d.department_name
    INTO dep_name
    FROM course c
    JOIN department d ON c.department_id = d.department_id
    WHERE c.course_title = p_course_title;
    RETURN dep_name;
    
END$$
DELIMITER ;

    -- so this is how I can explain it. 
    -- you're selectinbg the department name from department and putting it into dep_name
    -- but in order to get it through a course, you need to join the tables by their common
    -- index which is the deparment ID. So you're basically creating a bridge in between the 
    -- tables. If you join them by deparment ID, each of the tables can access each other.
	-- The where clause is essentially a filter so that you ask for a specific department.
    -- So it's like "give me the department where this course is equal to user input"
    -- w/o it, you basically get multiple rows for one answer. 


DELIMITER $$
CREATE FUNCTION f_student_credits_taken(
    p_student_id INT -- giving student's ID to get the credits 
)
RETURNS VARCHAR(255)-- idk why I need this but it does return a varchar
DETERMINISTIC
BEGIN
DECLARE credits_taken INT DEFAULT 0; -- this will be the sum of credits and it's default is 0
    SELECT SUM(c.credits)
    INTO credits_taken -- store the sum of the credits 
    FROM enrollment e
    JOIN course_offering co
        ON e.course_offering_id = co.course_offering_id -- joining these tables on course_offering_id to access each other's data
    JOIN course c                     -- made my way to course from course offering table
        ON c.course_id = co.course_id
    WHERE e.student_id = p_student_id; -- I want this student's credits, not all.

    RETURN credits_taken; -- return credits
END$$
DELIMITER ;