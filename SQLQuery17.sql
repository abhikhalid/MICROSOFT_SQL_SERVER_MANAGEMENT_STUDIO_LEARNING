-- Part 132 : Identifying object dependencies in SQL Server

--The following SQL Script creates 2 tables, 2 stored procedures and a view

CREATE TABLE Departments
(
 Id int primary key identity,
 Name nvarchar(50)
)

Create TABLE Employees7
(
 Id int primary key identity,
 Name nvarchar(50),
 Gender nvarchar(10),
 DeptId int foreign key references Departments(Id)
)


Create procedure sp_GetEmployees
as
begin
	Select * from Employees7
end

Create procedure sp_GetEmployeesandDepartments
as 
begin
	Select Employees7.Name as EmployeeName, Departments.Name as Department 
	from Employees7
	join Departments
	on Employees7.DeptId = Departments.Id
end


create view VwDepartments
as
Select * from Departments

--How to find dependencies using SQL Server Management Studio
--Use View Dependencies option in SQL Server Management studio to find the object dependencies


--For example : To find the dependencies on the Employees table, right click on it and select View Dependencies from the context menu


--In the Object Dependencies window, depending on the radio button you select, you can find the objects that depend on Employees table and the objects on which Employees table depends on.


--Identifying object dependencies is important especially when you intend to modify or delete an object upon which other objects depend. Otherwise you may risk breaking the functionality.


--For example, there are 2 stored procedures (sp_GetEmployees and sp_GetEmployeesandDepartments) that depend on the Employees table. If we are not aware of these dependencies and if we delete the Employees table, both stored procedures will fail with the following error.


--Msg 208, Level 16, State 1, Procedure sp_GetEmployees, Line 4
--Invalid object name 'Employees'.

--There are other ways for finding object dependencies in SQL Server which we will discuss in our upcoming videos.



-- Part 133 : sys dm sql referencing entities in SQL Server

--In this video we will discuss 

--How to find object dependencies using the following dynamic management functions
--sys.dm_sql_referencing_entities
--sys.dm_sql_referenced_entities
--Difference between 
--Referencing entity and Referenced entity
--Schema-bound dependency and Non-schema-bound dependency



--Difference between 
--Referencing entity and Referenced entity
--Schema-bound dependency and Non-schema-bound dependency


--The following example returns all the objects that depend on Employees table.
Select * from sys.dm_sql_referenced_entities('dbo.Employees7','Object')



-- Part 135 : Sequence object in SQL Server 2012
--Generates sequence of numeric values in an ascending or descending order
--https://csharp-video-tutorials.blogspot.com/2015/10/sequence-object-in-sql-server-2012.html
--Creating an Incrementing Sequence : The following code create a Sequence object that starts with 1 and increments by 1

CREATE SEQUENCE [dbo].[SequenceObject]
AS INT
START WITH 1
INCREMENT BY 1	

--Generating the Next Sequence Value : Now we have a sequence object created. To generate the sequence value use NEXT VALUE FOR clause

SELECT NEXT VALUE FOR [dbo].[SequenceObject]


-- Every time, you execute the above query the sequence value will be incremented by 1. I executed the above query 13 times, so the current value is 13

-- Retrieving the current sequence value : If you want to see what the current Sequence value before generating the next, use sys.sequences

SELECT * FROM sys.sequences WHERE name = 'SequenceObject'

--Alter the Sequence object to reset the sequence value : 

ALTER SEQUENCE [SequenceObject] RESTART WITH 1	

-- Select the next sequence value to make sure the value starts from 1

SELECT NEXT VALUE FOR [dbo].[SequenceObject]

--Using sequence value in an INSERT query : 


CREATE TABLE Employees8
(
  Id INT PRIMARY KEY,
  NAME NVARCHAR(50),
  Gender NVARCHAR(10)
)

-- Generate and insert Sequence values

INSERT INTO Employees8 VALUES(NEXT VALUE for [dbo].[SequenceObject], 'Ben','Male')
INSERT INTO Employees8 VALUES(NEXT VALUE for [dbo].[SequenceObject], 'Sara','Female')

SELECT * FROM Employees8

--Creating the decrementing Sequence : The following code create a Sequence object that starts with 100 and decrements by 1

CREATE SEQUENCE [dbo].[SequenceObject2]
AS INT
START WITH 100
INCREMENT BY -1

--Specifying MIN and MAX values for the sequence : Use the MINVALUE and MAXVALUE arguments to specify the MIN and MAX values respectively.

--Step 1 : Create the Sequence object

CREATE SEQUENCE [dbo].[SequenceObject3]
START WITH 100
INCREMENT BY 10
MINVALUE 100
MAXVALUE 150

--Step 2 : Retrieve the next sequence value. The sequence value starts at 100. Every time we call NEXT VALUE, the value will be incremented by 10. 

SELECT NEXT VALUE FOR [dbo].[SequenceObject3]

--If you call NEXT VALUE, when the value reaches 150 (MAXVALUE), you will get the following error
--The sequence object 'SequenceObject' has reached its minimum or maximum value. Restart the sequence object to allow new values to be generated.


--Recycling Sequence values : When the sequence object has reached it's maximum value, and if you want to restart from the minimum value, set CYCLE option

ALTER SEQUENCE [dbo].[SequenceObject3]
INCREMENT BY 10
MINVALUE 100
MAXVALUE 150
CYCLE

--At this point, whe the sequence object has reached it's maximum value, and if you ask for the NEXT VALUE, sequence object starts from the minimum value again which in this case is 100.


