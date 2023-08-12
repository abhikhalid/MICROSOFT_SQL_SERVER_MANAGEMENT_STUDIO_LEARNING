-- Part 93 : DDL Triggers in sql server

-- In SQL server, there are 4 types of triggers.
-- i. DML Triggers - Data Manipulation Language. (Insert,Update,Delete)
-- ii. DDL Triggers - Data Defination Language.
--- iii. CLR Triggers - Common Language Runtime
-- iv. Logon Triggers

-- What are DDL Triggers? 

-- DDL triggers fire in response to DDL events. CREATE, ALTER and DROP (TABLE,FUNCTION,Index,Stored Procedure etc).

-- Certain system stored procedures that perform DDL like operation can also fire DDL triggers. Example - sp_rename system stored procedure

-- What is the use of DDL triggers?

-- i. if you want to execute some code in response to a specific DDL event
-- ii. To prevent certain changes to your database scheme.
--- iii. Audit the changes that the users are making to the database structure.


-- Syntax for creating DDL trigger

-- CREATE TRIGGER [Trigger_Name]
-- ON [Scope (Server|Database)]
-- FOR [EventType1, EventType2, EventType3, ...],
-- AS
-- BEGIN
--   -- Trigger Body
-- END

use Sample9;

CREATE TRIGGER trMyFirstTrigger
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
	Print 'New table created'
END


-- When you execute the following code to create the table, the trigger will automatically fire and will print the message 
Create Table Test (Id int)

-- The above trigger will be fired only for one DDL event CREATE_TABLE. If you want this trigger to be fired for multiple event...

ALTER TRIGGER trMyFirstTrigger
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
	Print 'A table has just been created, modified or deleted'
END


-- now if you create, alter or drop a table, the trigger will fire automatically and you will get the message.
Create Table Test2 (Id int)

-- The 2 DDL triggers above execute some code in response to DDL events.


-- Now, let us look at an example of how to prevent users from crating, altering or dropping tables. To do this modify the trigger as shown below

ALTER TRIGGER trMyFirstTrigger
ON DATABASE
FOR CREATE_TABLE,ALTER_TABLE,DROP_TABLE
AS
BEGIN
	Rollback
	Print 'You can not create,alter or drop a table'
END

Create Table Table3(Id int)

-- To be able to create, alter or drop a table, you either have to disable or delete the trigger.

-- you can disable the trigger using the following 
DISABLE TRIGGER trMyFirstTrigger ON DATABASE

-- you can also enable the trigger usng the following T-SQL command
ENABLE TRIGGER trMyFirstTrigger ON DATABASE

--To drop trigger
DROP TRIGGER trMyFirstTrigger ON DATABASE


-- Certain system stored procedures that perform DDL like operations can also fire DDL triggers. 

CREATE TRIGGER trRenameTable
ON DATABASE
FOR RENAME
AS
BEGIN
	Print 'You just renamed something'
END

sp_rename 'Test','Test1010'

sp_rename 'Test1010.Id','NewId','column'


-- Part 94 : Server Scoped ddl trigers

-- The following trigger is a database scoped trigger. This will prevent users from creating, altering or dropping tables only form the database in which is created.

CREATE TRIGGER tr_DatabaseScopeTriiger
ON DATABASE
FOR CREATE_TABLE,ALTER_TABLE,DROP_TABLE
AS
BEGIN
	ROLLBACK
	Print 'You can not create, alter or drop a table in the current database'
END

-- If you have another database on the server, they will be able to create,alter or drop tables ion that database.  If you want to prevent users from doing this you may create the trigger again in this database.

-- But what if you have 100 different databases on your server and you want to prevent users from creating, altering or dropping tables from all these 100 databases. Creating the same trigger for all the 100 different databases is not a good approach for 2 reasons.

-- i. It is tedious and error prone
-- ii. Maintainability is a night mare. If for some reason you have to change the trigger,  you will have to do it in 100 different databases, which is tedious and error prone. This is where server-scoped DDDL triggers come in handy.

-- Creating a Server Scoped DDL trigger :

CREATE TRIGGER tr_SererScopeTrigger
ON ALL SERVER
FOR CREATE_TABLE, ALTER_TABLE,DROP_TABLE
AS
BEGIN
	ROLLBACK
	Print 'You can not create,alter or drop a table in any database on the server'
END

use Sample;
Create Table test(id int)

--To disable Server-scoped ddl trigger

DISABLE TRIGGER tr_ServerScopeTrigger ON ALL SERVER


--To enable Server-scoped ddl trigger
ENABLE TRIGGER tr_ServerScopeTrigger ON ALL SERVER

--To drop Server-scoped ddl trigger
DROP TRIGGER tr_ServerScopeTrigger ON ALL SERVER


-- Part 95 : SQL Server Trigger Execution Order

-- In this video, we will discuss how to set the execution order of triggers using sp_settriggerorder stored procedure.

-- Server scoped triggers will always fire before any of the database scoped triggers. This execution order can not be changed.

CREATE TRIGGER tr_DatabaseScopeTriger
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
	Print 'Database Scope Trigger'
END

CREATE TRIGGER tr_ServerScopeTrigger
ON ALL SERVER
FOR CREATE_TABLE
AS
BEGIN
	Print 'Server Scope Trigger'
END


Create Table MealManagement(Id int)

--Using the sp_settriggerorder stored procedure, you can set the execution order of server-scoped or database-scoped triggers.
EXEC sp_settriggerorder
@triggername = 'tr_DatabaseScopeTrigger1',
@order = 'none',
@stmttype = 'CREATE_TABLE',
@namespace = 'DATABASE'
GO

--If you have a database-scoped and a server-scoped trigger handling the same event, and if you have set the execution order at both the levels. Here is the execution order of the triggers.
--1. The server-scope trigger marked First
--2. Other server-scope triggers
--3. The server-scope trigger marked Last
--4. The database-scope trigger marked First
--5. Other database-scope triggers
--6. The database-scope trigger marked Last





-- Part 96 : Audit Table Changes in sql server

-- here we will learn how to audit table changes in SQL Server using a DDL trigger.

use Sample9;

CREATE TABLE TableChanges
(
 DatabaseName nvarchar(250),
 TableName nvarchar(250),
 EventType nvarchar(250),
 LoginName nvarchar(250),
 SQLCommand nvarchar(2500),
 AuditDateTime datetime
)

--The following trigger audits all table changes in all databases on a SQL Server
CREATE TRIGGER tr_AuditTableChanges
ON ALL SERVER
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
	DECLARE @EventData XML
	SELECT @EventData = EVENTDATA()

	INSERT INTO Sample9.dbo.TableChanges values (
	  @EventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(250)'),
         @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(250)'),
         @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(250)'),
         @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(250)'),
         @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2500)'),
         GetDate()
	)
END


--In the above example we are using EventData() function which returns event data in XML format. The following XML is returned by the EventData() function when I created a table with name = MyTable in SampleDB database.

--<EVENT_INSTANCE>
--  <EventType>CREATE_TABLE</EventType>
--  <PostTime>2015-09-11T16:12:49.417</PostTime>
--  <SPID>58</SPID>
--  <ServerName>VENKAT-PC</ServerName>
--  <LoginName>VENKAT-PC\Tan</LoginName>
--  <UserName>dbo</UserName>
--  <DatabaseName>SampleDB</DatabaseName>
--  <SchemaName>dbo</SchemaName>
--  <ObjectName>MyTable</ObjectName>
--  <ObjectType>TABLE</ObjectType>
--  <TSQLCommand>
--    <SetOptions ANSI_NULLS="ON" ANSI_NULL_DEFAULT="ON"
--                ANSI_PADDING="ON" QUOTED_IDENTIFIER="ON"
--                ENCRYPTED="FALSE" />
--    <CommandText>
--      Create Table MyTable
--      (
--         Id int,
--         Name nvarchar(50),
--         Gender nvarchar(50)
--      )
--    </CommandText>
--  </TSQLCommand>
--</EVENT_INSTANCE>



-- Part 97 : Logon Triggers in SQL Server



-- Part 98 : Select into in sql server
use Sample9;

Create Table Departments
(
 DepartmentId int primary key,
 DepartmentName nvarchar(50)
)

Insert Into Departments values(1,'IT')
Insert Into Departments values(2,'HR')
Insert Into Departments values(3,'Payroll')

--select * from Departments

