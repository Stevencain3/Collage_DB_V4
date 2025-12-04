DELIMITER //


-- Builds a unique system_user_id based on first and last name.
-- Adds a numeric suffix if another user already has the same base ID.
CREATE FUNCTION make_system_user_id(
    f_name VARCHAR(50),
    l_name VARCHAR(50)
)
RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
    DECLARE base_id     VARCHAR(50);
    DECLARE max_userid  VARCHAR(50);
    DECLARE max_suffix  INT DEFAULT 0;
    DECLARE new_userid  VARCHAR(50);

    -- Build base prefix (first 2 letters of first name + first 4 of last name)
    SET base_id = CONCAT(
        LOWER(LEFT(f_name, 2)),
        LOWER(LEFT(l_name, 4))
    );

    
     -- Get most recent user_id matching this prefix to determine next number.
		SELECT system_user_id
        INTO max_userid
        FROM people
        WHERE system_user_id LIKE CONCAT(base_id, '%')
        ORDER BY system_user_id DESC
        LIMIT 1;

   
    -- grabs the numeric suffix and increments it
 
    IF max_userid IS NULL THEN
        SET max_suffix = 1;
    ELSE
        SET max_suffix = CAST(
            SUBSTRING(max_userid, LENGTH(base_id) + 1)
            AS UNSIGNED
        ) + 1;
    END IF;

  
    -- Build final userid (prefix + 2-digit number)

    SET new_userid = CONCAT(base_id, LPAD(max_suffix, 2, '0'));

    RETURN new_userid;
END//

DELIMITER ;


-- Automatically generates system_user_id and campus_email before insert.
-- Uses the make_system_user_id() function to ensure same number suffex isnt reused.
DELIMITER //

CREATE TRIGGER trg_people_userid
BEFORE INSERT ON people
FOR EACH ROW
BEGIN
    DECLARE v_userid VARCHAR(50);

    -- Call your function to generate userid
    SET v_userid = make_system_user_id(NEW.first_name, NEW.last_name);

    SET NEW.system_user_id = v_userid;
    SET NEW.campus_email = CONCAT(v_userid, '@wsc.edu');

END//

DELIMITER ;

-- test cases
-- adding two of the same student names (me) to see if the incrementation works
CALL add_new_student(
    'Steven',
    'Cain',
    'stevencain57@gmail.com',
    '2002-08-20',
    'm',
    '123 Test St',
    '555-5555',
    3.8,
    2
);

CALL add_new_student(
    'Steven',
    'Cain',
    'stevencain58@gmail.com',
    '2005-09-20',
    'm',
    '1108 Main St',
    '555-5555',
    4.0,
    2
);

-- shows the incrementation works!
SELECT system_user_id, campus_email FROM af25stevc1_collegedb_v4.people
where system_user_id is not null;