--To improve performance, the Sequence object values can be cached using the CACHE option. When the values are cached they are read from the memory instead of from the disk,
--which improves the performance. When the cache option is specified you can also specify the size of the cache , that is the number of values to cache.

--The following example, creates the sequence object with 10 values cached. When the 11th value is requested, the next 10 values will be cached again.

CREATE SEQUENCE [dbo].[SequenceObject4]
START WITH 1
INCREMENT BY 1
CACHE 10


-- Part 136 : Difference between sequence and identity in SQL Server
-- https://csharp-video-tutorials.blogspot.com/2015/10/difference-between-sequence-and.html


-- Part 137 : Guid in SQL Server

--What is Guid in SQL Server
--The GUID data type is a 16 byte binary data type that is globally unique. GUID stands for Global Unique Identifier. The terms GUID and UNIQUEIDENTIFIER are used interchangeably.

-- To declare a GUID variable, we use the keyword UNIQUEIDENTIFIER

Declare @ID UNIQUEIDENTIFIER
SELECT @ID = NEWID()
SELECT @ID as MYGUID




--How to create a GUID in sql server
--To create a GUID in SQL Server use NEWID() function

--For example, SELECT NEWID(), creates a GUID that is guaranteed to be unique across tables, databases, and servers. Every time you execute SELECT NEWID() query, you get a GUID that is unique.

--Example GUID : 0BB83607-00D7-4B2C-8695-32AD3812B6F4

--When to use GUID data type : Let us understand when to use a GUID in SQL Server with an example. 



--1. Let us say our company does business in 2 countries - USA and India. 

--2. USA customers are stored in a table called USACustomers in a database called USADB.

Create Database USADB
Go

Use USADB
Go

Create Table USACustomers
(
     ID int primary key identity,
     Name nvarchar(50)
)
Go

Insert Into USACustomers Values ('Tom')
Insert Into USACustomers Values ('Mike')

Select * From USADB.dbo.USACustomers

--3. India customers are stored in a table called IndiaCustomers in a database called IndiaDB.

Create Database IndiaDB
Go

Use USADB
Go

Create Table IndiaCustomers
(
     ID int primary key identity,
     Name nvarchar(50)
)
Go

Insert Into IndiaCustomers Values ('John')
Insert Into IndiaCustomers Values ('Ben')

Select * From IndiaDB.dbo.IndiaCustomers


--In both the tables, the ID column data type is integer. It is also the primary key column which ensures the ID column across every row is unique in that table. We also have turned on the identity property,


--4. Now, we want to load the customers from both countries (India & USA) in to a single existing table Customers.

Create Table Customers
(
     ID int primary key,
     Name nvarchar(50)
)


Insert Into Customers
Select * from IndiaDB.dbo.IndiaCustomers
Union All
Select * from USADB.dbo.USACustomers


--We get the following error. This is because in both the tables, Identity column data type is integer. Integer is great for identity as long as you only want to maintain the uniqueness across just that one table. However, between IndiaCustomers and USACustomers tables, the ID coulumn values are not unique. So when we load the data into Customers table, we get "Violation of PRIMARY KEY constraint" error.

--Msg 2627, Level 14, State 1, Line 1
--Violation of PRIMARY KEY constraint. Cannot insert duplicate key in object 'dbo.Customers'. The duplicate key value is (1).
--The statement has been terminated.



--A GUID on the other hand is unique across tables, databases, and servers. A GUID is guaranteed to be globally unique. Let us see if we can solve the above problem using a GUID.

Go

Create Table USACustomers1
(
     ID uniqueidentifier primary key default NEWID(),
     Name nvarchar(50)
)
Go

Insert Into USACustomers1 Values (Default, 'Tom')
Insert Into USACustomers1 Values (Default, 'Mike')

--Next, create IndiaCustomers1 table and populate it with data.

Use IndiaDB
Go

Create Table IndiaCustomers1
(
     ID uniqueidentifier primary key default NEWID(),
     Name nvarchar(50)
)
Go

Insert Into IndiaCustomers1 Values (Default, 'John')
Insert Into IndiaCustomers1 Values (Default, 'Ben')


--Select data from both the tables (USACustomers1 & IndiaCustomers1). Notice the ID column values. They are unique across both the tables.

Select * From IndiaDB.dbo.IndiaCustomers1
UNION ALL
Select * From USADB.dbo.USACustomers1


--Now, we want to load the customers from USACustomers1 and IndiaCustomers1 tables in to a single existing table called Customers1. Let us first create Customers1 table. The ID column in Customers1 table is uniqueidentifier.

Create Table Customers1
(
     ID uniqueidentifier primary key,
     Name nvarchar(50)
)
Go

--Finally, execute the following insert script. Notice the script executes successfully without any errors and the data is loaded into Customers1 table.

Insert Into Customers1
Select * from IndiaDB.dbo.IndiaCustomers1
Union All
Select * from USADB.dbo.USACustomers1


--The main advantage of using a GUID is that it is unique across tables, databases and servers. It is extremely useful if you're consolidating records from multiple SQL Servers into a single table. 


--The main disadvantage of using a GUID as a key is that it is 16 bytes in size. It is one of the largest datatypes in SQL Server. An integer on the other hand is 4 bytes,

--An Index built on a GUID is larger and slower than an index built on integer column. In addition a GUID is hard to read compared to int.



--So in summary, use a GUID when you really need a globally unique identifier. In all other cases it is better to use an INT data type.



-- Part 138 : How to check GUID is null or empty in SQL Server

--http://csharp-video-tutorials.blogspot.com/2017/03/how-to-check-guid-is-null-or-empty-in.html