Create Table Employees
(
  Id int primary key,
  Name nvarchar(100),
  Gender nvarchar(10),
  Salary int,
  DeptId int foreign key references Departments(DepartmentId)
)

insert into Employees values (1, 'Mark','Male',50000,1)
insert into Employees values (2, 'Sara','Female',65000,2)
insert into Employees values (3, 'Mike','Male',48000,3)
insert into Employees values (4, 'Pam','Female',70000,1)
insert into Employees values (5, 'John','Male',55000,2)

--select * from Employees

-- The SELECT INTO statement in SQL Server, selects data from one table and inserts it into a new table.

-- SELECT INTO statement in SQL server can do the following

-- Copy all rows and columns from existing table into a new table. This is extreamly useful when you want to make a backup copy of the existing table.

Select * INTO  EmployeesBackup from Employees

select * from EmployeesBackup

--2. Copy all rows and columns from an existing table into a new table in an external database.

 SELECT * INTO HRDB.dbo.EmployeesBackup FROM Employees

--3. Copy only selected columns into a new table
SELECT Id, Name, Gender INTO EmployeesBackup FROM Employees

--4. Copy only selected rows into a new table
SELECT * INTO EmployeesBackup FROM Employees WHERE DeptId = 1


--5. Copy columns from 2 or more table into a new table
SELECT * INTO EmployeesBackup
FROM Employees
INNER JOIN Departments
ON Employees.DeptId = Departments.DepartmentId

--6. Create a new table whose columns and datatypes match with an existing table. 
SELECT * INTO EmployeesBackup FROM Employees WHERE 1 <> 1

--7. Copy all rows and columns from an existing table into a new table on a different SQL Server instance. For this, create a linked server and use the 4 part naming convention
--SELECT * INTO TargetTable
--FROM [SourceServer].[SourceDB].[dbo].[SourceTable]


--You cannot use SELECT INTO statement to select data into an existing table. For this you will have to use INSERT INTO statement.

--INSERT INTO ExistingTable (ColumnList)
--SELECT ColumnList FROM SourceTable


-- Part 99 : Difference between where and having in sql server

use Sample9;
Create Table Sales
(
  Product nvarchar(50),
  SaleAmount int
)

insert into Sales values ('iPhone',500)
insert into Sales values ('Laptop',800)
insert into Sales values ('iPhone',1000)
insert into Sales values ('Speakers',400)
insert into Sales values ('Laptop',600)

Select Product,SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY Product

-- now if we want to find ony those products where the total sales amount is greater than $1000, we will use HAVING clause to filter products

Select Product,SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY Product
HAVING SUM(SaleAmount) > 1000

-- If use use WHERE clause instead of HAVING clasuse, we will get a syntax error. This is because the WHERE clasuse doesn't work with the aggregate function like sum,min,max,avg etc.

Select Product,SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY Product
WHERE SUM(SaleAmount) > 1000

-- so, in short the difference is , WHERE clause can not be used with aggregate where as HAVING can.

-- WHERE clause filters rows before aggregate calculations are performed where as HAVING clause filters rows after aggregate calculations are performed. Let's understand with an example.

-- Calculate Total Sales of IPhone and Speakers using WHERE clause.
-- In this example, the WHERE clause retrieves only iPhone and Speaker products and then performs the sum.
Select Product, SUM(SaleAmount) as TotalSales
FROM Sales
WHERE Product in ('Iphone','Speakers')
Group By Product

-- Calculate Total Sales of IPhone and Speakers using HAVING clause
-- This example retrieves all rows from Sales table, performs the sum and then removes all products except iPhone and Speakers.
Select Product,SUM(SaleAmount) as TotalSales
FROM Sales
Group By Product
Having Product in ('Iphone','Speakers')

-- So from a performance standpoint, HAVING clasuse is slower than WHERE and should be avoided when posible.

-- Another difference is WHERE comes before GROUP BY and HAVING comes after GROUP BY.


--Difference between WHERE and Having
--1. WHERE clause cannot be used with aggregates where as HAVING can. This means WHERE clause is used for filtering individual rows where as HAVING clause is used to filter groups.

--2. WHERE comes before GROUP BY. This means WHERE clause filters rows before aggregate calculations are performed. 
--HAVING comes after GROUP BY. This means HAVING clause filters rows after aggregate calculations are performed.
--So from a performance standpoint, HAVING is slower than WHERE and should be avoided when possible.



--3. WHERE and HAVING can be used together in a SELECT query. In this case WHERE clause is applied first to filter individual rows. 
--The rows are then grouped and aggregate calculations are performed, and then the HAVING clause filters the groups.


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- Part 100 : Table valued parameters in SQL SERVER

-- Table valued parameter allows a table to be passed as a parameter to a stored procedure from T-SQL code or from an application. Previously, it was not possible to pass a table variable as a parameter to a stored procedure.

use Sample10;

Create Table Employees
(
	Id int primary key,
	Name nvarchar(50),
	Gender nvarchar(10)
)

CREATE TYPE EmpTableType AS TABLE
(
 Id INT PRIMARY KEY,
 Name NVARCHAR(50),
 Gender NVARCHAR(10)
)

--Step 2 : Use the User-defined Table Type as a parameter in the stored procedure. 
--Table valued parameters must be passed as read-only to stored procedures, functions etc.
--This means you cannot perform DML operations like INSERT, UPDATE or DELETE on a table-valued parameter in the body of a function, stored procedure etc.

CREATE PROCEDURE spInsertEmployees
@EmpTableType EmpTableType READONLY
AS
BEGIN
  INSERT INTO Employees
  Select * from @EmpTableType
END


DECLARE @EmployeeTableType EmpTableType

INSERT INTO @EmployeeTableType VALUES (1, 'Mark', 'Male')
INSERT INTO @EmployeeTableType VALUES (2, 'Mary', 'Female')
INSERT INTO @EmployeeTableType VALUES (3, 'John', 'Male')
INSERT INTO @EmployeeTableType VALUES (4, 'Sara', 'Female')
INSERT INTO @EmployeeTableType VALUES (5, 'Rob', 'Male')

EXECUTE spInsertEmployees @EmployeeTableType


--Part 102 : Grouping Sets in SQL Server
use Sample10;
--drop table Employees

Create Table Employees
(
 Id int primary key,
 Name nvarchar(50), 
 Gender nvarchar(10),
 Salary int,
 Country nvarchar(10)
)


Insert Into Employees Values (1, 'Mark', 'Male', 5000, 'USA')
Insert Into Employees Values (2, 'John', 'Male', 4500, 'India')
Insert Into Employees Values (3, 'Pam', 'Female', 5500, 'USA')
Insert Into Employees Values (4, 'Sara', 'Female', 4000, 'India')
Insert Into Employees Values (5, 'Todd', 'Male', 3500, 'India')
Insert Into Employees Values (6, 'Mary', 'Female', 5000, 'UK')
Insert Into Employees Values (7, 'Ben', 'Male', 6500, 'UK')
Insert Into Employees Values (8, 'Elizabeth', 'Female', 7000, 'USA')
Insert Into Employees Values (9, 'Tom', 'Male', 5500, 'UK')
Insert Into Employees Values (10, 'Ron', 'Male', 5000, 'USA')

Select * from Employees

-- We want to calculate Sum of Salary by Country and Gender
-- we can very easily achieve this using a Group By query as shown below
Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender

--Within the same result set we also want Sum of Salary just by Country.

Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender

UNION ALL

Select Country, NULL, SUM(Salary) as TotalSalary
From Employees
GROUP BY Country

-- within the same result set we also want Sum of Salary just by Gender.
-- We can achieve this by combining 3 Group By queries using UNION ALL as shown below
Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender

UNION ALL

Select Country, NULL, SUM(Salary) as TotalSalary
From Employees
GROUP BY Country

UNION ALL

Select NULL, Gender, SUM(Salary) as TotalSalary
From Employees
GROUP BY Gender

-- Finally, we also want the grand total of Salary. In this case, we are not grouping on any particular column.
--To achieve this we will have to combine the fourth query using UNION ALL as shown below. 

Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender

UNION ALL

Select Country, NULL, SUM(Salary) as TotalSalary
From Employees
GROUP BY Country

UNION ALL

Select NULL, Gender, SUM(Salary) as TotalSalary
From Employees
GROUP BY Gender

UNION ALL

