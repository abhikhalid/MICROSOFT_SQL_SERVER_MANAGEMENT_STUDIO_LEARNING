-- Part 88 : SQL Server Except Operator

-- EXCEPT operator returns unique rows from the left query that aren't in the right query's results.

-- i. The number and order of columns must be the same in all queries.
-- ii. The data types must be same or compatible
-- iii. This is similar to minus operator in oracle.

create database Sample8;

create table TableA
(
 Id int primary key,
 Name nvarchar(50),
 Gender nvarchar(10)
)

insert into TableA values (1,'Mark','Male')
insert into TableA values (2,'Mary','Female')
insert into TableA values (3,'Steve','Male')
insert into TableA values (4,'John','Male')
insert into TableA values (5,'Sara','Female')

create table TableB
(
 Id int primary key,
 Name nvarchar(50),
 Gender nvarchar(10)
)

insert into TableB values (4,'John','Male')
insert into TableB values (5,'Sara','Female')
insert into TableB values (6,'Pam','Female')
insert into TableB values (7,'Rebeka','Female')
insert into TableB values (8,'Jordan','Male')

Select * from TableA;
Select * from TableB;


--notice that the following query returns the unique rows from the left query that aren't in the right query's result.

Select Id,Name, Gender
From TableA
EXCEPT
Select Id,Name, Gender
From TableB

-- To retrive all of the rows from Table B that does not exist in Table A, reverse the two queries as shown below

Select Id,Name,Gender
From TableB
EXCEPT
Select Id,Name, Gender
From TableA

-- you can use Except operator on a single table. Let's use the following tblEmployees table for this example.

Create table tblEmployees
(
	Id int identity primary key,
	Name nvarchar(100),
	Gender nvarchar(10),
	Salary int
)

insert into tblEmployees values ('Mark','Male',52000)
insert into tblEmployees values ('Mary','Female',55000)
insert into tblEmployees values ('Steve','Male',45000)
insert into tblEmployees values ('John','Male',40000)
insert into tblEmployees values ('Sara','Female',52000)
insert into tblEmployees values ('Pam','Female',60000)
insert into tblEmployees values ('Tom','Male',58000)
insert into tblEmployees values ('George','Male',65000)
insert into tblEmployees values ('Tina','Female',67000)
insert into tblEmployees values ('Ben','Male',80000) 

Select * from tblEmployees


Select Id,Name,Gender,Salary
From tblEmployees
Where Salary >=50000
Except
Select Id,Name,Gender,Salary
From tblEmployees
Where Salary >=60000
order by Name



-- Part 89 : Difference between Except and not in sql server

use Sample8;
drop table TableA;
drop table TableB;

insert into TableA values(1,'Mark','Male')
insert into TableA values(2,'Mary','Female')
insert into TableA values(3,'Steve','Male')

insert into TableB values(2,'Mary','Female')
insert into TableB values(3,'Steve','Male')

-- The following query returns the rows from the left query that aren't int the right query's results.

Select Id,Name,Gender From TableA
Except
Select Id,Name,Gender From TableB

-- The same result can be achieved using NOT IN operator.

Select Id,Name,Gender From TableA
Where Id not in (select Id from TableB)

-- so what is the differences between EXCEPT and NOT IN Operator?

-- i. Except filters duplicate and returns only DISTINCT rows from the left query that aren't in the right query's result, Where as NOT IN does not filter the duplicates.

-- but it does't not filter duplicate rows
Select Id,Name,Gender From TableA
Where Id not in (select Id from TableB)


-- ii. EXCEPT operator excepts the same number of columns in both the queries. Where as NOT IN, compares a single column from the outer query with a single column from the subquery.

-- example: the no of columns are different. it would produce error.

Select Id,Name,Gender from TableA
EXCEPT
Select Id,Name From TableB

-- NOT IN compares a single column from the outer query with a single column from subquery.

Select Id,Name, Gender from TableA
Where Id NOT IN (Select Id, Name from TableB)



-- Part 90 : Itersect operator in sql server

--  we will discuss, i. Intersect operator in sql server. ii. Difference between intersect and inner join

-- Intersect operator retrieves the common records from both the left and the right query of the Intersect operator.
use Sample8;
drop table TableA;
drop table TableB;

Create Table TableA
(
 Id int,
 Name nvarchar(50),
 Gender nvarchar(10)
)

Create Table TableB
(
 Id int,
 Name nvarchar(50),
 Gender nvarchar(10)
)

insert into TableA values(1,'Mark','Male')
insert into TableA values (2,'Mary','Female')
insert into TableA values (3,'Steve','Male')

insert into TableB values (2,'Mary','Female')
insert into TableB values (3,'Steve','Male')

select * from TableA
Select * from TableB

Select Id,Name,Gender from TableA
Intersect
Select Id,Name,Gender from TableB

-- we can also avhieve the same thing using INNER JOIN. The following INNER join query would produce the exact same result.
-- notice that, the duplicates are not filtered.

Select TableA.Id,TableA.Name,TableA.Gender
from TableA
INNER JOIN TableB 
ON TableA.Id = TableB.Id

-- we can make the inner join behave like intersect operator by using the DISTINCT operator.

