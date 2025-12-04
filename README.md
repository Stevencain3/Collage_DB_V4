# College_Database_V4
![MySQL](https://img.shields.io/badge/Database-MySQL-blue)
![Status](https://img.shields.io/badge/Version-4.0-success)
![Workbench](https://img.shields.io/badge/Workbench-Compatible-orange)


## What is This Database?
The **College_Database_V4** is a MySQL-based relational database designed to support a basic college’s academic and administrative operations.
It stores and organizes information about students, faculty, administrators, courses, rooms, semesters, and enrollment data — allowing for efficient management of people, schedules, and academic records. 


The database is designed to track:

- General people records  
- Student, faculty, and staff details  
- Academic departments  
- Courses and semester offerings  
- Enrollment and student grades  
- Rooms and scheduling  

---

## Table of Contents
1. [Description](#what-is-this-database)
2. [EER Diagram](#eer-diagram)
3. [Tables and Descriptions](#tables-and-descriptions)
4. [Views](#views)
5. [Stored Procedures](#stored-procedures)
6. [Stored Functions](#stored-functions)
7. [Locking Transactions](#locking-transactions)
8. [Triggers](#triggers)
9. [Trigger Testing](#Trigger-Testing)
10. [Developers](#developers)

---
## EER Diagram 

<img width="543" height="373" alt="image" src="https://github.com/user-attachments/assets/6aed9a3b-4f54-4bab-85b3-31a59a2422af" />

---


## Tables and Descriptions

| Table Name | Purpose / Description |
|------------|------------------------|
| **[people](#1-people)** | Table storing general personal information for every individual in the system. |
| **[student](#2-student)** | Extends `people` with student-specific details such as GPA and advisor. |
| **[faculty](#3-faculty)** | Extends `people` to store faculty information including department and office location. |
| **[staff](#4-staff)** | Extends `people` to represent non-faculty employees (administrative & support staff). |
| **[department](#5-department)** | Stores academic departments such as "Computer Science" or "Mathematics". |
| **[course](#6-course)** | Contains general information about courses (title, code, credit hours). |
| **[course_offering](#7-course_offering)** | Represents a specific instance of a course taught during a semester, including room and faculty. |
| **[semester](#8-semester)** | Stores semester terms (e.g., Fall 2025). |
| **[room](#9-room)** | Contains room and building information for scheduling classes. |
| **[enrollment](#10-enrollment)** | Records which students are enrolled in which course offerings, including grades. |
| **[letter_grade](#11-letter_grade)** | Defines the grading scale (A, B+, etc.) with min/max score thresholds. |


---
##  Database Tables

Below is a summary of all tables and their columns.

---

### **1. `people`**
Stores general personal information.

| Column         | Description        |
|----------------|--------------------|
| people_id      | Primary identifier |
| first_name     | First name         |
| last_name      | Last name          |
| email          | Email address      |
| date_of_birth  | Date of birth      |
| gender         | Gender             |
| address        | Home address       |
| phone_number   | Contact number     |

---

### **2. `student`**
Extends base `people` information for students.

| Column         | Description              |
|----------------|--------------------------|
| student_id     | Student identifier       |
| people_id      | FK → people              |
| cumulative_gpa | Overall GPA              |
| advisor_id     | FK → faculty             |

---

### **3. `faculty`**

| Column          | Description            |
|-----------------|------------------------|
| faculty_id      | Faculty identifier     |
| people_id       | FK → people            |
| department_id   | FK → department        |
| office_location | Office location        |

---

### **4. `staff`**

| Column        | Description           |
|---------------|-----------------------|
| staff_id      | Staff identifier      |
| people_id     | FK → people           |
| department_id | FK → department       |
| staffcol      | Additional attribute  |

---

### **5. `department`**

| Column         | Description |
|----------------|-------------|
| department_id  | Identifier  |
| department_name| Name        |

---

### **6. `course`**

| Column       | Description      |
|--------------|------------------|
| course_id    | Identifier       |
| course_code  | Code (e.g., CS101) |
| course_title | Title            |
| credits      | Credit hours     |

---

### **7. `course_offering`**

| Column             | Description              |
|--------------------|--------------------------|
| course_offering_id | Identifier               |
| course_id          | FK → course              |
| semester_id        | FK → semester            |
| room_id            | FK → room                |
| faculty_id         | FK → faculty             |
| schedule           | Meeting days/times       |

---

### **8. `semester`**

| Column       | Description         |
|--------------|---------------------|
| semester_id  | Identifier          |
| semester_term| e.g., Fall 2025     |

---

### **9. `room`**

| Column       | Description        |
|--------------|--------------------|
| room_id      | Identifier         |
| room_number  | Room number        |
| building     | Building name      |
| capacity     | Seating capacity   |

---

### **10. `enrollment`**

| Column             | Description            |
|--------------------|------------------------|
| enrollment_id      | Identifier             |
| enrollment_date    | Date enrolled          |
| enrollment_modified| Last modification date |
| letter_grade_id    | FK → letter_grade      |
| student_id         | FK → student           |
| course_offering_id | FK → course_offering   |

---

### **11. `letter_grade`**

| Column          | Description          |
|-----------------|----------------------|
| letter_grade_id | Identifier           |
| grade           | e.g., A, B+          |
| min_score       | Minimum percentage   |
| max_score       | Maximum percentage   |

---


## Views 

| View Name | Description |
|-------------|-------------|
| **course_offering_summary** | A summary of each course offering, including course, semester, room, and faculty info. |
| **course_summary** | Basic course info like title, code, and credits. | 
| **enrollment_summary** | Shows student enrollments, course offerings, and grades in one place. |
| **faculty_summary** | Quick view of faculty information, including department and office. |
| **people_summary** | A combined look at all people in the system with their general info. | 
| **staff_summary** | Summary of staff members, with their job title and their assigned departments. |
| **student_summary** | Overview of students, their GPAs, and advisor info. | 
---

## Stored Procedures
| Stored Procedure | What It Does | 
|------------------|--------------|
| **Add a new student** | Adds a new student and their basic info into the system. |  
| **Delete a student** | Removes a student and any related data. |
| **Update a student's GPA** | Updates a student’s GPA. |
| **Add a new course** | Creates a new course in the system. | 
| **Delete a course** | Deletes a course and anything tied to it. |  

--- 

## Stored Functions
| Stored Function | What It Returns |
|-----------------|-----------------|
| **Get full name of a person** | Combines first and last name into one value. | 
| **Calculate total students in a department** | Returns how many students belong to a department. | 
| **GPA validation** | validates a students gpa and returns either an error msg or if the gpa can be used | 
| **Get department name by course** | Returns which department a course belongs to. | 
| **Make System User Id** | Generates a unique system user id based on a person's name, using prefix + numeric suffix pattern (e.g., dejohn01, dejohn02). |
| **Make Campus Email** | Creates a standardized WSC email address based on the generated system userid (e.g., dejohn01@wsc.edu). |

---

 ## Locking Transactions
| Locking Transaction | What It Does |
|----------------------|--------------|
| **Enroll a student with a lock** | Enrolls a student safely without conflicts or double-enrolling. | 
| **Update faculty assignment** | Changes which faculty member teaches a course offering. | 
| **Update a student's GPA** | Updates a student’s GPA, but validates the gpa to ensure safe updating |
| **Update a room's capacity** | Changes the max capacity of a classroom. | 
| **Delete a department and its courses** | Deletes a department and all related courses safely. |

---
 ## Triggers
| Trigger                          | What It Does                                                                                                                      |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **trg_people_userid**            | Automatically generates a unique `system_user_id` and `campus_email` for each new person (e.g., `stcain01` → `stcain01@wsc.edu`). |
| **trg_cumulative_gpa_before**    | Validates GPA format (X.Y) and ensures GPA is between 0.0–4.0 before insertion; also sets `audit_user_id` from `CURRENT_USER()`.  |
| **trg_student_gpa_audit_insert** | Logs newly inserted student GPAs into the `student_gpa_audit` table.                                                              |
| **trg_student_gpa_audit_update** | Records GPA changes by inserting old and new GPA values into the GPA audit table after updates.                                   |
| **trg_course_code_validation**   | Ensures the `course_code` follows the required pattern (AAA###: 3 letters + 3 digits).                                            |
| **Course Audit Triggers**        | Logs course INSERT, UPDATE, and DELETE actions into `course_audit` for historical tracking.                                       |
| **Monthly Audit Cleanup Events** | Scheduled events that automatically truncate `course_audit` and `student_gpa_audit` every month.                                  |

## Trigger Testing
| Test                   | Expected Result                                           |
| ---------------------- | --------------------------------------------------------- |
| **Insert new person**  | Generates `system_user_id` and `campus_email`.            |
| **Insert valid GPA**   | Student added successfully and an audit row is recorded.  |
| **Insert invalid GPA** | Trigger blocks insertion with an error message.           |
| **Update GPA**         | Inserts audit row showing old and new GPA values.         |
| **Insert course_code** | Accepts only values in the format AAA###; rejects others. |



## Developers

 **Tyler Lucas**  
- **GitHub Profile**: [TylerLucas1](https://github.com/TylerLucas1)  
- **Email**: [tyluca01@wsc.edu](mailto:tyluca01@wsc.edu)  




 **Steven Cain**  
- **GitHub Profile**: [Stevencain3](https://github.com/Stevencain3)  
- **Email**: [stcain01@wsc.edu](mailto:stcain01@wsc.edu)  