Select NULL, NULL, SUM(Salary) as TotalSalary
From Employees

-- There are 2 problems with the above approach.
-- i. The query is huge as we have combined different Group By queries using UNION ALL operator. This can grow even more if we start to add more groups.
-- ii. The Employees table has to be accessed 4 times, once for every query.

Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY 
	GROUPING SETS
	(
	 (Country,Gender),
	 (Country),
	 (Gender),
	 () -- Grand Total
	)
	

--The order of the rows in the result set is not the same as in the case of UNION ALL query. To control the order use order by as shown below.
Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY 
	GROUPING SETS
	(
	 (Country,Gender),
	 (Country),
	 (Gender),
	 () -- Grand Total
	)
	
Order By Grouping(Country), Grouping(Gender), Gender


-- Part 103 : Rollup in SQL Server

-- ROLLUP in SQL Sever is used to do aggregate operation on multiple levels in hierarchy.

use Sample10;
-- we will be using the Employees Table

--Retrieve Salary by country along with grand total

Select Country ,SUM(Salary) as TotalSalary
FROM Employees
GROUP BY ROLLUP(Country)

--or

Select Country, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country with ROLLUP

-- We can also use UNION ALL operator along with GROUP BY

Select Country, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country

UNION ALL

SELECT NULL, SUM(Salary)
FROM Employees


-- We can also use Grouping Sets to achieve the same result

Select Country, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY GROUPING SETS
(
  Country,
  ()
)


-- now, Group Salary by Country and Gender. Also comput the Subtotal for Country level and Grand Total

Select Country,Gender,SUM(Salary) As TotalSalary
FROM Employees
GROUP BY ROLLUP(Country,Gender) 

-- OR

Select Country,Gender,SUM(Salary) As TotalSalary
FROM Employees
GROUP BY Country,Gender WITH ROLLUP

--Using UNION ALL with GROUP BY

Select Country,Gender,SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender

UNION ALL

Select Country, NULL, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country

UNION ALL

Select NULL,NULL, SUM(Salary) as TotalSalary
FROM Employees


--Using Grouping sets

Select Country, Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY GROUPING SETS 
(
  (Country,Gender),
  (Country),
  ()
)


--////////////////////////////////////////////////////////

-- Part 104 : Cube in SQL Server

-- Cube() in SQL Server produces the result set by generating all combinations of columns specified in GROUP BY CUBE()

use Sample10;

-- Writa a query to retrieve Sum of Salary grouped by all combinations of the following 2 columns as well as Grand Total.
-- Country
-- Gender

Select Country,Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY CUBE(Country,Gender)

--or

Select Country,Gender, SUM(Salary) as TotalSalary
FROM Employees
GROUP BY Country,Gender with CUBE


--The above query is equivalent to the following Grouping Sets query
SELECT Country, Gender, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY
    GROUPING SETS
    (
         (Country, Gender),
         (Country),
         (Gender),
         ()
    )



--The above query is equivalent to the following UNION ALL query. While the data in the result set is the same, the ordering is not. Use ORDER BY to control the ordering of rows in the result set.

SELECT Country, Gender, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Country, Gender

UNION ALL

SELECT Country, NULL, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Country

UNION ALL

SELECT NULL, Gender, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY Gender

UNION ALL

SELECT NULL, NULL, SUM(Salary) AS TotalSalary
FROM Employees








--//////////////////////////////////////////

-- Part 105 : Difference between cube and rollup in SQL Server

--CUBE generates a result set that shows aggregates for all combinations of values in the selected columns, 
--where as ROLLUP generates a result set that shows aggregates for a hierarchy of values in the selected columns

-- Consider the following Sales Table
use Sample10;

Create Table Sales
(
  Id int primary key identity,
  Continent nvarchar(50),
  Country nvarchar(50),
  City nvarchar(50),
  SaleAmount int
)


Insert into Sales values('Asia','India','Bangalore',1000)
Insert into Sales values('Asia','India','Chennai',2000)
Insert into Sales values('Asia','Japan','Tokyo',4000)
Insert into Sales values('Asia','Japan','Hiroshima',5000)
Insert into Sales values('Europe','United Kingdom','London',1000)
Insert into Sales values('Europe','United Kingdom','Manchester',2000)
Insert into Sales values('Europe','France','Paris',4000)
Insert into Sales values('Europe','France','Cannes',5000)

--ROLLUP(Continent,Country,City) produces Sum of Salary for the following hierarchy
-- Continent, Country,City
-- Continent, Country
-- Continent
-- ()


-- CUBE(Continent,Country,City) produces Sum of Salary for the following column combinations
-- Continent,Country,City
-- Continent,Country
-- Continent,City
-- Continent
-- Country,City
-- Country
-- City
-- ()



--////////////////////////////////////////////////////////////////

-- Part 107 : Grouping function in SQL Server

use Sample10;

--We will use the following Sales table for this example

-- What is Grouping function ? 
-- Grouping(Column) indicates whether the column in a GROUP BY list is aggregated or not. Grouping returns 1 for aggregated or 0 for not aggregated in the result set.

--The following query returns 1 for aggregated or 0 for not aggregated in the result set


Select Continent, Country, City, SUM(SaleAmount) AS TotalSales, GROUPING(Continent) AS GP_Continent, GROUPING(Country) AS GP_Country, GROUPING(City) AS GP_City
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


--What is the use of Grouping function in real world
--When a column is aggregated in the result set, the column will have a NULL value. If you want to replace NULL with ALL then this GROUPING function is very handy.

Select 
CASE WHEN GROUPING(Continent) = 1 THEN 'All' ELSE ISNULL(Continent,'Unknown') END AS Continent,
CASE WHEN GROUPING(Country) = 1 THEN 'All' ELSE ISNULL(Country, 'Unknown') END AS Country,
CASE WHEN GROUPING(City) = 1 THEN 'All' ELSE ISNULL(City, 'Unknown') END AS City,
SUM(SaleAmount) AS TotalSales
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


--Can't I use ISNULL function instead as shown below

SELECT   ISNULL(Continent, 'All') AS Continent,
         ISNULL(Country, 'All') AS Country,
         ISNULL(City, 'All') AS City,
         SUM(SaleAmount) AS TotalSales
FROM Sales

GROUP BY ROLLUP(Continent, Country, City)

--Well, you can, but only if your data does not contain NULL values. Let me explain what I mean.


--At the moment the raw data in our Sales has no NULL values. Let's introduce a NULL value in the City column of the row where Id = 1

Update Sales Set City = NULL where Id = 1

--Now execute the following query with ISNULL function

SELECT   ISNULL(Continent, 'All') AS Continent,
         ISNULL(Country, 'All') AS Country,
         ISNULL(City, 'All') AS City,
         SUM(SaleAmount) AS TotalSales
FROM Sales

GROUP BY ROLLUP(Continent, Country, City)

--Result : Notice that the actuall NULL value in the raw data is also replaced with the word 'All', which is incorrect. Hence the need for Grouping function.

--Please note : Grouping function can be used with Rollup, Cube and Grouping Sets


-- Part 107 : GROUPING ID function in SQL Server
use Sample10;
  
select * from Sales

-- GROUPING_ID function computes the level of grouping.

-- Difference between GROUPING and GROUPING_ID

-- syntax: GROUPING function is used on single column, where as the column list for GROUPING_ID function must match with GROUP BY column list.

-- GROUPING(Col1)
-- GROUPING(Col1,Col2,Col3)


-- GROUPING indicates whether the column in a GROUP BY list is aggregated or not. Grouping returns 1 for aggregated or 0 for not aggregated in the result.

-- GROUPING_ID() function concatenates all the GROUPING() functions, perform the binary to decimal conversion, and returns the equivalent integar.

-- In short, GROUPING_ID(A,B,C) = GROUPING(A) + GROUPING(B) + GROUPING(C)


SELECT Continent, Country, City, SUM(SaleAmount) AS TotalSales,
CAST(GROUPING(Continent) AS NVARCHAR(1)) + 
CAST(GROUPING(Country) AS NVARCHAR(1)) +
CAST(GROUPING(City) AS NVARCHAR(1)) AS Groupings,
GROUPING_ID(Continent,Country,City) AS GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)


-- Use of GROUPING_ID function: GROUPING_ID function is very handly if you want to sort and filter by level of grouping.

-- Sorting by level of grouping:

