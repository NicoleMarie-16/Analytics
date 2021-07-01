-- Author: Nicole Davila
-- Date: 2019-06-11

-- Create database
CREATE DATABASE deli;

-- Select database to use
USE deli;

-- Create a table employees in the database
CREATE TABLE employees (
	ssn CHAR(9),
    	name VARCHAR(50),
    	salary NUMERIC(9,2),
    	hire_date DATE,
    	supervisor varchar(50),
    	PRIMARY KEY (ssn));
    
-- Insert values into employees table
INSERT INTO employees (ssn, name, salary, hire_date, supervisor)
VALUES (134568877, 'Jim Jones', 28000.00, '2015-01-26', 'Rita Bina'),
       (138568050, 'Rita Bita', 32000.00, '2017-02-15', 'Holly Dew'),
       (334558877, 'Holly Dew', 29000.00, '2016-01-15', 'Pablo Escobar'),
       (666566666, 'Pablo Escobar', 48000.00, '2014-01-26', 'Rita Bina'),
       (888918870, 'Al Capone', 40000.00, '2015-01-26', 'Pablo Escobar'),
       (111223333, 'Bonnie Clyde', 42000.00, '2015-04-07', 'Al Capone');

-- Check values entered
SELECT * FROM employees;

-- Create table departments in the database
CREATE TABLE departments (
	dept_name VARCHAR(20),
    	man_ssn CHAR(9),
    	appt_date DATE,
    	PRIMARY KEY (dept_name),
    	FOREIGN KEY (man_ssn) REFERENCES employees (ssn));
 
-- Insert values into departments table 
INSERT INTO departments (dept_name, man_ssn, appt_date)
VALUES ('hot foods', 888918870, '2016-01-01'),
       ('sandwiches', 111223333, '2016-01-01'), 
       ('snacks', 666566666, '2015-05-05'),
       ('beverages', 138568050, '2018-03-18');

-- Check values entered
SELECT * FROM departments; 

-- Create table works in the database
CREATE TABLE works (
	ssn CHAR(9),
    	dept_name varchar(20),
    	FOREIGN KEY (ssn) REFERENCES employees (ssn),
    	FOREIGN KEY (dept_name) REFERENCES departments (dept_name));

-- Insert values into works table    
INSERT INTO works (ssn, dept_name)
VALUES (134568877, 'hot foods'),
	(138568050, 'beverages'),
    	(334558877, 'sandwiches'),
    	(666566666, 'snacks'),
    	(888918870, 'hot foods'),
    	(111223333, 'sandwiches');

-- Check values entered    
SELECT * FROM works;
 
-- Create table manages in the database
 CREATE TABLE manages (
	ssn CHAR(9),
    	manages VARCHAR(20),
    	PRIMARY KEY (ssn),
    	FOREIGN KEY (manages) REFERENCES departments (dept_name));
 
-- Insert values into manages table
INSERT INTO manages (ssn, manages)
VALUES (138568050, 'beverages'),
       (666566666, 'snacks'),
       (888918870, 'hot foods'),
       (111223333, 'sandwiches');

-- Check values entered
SELECT * FROM manages;

-- Add status column to employees table
ALTER TABLE employees
ADD status VARCHAR(15);

-- Update status for various records in employees table
UPDATE employees 
SET status = 'employee' 
WHERE ssn = 134568877;

UPDATE employees 
SET status = 'manager' 
WHERE ssn = 138568050;

UPDATE employees 
SET status = 'supervisor' 
WHERE ssn = 334558877;

UPDATE employees 
SET status = 'manager' 
WHERE ssn = 666566666;

UPDATE employees 
SET status = 'manager' 
WHERE ssn = 888918870;

UPDATE employees 
SET status = 'manager' 
WHERE ssn = 111223333;

-- Take a look at che changes
SELECT * FROM employees;

-- Create another table in the deli database
CREATE TABLE discount (
	status VARCHAR(15),
    	discount_level SMALLINT,
    	PRIMARY KEY (status));

-- Insert records into discount table
INSERT INTO discount (status, discount_level)
VALUES ('manager', 25),
       ('supervisor', 20),
       ('employee', 15);

-- Make the status column in employees reference the status column in the discount table
ALTER TABLE employees
ADD FOREIGN KEY (status) REFERENCES discount(status);

-- Check values in table discount
SELECT * FROM discount;

-- Remove the supervisor column from the employees table
ALTER TABLE employees
DROP supervisor;

-- Create table supervisor
CREATE TABLE supervisor (
	ssn CHAR(9),
    	supervisor VARCHAR(50),
    	PRIMARY KEY (ssn));

-- Insert values into supervisor    
INSERT INTO supervisor (ssn, supervisor)
	VALUES (134568877, 'Rita Bina'),
	(138568050, 'Holly Dew'),
	(334558877, 'Pablo Escobar'),
	(666566666, 'Rita Bina'),
    	(888918870, 'Pablo Escobar'),
	(111223333, 'Al Capone');

-- Create a view
CREATE VIEW EmpDiscount AS
SELECT e.name, w.dept_name, s.supervisor, d.discount_level
FROM employees AS e, works AS w, supervisor AS s, discount AS d
WHERE e.ssn = w.ssn AND e.ssn = s.ssn AND e.status = d.status;

-- Check newly created view
select * from EmpDiscount;

-- What is the average discount by department?
SELECT dept_name, AVG(discount_level) as AvgDiscount
FROM EmpDiscount
GROUP BY dept_name;