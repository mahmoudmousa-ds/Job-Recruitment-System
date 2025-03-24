-- Create the database
CREATE DATABASE JobRecruitmentDB;
GO

-- Use the database
USE JobRecruitmentDB;
GO

-- Create the Company table
CREATE TABLE Company (
    company_id INT PRIMARY KEY IDENTITY(1,1),  -- Primary key with auto-increment
    name NVARCHAR(255) NOT NULL,  -- Company name
    location NVARCHAR(255),  -- Company location
    industry NVARCHAR(255),  -- Industry type
    website NVARCHAR(255)  -- Company website
);
GO

-- Create the Job table
CREATE TABLE Job (
    job_id INT PRIMARY KEY IDENTITY(1,1),  -- Primary key with auto-increment
    title NVARCHAR(255) NOT NULL,  -- Job title
    description TEXT,  -- Job description
    salary DECIMAL(10,2),  -- Salary
    company_id INT,  -- Foreign key referencing the Company table
    FOREIGN KEY (company_id) REFERENCES Company(company_id) ON DELETE CASCADE  -- Delete jobs if the associated company is deleted
);
GO

-- Create the Applicant table
CREATE TABLE Applicant (
    applicant_id INT PRIMARY KEY IDENTITY(1,1),  -- Primary key with auto-increment
    name NVARCHAR(255) NOT NULL,  -- Applicant's name
    email NVARCHAR(255) UNIQUE NOT NULL,  -- Email (must be unique)
    phone NVARCHAR(20),  -- Phone number
    resume_link NVARCHAR(255)  -- Resume link
);
GO

-- Create the Application table
CREATE TABLE Application (
    application_id INT PRIMARY KEY IDENTITY(1,1),  -- Primary key with auto-increment
    applicant_id INT,  -- Foreign key referencing the Applicant table
    job_id INT,  -- Foreign key referencing the Job table
    status NVARCHAR(50) CHECK (status IN ('Pending', 'Interview', 'Hired', 'Rejected')),  -- Application status with predefined values
    applied_date DATETIME DEFAULT GETDATE(),  -- Date of application (default to current date)
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id) ON DELETE CASCADE,  -- Delete applications if the applicant is deleted
    FOREIGN KEY (job_id) REFERENCES Job(job_id) ON DELETE CASCADE  -- Delete applications if the job is deleted
);
GO

-- Create the Interview table
CREATE TABLE Interview (
    interview_id INT PRIMARY KEY IDENTITY(1,1),  -- Primary key with auto-increment
    application_id INT,  -- Foreign key referencing the Application table
    interview_date DATETIME NOT NULL,  -- Interview date
    feedback TEXT,  -- Interview feedback
    result NVARCHAR(50) CHECK (result IN ('Accepted', 'Rejected')),  -- Interview result with predefined values
    FOREIGN KEY (application_id) REFERENCES Application(application_id) ON DELETE CASCADE  -- Delete interview records if the application is deleted
);
GO

-- Insert sample data into the Company table
INSERT INTO Company (name, location, industry, website) VALUES
('Microsoft', 'USA', 'Technology', 'https://www.microsoft.com'),
('Google', 'USA', 'Technology', 'https://www.google.com'),
('Amazon', 'USA', 'E-commerce', 'https://www.amazon.com');
GO

-- Insert sample data into the Job table
INSERT INTO Job (title, description, salary, company_id) VALUES
('Data Scientist', 'Analyze and interpret complex data.', 120000, 1),
('Software Engineer', 'Develop and maintain software applications.', 100000, 2),
('Cloud Engineer', 'Manage cloud-based infrastructure.', 110000, 3);
GO

-- Insert sample data into the Applicant table
INSERT INTO Applicant (name, email, phone, resume_link) VALUES
('Mahmoud Ahmed', 'mahmoud@example.com', '+966123456789', 'https://resume.com/mahmoud'),
('Sarah Ali', 'sarah@example.com', '+966987654321', 'https://resume.com/sarah'),
('Omar Khaled', 'omar@example.com', '+966567891234', 'https://resume.com/omar');
GO

-- Insert sample data into the Application table
INSERT INTO Application (applicant_id, job_id, status, applied_date) VALUES
(1, 1, 'Pending', GETDATE()),
(2, 2, 'Interview', GETDATE()),
(3, 3, 'Hired', GETDATE());
GO

-- Insert sample data into the Interview table
INSERT INTO Interview (application_id, interview_date, feedback, result) VALUES
(1, '2025-03-25 10:00:00', 'Good technical skills.', 'Accepted'),
(2, '2025-03-26 11:00:00', 'Needs improvement in algorithms.', 'Rejected');
GO

-- Retrieve all data from each table for verification
SELECT * FROM Company;
SELECT * FROM Job;
SELECT * FROM Applicant;
SELECT * FROM Application;
SELECT * FROM Interview;
GO

-- Query: Retrieve all jobs with company details
SELECT J.job_id, J.title, J.description, J.salary, C.name AS company_name, C.location
FROM Job J
JOIN Company C ON J.company_id = C.company_id;
GO

-- Query: Retrieve applicants and their job applications with status
SELECT A.applicant_id, A.name AS applicant_name, J.title AS job_title, App.status, App.applied_date
FROM Application App
JOIN Applicant A ON App.applicant_id = A.applicant_id
JOIN Job J ON App.job_id = J.job_id;
GO

-- Query: Count the number of applications for each job
SELECT J.title AS job_title, COUNT(App.application_id) AS total_applications
FROM Job J
LEFT JOIN Application App ON J.job_id = App.job_id
GROUP BY J.title;
GO

-- Query: Retrieve all scheduled interviews with applicant and job details
SELECT I.interview_id, A.name AS applicant_name, J.title AS job_title, I.interview_date, I.feedback, I.result
FROM Interview I
JOIN Application App ON I.application_id = App.application_id
JOIN Applicant A ON App.applicant_id = A.applicant_id
JOIN Job J ON App.job_id = J.job_id;
GO

-- Query: Retrieve jobs that have not received any applications
SELECT J.title AS job_title, C.name AS company_name
FROM Job J
LEFT JOIN Application App ON J.job_id = App.job_id
JOIN Company C ON J.company_id = C.company_id
WHERE App.application_id IS NULL;
GO

-- Query: Retrieve applicants who were accepted in interviews
SELECT A.name AS applicant_name, J.title AS job_title, I.interview_date, I.feedback
FROM Interview I
JOIN Application App ON I.application_id = App.application_id
JOIN Applicant A ON App.applicant_id = A.applicant_id
JOIN Job J ON App.job_id = J.job_id
WHERE I.result = 'Accepted';
GO

-- Query: Retrieve applicants who have applied for multiple jobs
SELECT A.name AS applicant_name, COUNT(App.application_id) AS total_applications
FROM Applicant A
JOIN Application App ON A.applicant_id = App.applicant_id
GROUP BY A.name
HAVING COUNT(App.application_id) > 1;
GO