SELECT Continent, Country, City, SUM(SaleAmount) AS TotalSales, GROUPING_ID(Continent,Country,City) as GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)
ORDER BY GPID

-- Filter by levle of grouping : The following query retrieves only continent level aggregated data

SELECT Continent, Country, City, SUM(SaleAmount) AS TotalSales, GROUPING_ID(Continent,Country,City) AS GPID
FROM Sales
GROUP BY ROLLUP(Continent,Country,City)
HAVING GROUPING_ID(Continent,Country,City) = 3



-- Part 108: Debugging sql server stored procedures

-- here, we will learn how to debug stored procedures in SQL Server

-- open another query window and write the following stored procedure

--Create procedure spPrintEvenNumbers
--@Target int
--as 
--Begin
--	Declare @StartNumber int
--	Set @StartNumber = 1

--	while(@StartNumber < @Target)
--		begin
--		 if(@StartNumber%2=0)
--			begin
--				print @StartNumber
--			end
--		 set @StartNumber = @StartNumber + 1
--		end

--	print 'Fininshed printing even numbers till ' + RTRIM(@Target)
--End

DECLARE @TargetNumber INT
SET @TargetNumber = 10

EXECUTE spPrintEvenNumbers @TargetNumber
Print 'Done'


-- Part 109 : Over clause in SQL Server

-- The OVER clause combined with PARTITION BY is used to break up data into partitions.

-- syntax : function(...) OVER (PARTITION BY col1,col2...)

-- COUNT(Gender) OVER(PARTITION BY Gender) will partition the data by Gender. there will be 2 partition (Male and Female) and then COUNT() function is applied over each partition

-- any of the following functions can be used. Please note this is not the complete list. COUNT(), AVG(),SUM(), MIN(), MAX(), ROW_NUMBER(), RANK(), DENSE_RANK() etc.

use Sample10;

--Create Table Employees
--(
--     Id int primary key,
--     Name nvarchar(50),
--     Gender nvarchar(10),
--     Salary int
--)
--Go

--Insert Into Employees Values (1, 'Mark', 'Male', 5000)
--Insert Into Employees Values (2, 'John', 'Male', 4500)
--Insert Into Employees Values (3, 'Pam', 'Female', 5500)
--Insert Into Employees Values (4, 'Sara', 'Female', 4000)
--Insert Into Employees Values (5, 'Todd', 'Male', 3500)
--Insert Into Employees Values (6, 'Mary', 'Female', 5000)
--Insert Into Employees Values (7, 'Ben', 'Male', 6500)
--Insert Into Employees Values (8, 'Jodi', 'Female', 7000)
--Insert Into Employees Values (9, 'Tom', 'Male', 5500)
--Insert Into Employees Values (10, 'Ron', 'Male', 5000)



select * from Employees

--Write a query to retrieve total count of employees by Gender. Also in the result we want Average, Minimum and Maximum salary by Gender. The result of the query should be as shown below.

SELECT Gender, COUNT(*) as GenderTotal, AVG(Salary) as AvgSal, MIN(Salary) as MinSal, MAX(Salary) as MaxSal
From Employees
GROUP BY Gender

--What if we want non-aggregated values (like employee Name and Salary) in result set along with aggregated values

--you can not include non-aggregated columns in the GROUP BY query like this
SELECT Name,Salary,Gender, COUNT(*) as GenderTotal, AVG(Salary) as AvgSal,MIN(Salary) as MinSal, MAX(Salary) as MaxSal
FROM Employees
GROUP BY Gender

--One way to achieve this is by including the aggregations in a subquery and then JOINING it with the main query as shown in the example below. Look at the amount of T-SQL code we have to write.

Select Name,Salary,Employees.Gender,Genders.GenderTotal,Genders.AvgSal,Genders.MinSal,Genders.MaxSal
FROM Employees
INNER JOIN 
(
 SELECT Gender, COUNT(*) as GenderTotal, AVG(Salary) as AvgSal, MIN(Salary) as MinSal, MAX(Salary) as MaxSal
	From Employees
	GROUP BY Gender
) AS Genders
ON Employees.Gender = Genders.Gender


-- Better way of doing this is by using the OVER clause combined with PARTITION BY

Select Name,Salary,Gender, 
COUNT(Gender) OVER (PARTITION BY Gender)  as GenderTotal,
AVG(Salary) OVER (PARTITION BY Gender)  as AvgSal,
MIN(Salary) OVER (PARTITION BY Gender)  as MinSal,
MAX(Salary)  OVER (PARTITION BY Gender)  as MaxSal
FROM Employees


-- Part 110 : Row Number function in SQL Server

--Returns the sequential number of a row starting at 1
--ORDER BY clause is required
--PARTITION BY clause is optional
--When the data is partitioned, row number is reset to 1 when the partition changes

-- Syntax : ROW_NUMBER() OVER (ORDER BY Col1,Col2)

--Row_Number function without PARTITION BY : In this example, data is not partitioned, 
--so ROW_NUMBER will provide a consecutive numbering for all the rows in the table based on the order of rows imposed by the ORDER BY clause.


SELECT Name,Gender,Salary, ROW_NUMBER() OVER (ORDER BY Gender) AS RowNumber
FROM Employees

--Please note : If ORDER BY clause is not specified you will get the following error
--The function 'ROW_NUMBER' must have an OVER clause with ORDER BY

--Row_Number function with PARTITION BY : In this example, data is partitioned by Gender, 
--so ROW_NUMBER will provide a consecutive numbering only for the rows with in a parttion. When the partition changes the row number is reset to 1.

SELECT Name, Gender, Salary, ROW_NUMBER() OVER (PARTITION BY Gender ORDER BY Gender) AS RowNumber
FROM Employees

--Use case for Row_Number function : Deleting all duplicate rows except one from a sql server table. 


-- Part 111 : Rank and Dense_Rank in SQL Server

--Returns a rank starting at 1 based on the ordering of rows imposed by the ORDER BY clause.
--ORDER BY clause is required
--PARTITION BY clause is optional
--When the data is partitioned, rank is reset to 1 when the partition changes



--Difference between Rank and Dense_Rank functions
--Rank function skips ranking(s) if there is a tie where as Dense_Rank will not.


--For example : If you have 2 rows at rank 1 and you have 5 rows in total.
--RANK() returns - 1, 1, 3, 4, 5
--DENSE_RANK returns - 1, 1, 2, 3, 4
 

--Syntax : 
--RANK() OVER (ORDER BY Col1, Col2, ...)
--DENSE_RANK() OVER (ORDER BY Col1, Col2, ...)

use Sample10;
drop table Employees

Create Table Employees
(
    Id int primary key,
    Name nvarchar(50),
    Gender nvarchar(10),
    Salary int
)
Go

Insert Into Employees Values (1, 'Mark', 'Male', 8000)
Insert Into Employees Values (2, 'John', 'Male', 8000)
Insert Into Employees Values (3, 'Pam', 'Female', 5000)
Insert Into Employees Values (4, 'Sara', 'Female', 4000)
Insert Into Employees Values (5, 'Todd', 'Male', 3500)
Insert Into Employees Values (6, 'Mary', 'Female', 6000)
Insert Into Employees Values (7, 'Ben', 'Male', 6500)
Insert Into Employees Values (8, 'Jodi', 'Female', 4500)
Insert Into Employees Values (9, 'Tom', 'Male', 7000)
Insert Into Employees Values (10, 'Ron', 'Male', 6800)


--RANK() and DENSE_RANK() functions
--without PARTITION BY clause : In this example, data is not partitioned, 
--so RANK() function provides a consecutive numbering except when there is a tie. Rank 2 is skipped as there are 2 rows at rank 1. The third row gets rank 3.

--DENSE_RANK() on the other hand will not skip ranks if there is a tie. The first 2 rows get rank 1. Third row gets rank 2.

SELECT Name,Salary,Gender,
RANK() OVER (ORDER BY Salary DESC) AS [Rank],
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank
FROM Employees


--RANK() and DENSE_RANK() functions with PARTITION BY clause : Notice when the partition changes from Female to Male Rank is reset to 1

SELECT Name,Gender,Salary,
RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS [Rank],
DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS DenseRank
FROM Employees

--Use case for RANK and DENSE_RANK functions : Both these functions can be used to find Nth highest salary.
-- However, which function to use depends on what you want to do when there is a tie. Let me explain with an example.