Select DISTINCT TableA.Id,TableA.Name,TableA.Gender
from TableA
INNER JOIN TableB 
ON TableA.Id = TableB.Id

-- ii. INNER JOIN treats two NULLS as two different values. So, If you are joining two tables based on nullable column and if both tables have NULLS in that joining column then,
-- INNER JOIN will not include those rows in the result set, where as INTERSECT treats two NULLS as a same value and it returns all matching rows.

-- to understand the difference, execute the following 2 insert statments.

insert into TableA values (NULL,'Pam','Female')
insert into TableB values (NULL,'Pam','Female')

-- intersect query

select id,name,gender from TableA
intersect
select id,name,gender from TableB


Select TableA.Id, TableA.Name, TableA.Gender
From TableA Inner Join TableB
On TableA.Id = TableB.Id



-- Part 91 : Difference between Union, Intersect and except in sql server

-- UNION : Union operator returns all the unique rows from the both left and right query. UNION ALL includes the duplicates as well.

-- INTERSECT : INTERSECT operator retrieves the common unique rows from both the left and the right query.


-- EXCEPT : EXCEPT operator returns the unique rows from the left query that aren't in the right query's result.

-- Let's understand the difference with an example.

create Database Sample9;
use Sample9;

Create Table TableA
(
 Id int,
 Name nvarchar(50),
 Gender nvarchar(10)
)

insert into TableA values (1,'Mark','Male')
insert into TableA values (2,'Mary','Female')
insert into TableA values (3,'Steve','Male')
insert into TableA values (3,'Steve','Male')


Create Table TableB
(
 Id int Primary key,
 Name nvarchar(50),
 Gender nvarchar(10)
)

insert into TableB values (2,'Mary','Female')
insert into TableB values (3,'Steve','Male')
insert into TableB values (4,'John','Male')

Select * from TableA
Select * from TableB

-- UNION operator returns all the unique rows from both the queries. Notice the duplicates are removed.
Select * From TableA
UNION
Select * from TableB

-- UNION ALL operator returns all the rows from the queries, including duplicates
Select * From TableA
UNION ALL
Select * from TableB

--INTERSECT : INTERSECT operator returns all the common value from the left and the right query. Notice duplicates are removed.
Select * From TableA
INTERSECT
Select * from TableB


--EXCEPT : EXCEPT operator returns rows from the left query that aren't in the right query's results.
Select * From TableA
EXCEPT
Select * from TableB

-- For UNION, INTERSECT and EXCEPT operator, The number and the order of the columns must be same in both the queries
-- The data types must be same or at least compatible.


-- Part 92 : Cross apply and outer apply in sql server
use Sample9;

Create Table Department
(
 Id int primary key,
 DepartmentName nvarchar(50)
)

insert into Department values (1,'IT')
insert into Department values (2,'HR')
insert into Department values (3,'Payroll')
insert into Department values (4,'Administration')
insert into Department values (5,'Sales')

Select * from Department

Create Table Employee
(
 Id int primary key,
 Name nvarchar(50),
 Gender nvarchar(10),
 Salary int,
 DepartmentId int foreign key references Department(Id)
)

insert into Employee values (1,'Mark','Male',50000,1)
insert into Employee values (2,'Mary','Female',60000,3)
insert into Employee values (3,'Steve','Male',45000,2)
insert into Employee values (4,'John','Male',56000,1)
insert into Employee values (5,'Sara','Female',39000,2)

Select * from Employee

-- We want to retrive all the matching rows between Department and Employee tables.

Select D.DepartmentName, E.Name,E.Gender,E.Salary
FROM Department D
LEFT JOIN EMPLOYEE E
ON D.Id = E.DepartmentId

-- now, let's assume we do not have accces to the Employee table. Instead we have access to the following Table valued function, that returns all the Employee belonging to a department by Department Id.

Create function fn_GetEmployeeByDepartmentId(@DepartmentId int)
Returns Table
as 
Return
(
  Select Id,Name,Gender,Salary,DepartmentId
  From Employee where DepartmentId = @DepartmentId
)

--The following query returns the employees of the deparment with Id = 1
Select * from fn_GetEmployeeByDepartmentId(1)

--Now if you try to perform an Inner or Left join between Department table and fn_GetEmployeesByDepartmentId() function you will get an error.

Select D.DepartmentName, E.Name, E.Gender, E.Salary
from Department D
Inner Join fn_GetEmployeesByDepartmentId(D.Id) E
On D.Id = E.DepartmentId

-- This is why we use Cross Apply and Outer Apply operators.
-- Cross apply is semantically equivalent to Inner Join and Outer Apply is semnatically equivalent to LEFT OUTER JOIN.

--Just like Inner Join, Cross Apply retrieves only the matching rows from the Department table and fn_GetEmployeesByDepartmentId() table valued function.

Select D.DepartmentName, E.Name, E.Gender, E.Salary
from Department D
Cross Apply fn_GetEmployeesByDepartmentId(D.Id) E


--Just like Left Outer Join, Outer Apply retrieves all matching rows from the Department table and fn_GetEmployeesByDepartmentId() table valued function + non-matching rows from the left table (Department)

Select D.DepartmentName, E.Name, E.Gender, E.Salary
from Department D
Outer Apply fn_GetEmployeesByDepartmentId(D.Id) E