--If there are 2 employees with the FIRST highest salary, there are 2 different business cases
--If your business case is, not to produce any result for the SECOND highest salary, then use RANK function
--If your business case is to return the next Salary after the tied rows as the SECOND highest Salary, then use DENSE_RANK function
--Since we have 2 Employees with the FIRST highest salary. Rank() function will not return any rows for the SECOND highest Salary.


WITH Result AS
(
 SELECT Salary, RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
 FROM Employees
)

Select top 1 Salary from Result where Salary_Rank = 2

WITH Result AS
(
 SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
 FROM Employees
)

Select top 1 Salary FROM Result WHERE Salary_Rank = 2


--You can also use RANK and DENSE_RANK functions to find the Nth highest Salary among Male or Female employee groups. 
--The following query finds the 3rd highest salary amount paid among the Female employees group.

WITH Result AS
(
 SELECT Salary, Gender, DENSE_RANK() OVER (PARTITION BY Gender ORDER BY Salary DESC) AS Salary_Rank
 FROM Employees
)

SELECT TOP 1 Salary from Result where Salary_Rank = 3 AND Gender = 'Female'



-- Part 112 : Difference between rank, dense_rank and row_number in SQL

-- Similarities between RANK, DENSE_RANK and ROW_NUMBER functions

-- i. Returns an increasing integar value starting 1 based on the ordering of rows imposed by the ORDER BY clause. (if there are no ties)
-- ii. ORDER BY clause is required.
-- iii. PARTITION BY clause is optional.
--- iv. when the data is partioned, the integar value is reset to 1 when the partition changes.

create database Sample11
use Sample11

Create Table Employees
(
     Id int primary key,
     Name nvarchar(50),
     Gender nvarchar(10),
     Salary int
)
Go

Insert Into Employees Values (1, 'Mark', 'Male', 6000)
Insert Into Employees Values (2, 'John', 'Male', 8000)

Insert Into Employees Values (3, 'Pam', 'Female', 4000)

Insert Into Employees Values (4, 'Sara', 'Female', 5000)
Insert Into Employees Values (5, 'Todd', 'Male', 3000)

select * from Employees

-- note that, now two employees in the table have the same salary. So all the 3 functions RANK, DENSE_RANK and ROW_NUMBER produce the same increasing integar value when ordered by Salary Column.

SELECT Name, Salary, Gender, ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNumber,
                             RANK() OVER (Order by Salary DESC) AS [Rank],
							 DENSE_RANK() OVER (Order by Salary DESC) AS DenseRank
							 FROM Employees

							 ou will only see the difference when there ties (duplicate values in the column used in the ORDER BY clause).

--Now let's include duplicate values for Salary column. 

--To do this 
--First delete existing data from the Employees table
DELETE FROM Employees

--Insert new rows with duplicate valuse for Salary column
Insert Into Employees Values (1, 'Mark', 'Male', 8000)
Insert Into Employees Values (2, 'John', 'Male', 8000)

Insert Into Employees Values (3, 'Pam', 'Female', 8000)
Insert Into Employees Values (4, 'Sara', 'Female', 4000)
Insert Into Employees Values (5, 'Todd', 'Male', 3500)

--Notice 3 employees have the same salary 8000. When you execute the following query you can clearly see the difference between RANK, DENSE_RANK and ROW_NUMBER functions.

SELECT Name, Salary, Gender,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNumber,
RANK() OVER (ORDER BY Salary DESC) AS [Rank],
DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank
FROM Employees


--Difference between RANK, DENSE_RANK and ROW_NUMBER functions
--ROW_NUMBER : Returns an increasing unique number for each row starting at 1, even if there are duplicates.
--RANK : Returns an increasing unique number for each row starting at 1. When there are duplicates, same rank is assigned to all the duplicate rows,
--but the next row after the duplicate rows will have the rank it would have been assigned if there had been no duplicates. So RANK function skips rankings if there are duplicates.
--DENSE_RANK : Returns an increasing unique number for each row starting at 1. When there are duplicates, same rank is assigned to all the duplicate rows but 
--the DENSE_RANK function will not skip any ranks. This means the next row after the duplicate rows will have the next rank in the sequence


-- Part 113 : Calculate running total in SQL Server 2012


use Sample10;

Select * from Employees


SELECT Name,Gender, Salary, SUM(Salary) OVER(Order By Id) AS RunnnigTotal
FROM Employees

-- sql query to compute running total with partitions

SELECT Name, Gender, Salary, SUM(Salary) OVER (PARTITION BY Gender ORDER BY ID) AS RunningTotal
FROM Employees


--What happens if I use order by on Salary column
--If you have duplicate values in the Salary column, all the duplicate values will be added to the running total at once.
--In the example below notice that we have 5000 repeated 3 times. So 15000 (i.e 5000 + 5000 + 5000) is added to the running total at once. 

SELECT Name, Gender, Salary,
        SUM(Salary) OVER (ORDER BY Salary) AS RunningTotal
FROM Employees

--So when computing running total, it is better to use a column that has unique data in the ORDER BY clause.



-- Part 114 : NTILE function in SQL Server

-- ORDER BY clause is required
-- PARTITION BY clause is optional
-- Distributes the rows into a specified number of groups
-- If the number of rows is not divisible by number of groups, you may have groups of two different sizes.
-- Larger groups come before smaller groups.


--For example

--NTILE(2) of 10 rows divides the rows in 2 Groups (5 in each group)
--NTILE(3) of 10 rows divides the rows in 3 Groups (4 in first group, 3 in 2nd & 3rd group)
--Syntax : NTILE (Number_of_Groups) OVER (ORDER BY Col1, Col2, ...)

use Sample10;

select * from Employees;

--Create Table Employees
--(
--    Id int primary key,
--    Name nvarchar(50),
--    Gender nvarchar(10),
--    Salary int
--)
--Go

--Insert Into Employees Values (1, 'Mark', 'Male', 5000)
--Insert Into Employees Values (2, 'John', 'Male', 4500)
--Insert Into Employees Values (3, 'Pam', 'Female', 5500)
--Insert Into Employees Values (4, 'Sara', 'Female', 4000)
--Insert Into Employees Values (5, 'Todd', 'Male', 3500)
--Insert Into Employees Values (6, 'Mary', 'Female', 5000)
--Insert Into Employees Values (7, 'Ben', 'Male', 6500)
--Insert Into Employees Values (8, 'Jodi', 'Female', 7000)
--Insert Into Employees Values (9, 'Tom', 'Male', 5500)
--Insert Into Employees Values (10, 'Ron', 'Male', 5000)


SELECT Name, Gender, Salary, NTILE(3) OVER (ORDER BY Salary) AS [Ntile]
FROM Employees

--What if the specified number of groups is GREATER THAN the number of rows
--NTILE function will try to create as many groups as possible with one row in each group. 

--With 10 rows in the table, NTILE(11) will create 10 groups with 1 row in each group.

SELECT Name, Gender, Salary, NTILE(11) OVER (ORDER BY Salary) AS [Ntile]
FROM Employees

--NTILE function with PARTITION BY clause : When the data is partitioned, NTILE function creates the specified number of groups with in each partition.


SELECT Name, Gender, Salary,NTILE(3) OVER (PARTITION BY GENDER ORDER BY Salary) AS [Ntile]
from Employees



-- Part 115: Lead and Lag functions in SQL Server 2012

--  Lead function is used to acess subsquent row data along with current row data.
--  Lag function is used to access previous row data along with current row data.
--  ORDER By clause is required
--  PARTITION BY clause is optional

--Syntax
--LEAD(Column_Name, Offset, Default_Value) OVER (ORDER BY Col1, Col2, ...)
--LAG(Column_Name, Offset, Default_Value) OVER (ORDER BY Col1, Col2, ...)

--Offset - Number of rows to lead or lag.
--Default_Value - The default value to return if the number of rows to lead or lag goes beyond first row or last row in a table or partition. 
--If default value is not specified NULL is returned.

--Create Table Employees
--(
--     Id int primary key,
--     Name nvarchar(50),
--     Gender nvarchar(10),
--     Salary int
--)
--Go

--Insert Into Employees Values (1, 'Mark', 'Male', 1000)
--Insert Into Employees Values (2, 'John', 'Male', 2000)

--Insert Into Employees Values (3, 'Pam', 'Female', 3000)

--Insert Into Employees Values (4, 'Sara', 'Female', 4000)
--Insert Into Employees Values (5, 'Todd', 'Male', 5000)
--Insert Into Employees Values (6, 'Mary', 'Female', 6000)
--Insert Into Employees Values (7, 'Ben', 'Male', 7000)
--Insert Into Employees Values (8, 'Jodi', 'Female', 8000)
--Insert Into Employees Values (9, 'Tom', 'Male', 9000)
--Insert Into Employees Values (10, 'Ron', 'Male', 9500)

use Sample10;
Select * from Employees

--Lead and Lag functions example WITHOUT partitions : This example Leads 2 rows and Lags 1 row from the current row.
--When you are on the first row, LEAD(Salary, 2, -1) allows you to move forward 2 rows and retrieve the salary from the 3rd row.
--When you are on the first row, LAG(Salary, 1, -1) allows us to move backward 1 row. Since there no rows beyond row 1, Lag function in this case returns the default value -1.
--When you are on the last row, LEAD(Salary, 2, -1) allows you to move forward 2 rows. Since there no rows beyond the last row 1, Lead function in this case returns the default value -1.
--When you are on the last row, LAG(Salary, 1, -1) allows us to move backward 1 row and retrieve the salary from the previous row.

SELECT Name, Gender, Salary, LEAD(Salary,2,-1) OVER (ORDER BY Salary) AS Lead_2, LAG(Salary,1,-1) OVER (ORDER BY Salary) AS Lag_1
FROM Employees

--Lead and Lag functions example WITH partitions : Notice that in this example, Lead and Lag functions return default value if the number of rows to lead or lag goes beyond first row or 
--last row in the partition. 

SELECT Name, Gender, Salary, LEAD(Salary,2,-1) OVER (PARTITION BY Gender ORDER BY Salary) AS Lead_2, LAG(Salary,1,-1) OVER (PARTITION BY Gender ORDER BY Salary) AS Lag_1
FROM Employees


-- Part 116: FIRST_VALUE function in SQL Server


-- FIRST_VALUE function
-- Retrives the first value from the specified column
-- ORDER BY clause is required
-- PARTITION BY clause is optional

--Syntax : FIRST_VALUE(Column_Name) OVER (ORDER BY Col1, Col2, ...)

--FIRST_VALUE function example WITHOUT partitions : In the following example, FIRST_VALUE function returns the name of the lowest paid employee from the entire table.

SELECT Name,Gender,Salary, FIRST_VALUE(Name) OVER (ORDER BY Salary) AS FirstValue
FROM Employees


--FIRST_VALUE function example WITH partitions : In the following example, FIRST_VALUE function returns the name of the lowest paid employee from the respective partition.

SELECT Name, Gender, Salary, FIRST_VALUE(Name) OVER (PARTITION BY Gender ORDER BY Salary ) As FirstValue
FROM Employees



-- Part 117 : Window functions in SQL Server

-- In SQL Server, we have different categories of window functions

-- Aggregate functions - AVG, SUM, COUNT, MIN, MAX etc
-- Ranking  functions - RANK, DENSE_RANK, ROW_NUMBER etc
-- Analytic functions - LEAD, LAG, FIRST_VALUE, LAST_VALUE etc

--OVER Clause defines the partitioning and ordering of a rows (i.e a window) for the above functions to operate on. Hence these functions are called window functions.
--The OVER clause accepts the following three arguments to define a window for these functions to operate on.
--ORDER BY : Defines the logical order of the rows
--PARTITION BY : Divides the query result set into partitions. The window function is applied to each partition separately.
--ROWS or RANGE clause : Further limits the rows within the partition by specifying start and end points within the partition.
--The default for ROWS or RANGE clause is
--RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

--Let us understand the use of ROWS or RANGE clause with an example.

-- Compute average salary and display it against every employee row as shown below.
--We might think the following query would do the job. 


SELECT Name,Gender, Salary, AVG(Salary) OVER (ORDER BY SALARY) AS Average
FROM Employees

-- As you can see from the result below, the above query does not produce the overall salary average. It produces the average of the current row and the rows preceeding the current row. 
--This is because, the default value of ROWS or RANGE clause (RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) is applied.



--To fix this, provide an explicit value for ROWS or RANGE clause as shown below. 
--ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING tells the window function to operate on the set of rows starting from the first row in the partition to the last row in the partition.

SELECT Name, Gender, Salary, AVG(Salary) OVER (ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Average
FROM Employees

--The same result can also be achieved by using RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

--What is the difference between ROWS and RANGE

--The following query can be used if you want to compute the average salary of 
--1. The current row
--2. One row PRECEDING the current row and 
--3. One row FOLLOWING the current row


SELECT Name, Gender, Salary, AVG(Salary) OVER(ORDER BY Salary ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS Average
FROM Employees


-- Part 119 : Difference between rows and range

create database Sample13;

Create Table Employees
(
     Id int primary key,
     Name nvarchar(50),
     Salary int
)
Go

Insert Into Employees Values (1, 'Mark', 1000)
Insert Into Employees Values (2, 'John', 2000)
Insert Into Employees Values (3, 'Pam', 3000)
Insert Into Employees Values (4, 'Sara', 4000)
Insert Into Employees Values (5, 'Todd', 5000)

select * from Employees

--Calculate the running total of Salary and display it against every employee row
--The following query calculates the running total. We have not specified an explicit value for ROWS or RANGE clause.
SELECT Name, Salary, SUM(Salary) OVER (ORDER BY Salary) AS RunningTotal
FROM Employees

--So the above query is using the default value which is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

--This means the above query can be re-written using an explicit value for ROWS or RANGE clause as shown below.
SELECT Name, Salary,
        SUM(Salary) OVER(ORDER BY Salary
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Employees

--We can also achieve the same result, by replacing RANGE with ROWS
SELECT Name, Salary,
        SUM(Salary) OVER(ORDER BY Salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Employees


--What is the difference between ROWS and RANGE
--To understand the difference we need some duplicate values for the Salary column in the Employees table.

--Execute the following UPDATE script to introduce duplicate values in the Salary column
Update Employees set Salary = 1000 where Id = 2
Update Employees set Salary = 3000 where Id = 4
Go


--Now execute the following query. Notice that we get the running total as expected.
SELECT Name, Salary,
        SUM(Salary) OVER(ORDER BY Salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Employees


--The following query uses RANGE instead of ROWS
--You get the following result when you execute the above query. Notice we don't get the running total as expected.
SELECT Name, Salary,
        SUM(Salary) OVER(ORDER BY Salary
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Employees

--So, the main difference between ROWS and RANGE is in the way duplicate rows are treated. ROWS treat duplicates as distinct values, where as RANGE treats them as a single entity.

--All together side by side. The following query shows how running total changes


--1. When no value is specified for ROWS or RANGE clause


--2. When RANGE clause is used explicitly with it's default value
--3. When ROWS clause is used instead of RANGE clause

SELECT Name, Salary,
        SUM(Salary) OVER(ORDER BY Salary) AS [Default],
        SUM(Salary) OVER(ORDER BY Salary
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Range],
        SUM(Salary) OVER(ORDER BY Salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Rows]
FROM Employees


-- Part 119 : LAST_VALUE function in SQL Server
--LAST_VALUE function 
--Introduced in SQL Server 2012
--Retrieves the last value from the specified column
--ORDER BY clause is required
--PARTITION BY clause is optional
--ROWS or RANGE clause is optional, but for it to work correctly you may have to explicitly specify a value

--Syntax : LAST_VALUE(Column_Name) OVER (ORDER BY Col1, Col2, ...)


-- LAST_VALUE function not working as expected : In the following example, LAST_VALUE function does not return the name of the highest paid employee.
-- This is because we have not specified an explicit value for ROWS or RANGE clause.
-- As a result it is using it's default value RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
use Sample9;
select * from Employees

SELECT Name, Gender, Salary, LAST_VALUE(Name) OVER (ORDER BY Salary) AS LastValue
FROM Employees


--LAST_VALUE function working as expected : In the following example, LAST_VALUE function returns the name of the highest paid employee as expected. 
--Notice we have set an explicit value for ROWS or RANGE clause to ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

--This tells the LAST_VALUE function that it's window starts at the first row and ends at the last row in the result set.

SELECT Name, Gender, Salary, LAST_VALUE(Name) OVER (ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastValue
FROM Employees

--LAST_VALUE function example with partitions : In the following example, LAST_VALUE function returns the name of the highest paid employee from the respective partition.

SELECT Name, Gender, Salary, LAST_VALUE(Name) OVER (PARTITION BY Gender ORDER BY Salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastValue
FROM Employees



-- Part 122 : Choose function in SQL Server

--Choose function 
--Introduced in SQL Server 2012
--Returns the item at the specified index from the list of available values
--The index position starts at 1 and NOT 0 (ZERO)

--Syntax : CHOOSE( index, val_1, val_2, ... )

SELECT CHOOSE(2,'India','US','UK') AS Country

use Sample13;

Create Table Employees2
(
  Id int Primary key identity,
  Name nvarchar(10),
  DateOfBirth date
)


Insert into Employees2 values ('Mark', '01/11/1980')
Insert into Employees2 values ('John', '12/12/1981')
Insert into Employees2 values ('Amy', '11/21/1979')
Insert into Employees2 values ('Ben', '05/14/1978')
Insert into Employees2 values ('Sara', '03/17/1970')
Insert into Employees2 values ('David', '04/05/1978')

select * from Employees2


--Using CASE statement in SQL Server

SELECT Name, DateOfBirth,
        CASE DATEPART(MM, DateOfBirth)
            WHEN 1 THEN 'JAN'
            WHEN 2 THEN 'FEB'
            WHEN 3 THEN 'MAR'
            WHEN 4 THEN 'APR'
            WHEN 5 THEN 'MAY'
            WHEN 6 THEN 'JUN'
            WHEN 7 THEN 'JUL'
            WHEN 8 THEN 'AUG'
            WHEN 9 THEN 'SEP'
            WHEN 10 THEN 'OCT'
            WHEN 11 THEN 'NOV'
            WHEN 12 THEN 'DEC'
        END
       AS [MONTH]
FROM Employees2

-- Using CHOOSE function in SQL Server : the amount of code we have to write is lot less than using CASE statement.

SELECT Name, DateOfBirth, CHOOSE(DATEPART(MM, DateOfBirth),'JAN','FEB','MAR','APR', 'MAY', 'JUN', 'JUL', 'AUG',
       'SEP', 'OCT', 'NOV', 'DEC') 
FROM Employees2



-- Part 123 : IFF function is SQL Server

--IIF function
--Introduced in SQL Server 2012
--Returns one of two the values, depending on whether the Boolean expression evaluates to true or false
--IIF is a shorthand way for writing a CASE expression

--Syntax : IIF ( boolean_expression, true_value, false_value )

DECLARE @Gender INT
SET @Gender = 1

SELECT IIF(@Gender = 1, 'Male', 'Female') AS Gender

use Sample13;
Create Table Employees3
(
 Id int primary key identity,
 Name nvarchar(10),
 GenderId int
)


Insert into Employees3 values ('Mark', 1)
Insert into Employees3 values ('John', 1)
Insert into Employees3 values ('Amy', 2)
Insert into Employees3 values ('Ben', 1)
Insert into Employees3 values ('Sara', 2)
Insert into Employees3 values ('David', 1)

--Write a query to display Gender along with employee Name and GenderId. We can achieve this either by using CASE or IIF.

--Using IIF function
SELECT Name,GenderId, IIF(GenderId = 1,'Male','Female') AS Gender
FROM Employees3


--Using CASE statement
SELECT Name, GenderId,
        CASE WHEN GenderId = 1
                      THEN 'Male'
                      ELSE 'Female'
                   END AS Gender
FROM Employees3


-- Part 124 : TRY PARSE function in SQL Server

--In this video we will discuss 
--TRY_PARSE function
--Difference between PARSE and TRY_PARSE functions

--TRY_PARSE function
--Introduced in SQL Server 2012
--Converts a string to Date/Time or Numeric type
--Returns NULL if the provided string cannot be converted to the specified data type
--Requires .NET Framework Common Language Runtime (CLR)

--Syntax : TRY_PARSE ( string_value AS data_type )

--Example : Convert string to INT. As the string can be converted to INT, the result will be 99 as expected.

--SELECT TRY_PARSE('99' AS INT) AS Result\


Select TRY_PARSE('99' AS INT) AS Result

--Example : Convert string to INT. The string cannot be converted to INT, so TRY_PARSE returns NULL

SELECT TRY_PARSE('ABC' AS INT) AS Result

--Use CASE statement or IIF function to provide a meaningful error message instead of NULL when the conversion fails.

SELECT IIF(TRY_PARSE('ABC' AS INT) IS NULL,'Conversion Failed','Conversion Successful') AS Result

SELECT
CASE WHEN TRY_PARSE('ABC' AS INT) IS NULL
           THEN 'Conversion Failed'
           ELSE 'Conversion Successful'
END AS Result

--What is the difference between PARSE and TRY_PARSE

--PARSE will result in an error if the conversion fails, where as TRY_PARSE will return NULL instead of an error.

--Since ABC cannot be converted to INT, PARSE will return an error
SELECT PARSE('ABC' AS INT) AS Result

-- Since ABC cannot be converted to INT, TRY_PARSE will return NULL instead of an error
SELECT TRY_PARSE('ABC' AS INT) AS Result


-- Using TRY_PARSE() function with table data. We will use the following Employees table for this example.
use Sample13;

Create table Employees4
(
     Id int primary key identity,
     Name nvarchar(10),
     Age nvarchar(10)
)

Insert into Employees4 values ('Mark', '40')
Insert into Employees4 values ('John', '20')
Insert into Employees4 values ('Amy', 'THIRTY')
Insert into Employees4 values ('Ben', '21')
Insert into Employees4 values ('Sara', 'FIFTY')
Insert into Employees4 values ('David', '25')

SELECT NAME, TRY_PARSE(Age AS INT) AS Age
FROM Employees4


--If you use PARSE instead of TRY_PARSE, the query fails with an error.

SELECT Name, PARSE(Age AS INT) AS Age
FROM Employees4


-- TRY CONVERT function in SQL Server 

--TRY_CONVERT function
--Difference between CONVERT and TRY_CONVERT functions
--Difference between TRY_PARSE and TRY_CONVERT functions

use Sample13;



--Create table Employees4
--(
--     Id int primary key identity,
--     Name nvarchar(10),
--     Age nvarchar(10)
--)
--Go

--Insert into Employees4 values ('Mark', '40')
--Insert into Employees4 values ('John', '20')
--Insert into Employees4 values ('Amy', 'THIRTY')
--Insert into Employees4 values ('Ben', '21')
--Insert into Employees4 values ('Sara', 'FIFTY')
--Insert into Employees4 values ('David', '25')


SELECT Name,TRY_CONVERT(INT,Age) AS Age
FROM Employees4

--If you use CONVERT instead of TRY_CONVERT, the query fails with an error.

SELECT Name, CONVERT(INT,Age) AS Age
FROM Employees4

--The above query returns the following error
--Conversion failed when converting the nvarchar value 'THIRTY' to data type int.


--Difference between TRY_PARSE and TRY_CONVERT functions
-- TRY_PARSE can only be used for converting from string to date/time or number data types where as TRY_CONVERT can be used for any general type conversions.

--For example, you can use TRY_CONVERT to convert a string to XML data type, where as you can not do the same using TRY_PARSE


--Converting a string to XML data type using TRY_CONVERT
SELECT TRY_CONVERT(XML, '<root><child/></root>') AS [XML]

SELECT TRY_PARSE('<root><child/></root>' AS XML) AS [XML]


--Another difference is TRY_PARSE relies on the presence of .the .NET Framework Common Language Runtime (CLR) where as TRY_CONVERT does not.


-- Part 126 : EOMONTH function in SQL Server

--EOMONTH function
--Introduced in SQL Server 2012
--Returns the last day of the month of the specified date

--Syntax : EOMONTH ( start_date [, month_to_add ] )


--start_date : The date for which to return the last day of the month
--month_to_add : Optional. Number of months to add to the start_date. EOMONTH adds the specified number of months to start_date, and then returns the last day of the month for the resulting date.


SELECT EOMONTH('11/20/2021') AS LastDay

--Example : Returns last day of the month of February from a NON-LEAP year
SELECT EOMONTH('2/20/2019') AS LastDay


--Example : Returns last day of the month of February from a LEAP year
SELECT EOMONTH('2/20/2016') AS LastDay

--month_to_add optional parameter can be used to add or subtract a specified number of months from the start_date, and then return the last day of the month from the resulting date.

--The following example adds 2 months to the start_date and returns the last day of the month from the resulting date
SELECT EOMONTH('3/20/2019', 2) AS LastDay

--he following example subtracts 1 month from the start_date and returns the last day of the month from the resulting date
SELECT EOMONTH('3/20/2020', -1) AS LastDay

--Using EOMONTH function with table data. We will use the following Employees table for this example.

use Sample13;

Create table Employees5
(
    Id int primary key identity,
    Name nvarchar(10),
    DateOfBirth date
)
Go

Insert into Employees5 values ('Mark', '01/11/1980')
Insert into Employees5 values ('John', '12/12/1981')
Insert into Employees5 values ('Amy', '11/21/1979')
Insert into Employees5 values ('Ben', '05/14/1978')
Insert into Employees5 values ('Sara', '03/17/1970')
Insert into Employees5 values ('David', '04/05/1978')


SELECT Name, DateOfBirth, EOMONTH(DateOfBirth) AS LastDay
FROM Employees5

--If you want just the last day instead of the full date, you can use DATEPART function

SELECT Name, DateOfBirth, DATEPART(DD,EOMONTH(DateOfBirth)) AS LastDay
FROM Employees5

-- Part 127 : DATEFROMPARTS function in SQL Server

--DATEFROMPARTS function
--Introduced in SQL Server 2012
--Returns a date value for the specified year, month, and day
--The data type of all the 3 parameters (year, month, and day) is integer
--If invalid argument values are specified, the function returns an error
--If any of the arguments are NULL, the function returns null
--Syntax : DATEFROMPARTS ( year, month, day )

--Example : All the function arguments have valid values, so DATEFROMPARTS returns the expected date

SELECT DATEFROMPARTS ( 2015, 10, 25) AS [Date]

--Example : Invalid value specified for month parameter, so the function returns an error

SELECT DATEFROMPARTS ( 2015, 15, 25) AS [Date]


SELECT DATEFROMPARTS ( 2015, NULL, 25) AS [Date]


--Other new date and time functions introduced in SQL Server 2012
--EOMONTH (Discussed in Part 125 of SQL Server tutorial)
--DATETIMEFROMPARTS : Returns DateTime
--Syntax : DATETIMEFROMPARTS ( year, month, day, hour, minute, seconds, milliseconds )

--SMALLDATETIMEFROMPARTS : Returns SmallDateTime
--Syntax : SMALLDATETIMEFROMPARTS ( year, month, day, hour, minute)





-- Part 128 : Difference between DateTime and SmallDateTime in SQL Server
-- https://csharp-video-tutorials.blogspot.com/2015/10/difference-between-datetime-and.html
-- The range for SmallDateTime is Janunary 1, 1900, through June 6, 2079. A value outside of this range is not allowed.


use Sample13;

Create Table Employees6(
   id int primary key identity,
   SmallDateTime smalldatetime ,
   DateTime datetime
)

ALTER TABLE Employees6 ALTER COLUMN  SmallDateTime smalldatetime NULL;
ALTER TABLE Employees6 ALTER COLUMN  DateTime datetime NULL;

-- Date Range Difference
-- The following 2 queries have values outside of the range of SmallDateTime data type.

-- SmallDateTime - January 1, 1900 to June 6, 2079
Insert into Employees6([SmallDateTime]) values ('01/01/1899')
Insert into Employees6([SmallDateTime]) values ('07/06/2079')

--When executed, the above queries fail with the following error
--The conversion of a varchar data type to a smalldatetime data type resulted in an out-of-range value


-- The range for DateTime is January 1,1753 throgh December 31,9999. A value outside of this range is not allowed.

-- The following query has a value outside of the range of DateTime data type.

Insert into Employees6([DateTime]) values ('01/01/1752')

--When executed, the above query fails with the following error
--The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.


-- Time Range Difference
-- Values  with 29.998 seconds or lower are rounded down
-- SmallDateTime - Time rounded to 12.35

insert into Employees6([SmallDateTime]) values ('01/01/1995 12:35:29:998')

select * from Employees6
Truncate table Employees6

-- Values with 29.999 seconds or higher are rounded up
-- SmallDateTime -- Time rounded to 12:36

insert into Employees6 ([SmallDateTime]) values ('01/01/1995 12:35:29:999')


-- values are rounded to increments of .000, 003 or .007 seconds
-- DateTime - Time rounded to 01/01/99 23:59:59:990

insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.990')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.991')

insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.992')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.993')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.994')

insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.995')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.996')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.997')
insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.998')


insert into Employees6([DateTime]) values ('01/01/1995 23:59:59.999')


-- Part 129 : DateTime2FromParts function in SQL Server 2012

--DateTime2FromParts function
--Introduced in SQL Server 2012
--Returns DateTime2
--The data type of all the parameters is integer
--If invalid argument values are specified, the function returns an error
--If any of the required arguments are NULL, the function returns null
--If the precision argument is null, the function returns an error
--Syntax : DATETIME2FROMPARTS ( year, month, day, hour, minute, seconds, fractions, precision )

--Example : All the function arguments have valid values, so DATETIME2FROMPARTS returns DATETIME2 value as expected.


SELECT DATETIME2FROMPARTS(2018,11,15,20,55,55,0,0) AS [DateTime2]

--Example : Invalid value specified for month parameter, so the function returns an error

SELECT DATETIME2FROMPARTS (2018, 15, 15, 20, 55, 55, 0, 0 ) AS [DateTime2]

--Output : Cannot construct data type datetime2, some of the arguments have values which are not valid.

--Example : If any of the required arguments are NULL, the function returns null. NULL specified for month parameter, so the function returns NULL.

SELECT DATETIME2FROMPARTS ( 2015, NULL, 15, 20, 55, 55, 0, 0 ) AS [DateTime2]


--Example : If the precision argument is null, the function returns an error

SELECT DATETIME2FROMPARTS ( 2015, 15, 15, 20, 55, 55, 0, NULL ) AS [DateTime2]

--Output : Scale argument is not valid. Valid expressions for data type datetime2 scale argument are integer constants and integer constant expressions.


-- Part 130 : Difference between DateTime and DateTime2 in SQL Server
--https://csharp-video-tutorials.blogspot.com/2015/10/difference-between-datetime-and_21.html

-- Part 131 :  Offset fetch next in SQL Server

 --One of the common tasks for a SQL developer is to come up with a stored procedure that can return a page of results from the result set.
 --With SQL Server 2012 OFFSET FETCH Clause it is very easy to implement paging. 
 --Let's understand this with an example. We will use the following tblProducts table for the examples in this video. The table has got 100 row.

 use Sample13;

 CREATE TABLE tblProducts
 (
   Id int primary key identity,
   Name nvarchar(25),
   [Description] nvarchar(50),
   Price int
 )

 Declare @Start int
 Set @Start = 1

 Declare @Name nvarchar(25)
 Declare @Description nvarchar(50)

 while(@Start <=100)
 Begin
	Set @Name = 'Product - ' + LTRIM(@Start)
	Set @Description = 'Product Description - ' + LTRIM(@Start)

	Insert into tblProducts values (@Name,@Description,@Start*10)
	Set @Start = @Start + 1
 End

 SELECT * FROM tblProducts


-- OFFSET FETCH Clause
--Introduced in SQL Server 2012
--Returns a page of results from the result set
--ORDER BY clause is required

--OFFSET FETCH Syntax : 
--SELECT * FROM Table_Name
--ORDER BY Column_List
--OFFSET Rows_To_Skip ROWS
--FETCH NEXT Rows_To_Fetch ROWS ONLY


SELECT * FROM tblProducts
ORDER BY Id
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY

--From the front-end application, we would typically send the PAGE NUMBER and the PAGE SIZE to get a page of rows. 
--The following stored procedure accepts PAGE NUMBER and the PAGE SIZE as parameters and returns the correct set of rows.

CREATE PROCEDURE spGetRowsByPageNumberAndSize
@PageNumber INT,
@PageSize INT
AS
BEGIN
	SELECT * FROM tblProducts
	ORDER BY Id
	OFFSET (@PageNumber -1) * @PageSize Rows
	FETCH NEXT @PageSize ROWS ONLY
END

EXECUTE spGetRowsByPageNumberAndSize 3, 10



