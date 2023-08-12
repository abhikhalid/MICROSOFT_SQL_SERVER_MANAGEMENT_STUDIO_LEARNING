--CREATE DATABASE Sample1;

use Sample1
Go

CREATE TABLE tblGender
(
	ID int NOT NULL Primary Key,
	Gender nvarchar(50) NOT NULL
)

Alter table tblPerson add constraint tblPerson_GenderID_FK
Foreign Key (GenderId) references tblGender(ID)


--/////////////////////////--

Select * from tbl_Gender
Select * from tbl_Personn

Insert into tbl_Personn (ID,Name,Email) Values (9,'Rich','r@r.com')

--Cascading referential integrity constraint - Part 5
--CRATING A DEFAULT CONSTRAINT
ALTER TABLE tbl_Personn
ADD CONSTRAINT DF_tblPerson_GenderId
DEFAULT 3 FOR GenderId


--DROP A CONSTRAINT
ALTER TABLE tbl_Personn
DROP CONSTRAINT DF_tblPerson_GenderId

--Delete
Delete from tbl_Gender where ID = 2

-- Check Constraint

SELECT * from tbl_Personn

--DELETE FROM tbl_Personn where ID = 10

INSERT INTO tbl_Personn values(10,'Sara','s@s.com',1,-970);

-- creating a check constraint manually
ALTER Table tbl_Personn
ADD Constraint CK_tbl_Personn_Age CHECK (Age >0 AND Age < 150)

-- Drop a check contraint
ALTER Table tbl_Personn
Drop Constraint CK_tblPerson_Age

--Identity Column in SQL Server - Part 7
    
--if you mark a column as an idenity column, you don't need to supply a value
-- for it.

 SELECT * FROM dbo.tblPerson1

 INSERT INTO dbo.tblPerson1 values('Prianka')
 
 SET IDENTITY_INSERT dbo.tblPerson1 ON

 INSERT INTO dbo.tblPerson1 (PersonId,Name) values(1,'Khalid')

 DELETE FROM tblPerson1 where PersonId = 1

  SET IDENTITY_INSERT dbo.tblPerson1 OFF
 
 INSERT INTO dbo.tblPerson1 values('Mahmud')

 -- Delete everything from the tblPerson1 table

 DELETE from tblPerson1

 SELECT * FROM dbo.tblPerson1
 --reset the identity value
 
 DBCC CHECKIDENT (tblPerson1, RESEED,0)

 INSERT INTO dbo.tblPerson1 values('Prianka')

 ---------------------------------
 --USER1
 --How to get the last generated identity column value in SQL Server - Part 8

 Create Table Test1(
   ID int identity(1,1),
   Value nvarchar(20)
 )
 Create Table Test2(
   ID int identity(1,1),
   Value nvarchar(20)
 )

 INSERT INTO Test1 Values ('X')
 Select * from Test1
 Select * from Test2

 -- the last generated identity column value
 Select SCOPE_IDENTITY()
 --another way using global variable
 Select @@IDENTITY
 Select IDENT_CURRENT('Test2')

 Create Trigger trForInsert on Test1 for Insert
 as
 Begin
	Insert into Test2 Values('YYYY')
 End
  ---------------------------------
 --Unique key constraint - Part 9

 Alter Table tbl_Personn
 Add Constraint UQ_tblPerson_Email Unique(Email)

 Select * from tbl_Personn

 insert into tbl_Personn values(9,'Khalid','k@k.com',1,26)

 --Alter Table tbl_Personn
 --Drop Constraint UQ_tblPerson_Email

 --Select statement in sql server
 SELECT * from tbl_Personn

 Select Distinct City from tbl_Personn

 SELECT * from tbl_Personn Where City = 'London'

  SELECT * from tbl_Personn Where City <> 'London'

  SELECT * from tbl_Personn Where City != 'London'

  Select * from tbl_Personn Where Age = 20 or Age = 23 or Age =29

  Select * from tbl_Personn Where Age IN (20,23,29)

  Select * from tbl_Personn Where Age BETWEEN 20 AND 25

  Select * from tbl_Personn Where City LIKE 'L%'

  Select * from tbl_Personn Where NOT Email LIKE '%@%'

  Select * from tbl_Personn Where  Email LIKE '_@_.com'

  Select * from tbl_Personn Where  Email LIKE '_@_.com'

  Select * from tbl_Personn Where  Name LIKE '[MST]%'

  Select * from tbl_Personn Where  Name LIKE '[^MST]%'

  Select * from tbl_Personn Where (City = 'London' or City='Sylhet')
  AND Age > 25

  Select * from tbl_Personn
  order by Name 

  Select * from tbl_Personn
  order by Name DESC

  Select * from tbl_Personn
  order by Name DESC, Age ASC

  SELECT top 3 * from tbl_Personn

  SELECT top 50 percent * from tbl_Personn
  
  Select * from tbl_Personn Order by Age DESC
  
  --Group by in sql server - Part 11
  
  Select * from tbl_Personn

  Select SUM(Salary) from tbl_Personn
  Select MIN(Salary) from tbl_Personn
  Select MAX(Salary) from tbl_Personn

  Select City, SUM(Salary) as TotalSalary
  from tbl_Personn
  Group By City

  Select City,GenderId,SUM(Salary) as TotalSalary
  from tbl_Personn
  Group By City,GenderId
  Order by City
  
  Select Count(ID) from tbl_Personn

  Select City,GenderId,SUM(Salary) as TotalSalary,Count(ID) as [Total Employees]
  from tbl_Personn
  Group By City,GenderId
  Order by City

  Select City,GenderId,SUM(Salary) as TotalSalary,Count(ID) as [Total Employees]
  from tbl_Personn
  Where GenderId = 1
  Group By City,GenderId
  Order by City

  Select City,GenderId,SUM(Salary) as TotalSalary,Count(ID) as [Total Employees]
  from tbl_Personn
  Group By City,GenderId
  Having GenderId = 1
  Order by City

  Select City,GenderId,SUM(Salary) as TotalSalary,Count(ID) as [Total Employees]
  from tbl_Personn
  Group By City,GenderId
  Having SUM(Salary) > 5000

  --/////////////////////////////

  --Joins in sql server - Part 12

  --Create employee and department table
  SELECT * from tblEmployee
  Select * from tblDepartment

  --ALTER TABLE tblEmployee
  --ALTER COLUMN DepartmentId int NULL

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  LEFT JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id

   SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  RIGHT JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  FUll OUTER JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  CROSS JOIN tblDepartment

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  LEFT JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id
  --Where tblEmployee.DepartmentId IS NULL
  Where tblDepartment.Id IS NULL

  SELECT Name, Gender, Salary, DepartmentName
  from tblEmployee
  FULL JOIN tblDepartment
  ON tblEmployee.DepartmentId = tblDepartment.Id
  Where tblEmployee.DepartmentId IS NULL
  OR tblDepartment.Id IS NULL

  -----------------------

  --Self join in sql server - Part 14

  SELECT * FROM tblEmployess;

  Select E.Name as Employee, M.Name as ManagerName
  FROM tblEmployess E
  LEFT JOIN tblEmployess M
  ON E.ManagerId = M.EmployeeId

  Select E.Name as Employee, M.Name as ManagerName
  FROM tblEmployess E
  INNER JOIN tblEmployess M
  ON E.ManagerId = M.EmployeeId

  Select E.Name as Employee, M.Name as ManagerName
  FROM tblEmployess E
  CROSS JOIN tblEmployess M

  --Different ways to replace NULL in sql server - Part 15
  
  SELECT ISNULL('KHALID','No Manager') as Manager
  Select COALESCE('KHALID','No Manager') as Manager

  Select E.Name as Employee,
  --ISNULL(M.Name,'No Manager')
  COALESCE(M.Name,'No Manager')
  as Manager
  FROM tblEmployess E
  LEFT JOIN tblEmployess M
  ON E.ManagerId = M.EmployeeId

  Select E.Name as Employee,
  CASE WHEN M.NAME IS NULL THEN 'No Manager' ELSE M.NAME END 
  as Manager
  FROM tblEmployess E
  LEFT JOIN tblEmployess M
  ON E.ManagerId = M.EmployeeId

  --Coalesce function in sql server Part 16
  -- this function returns the first non null value

  Select *  from tbl_Students;

  Select Id, COALESCE(FirstName,MiddleName,LastName)
  From tbl_Students

--Union and union all in sql server Part 17
-- Union & Union All operators in sql server, are used to combine
-- the result-set of two or more SELECT queries.

SELECT Id, Name, Email
FROM tblInidaCustomers
UNION
SELECT Id, Name, Email
FROM tblUKCustomers

SELECT Id, Name, Email
FROM tblInidaCustomers
UNION ALL
SELECT Id, Name, Email
FROM tblUKCustomers
ORDER BY Name

----------------------------- 
--Stored procedures in sql server Part 18

SELECT * from tblEmployee

--CREATE PROCEDURE spGetEmployees
--AS
--BEGIN
--   Select Name, Gender from tblEmployee
--END

ALTER PROCEDURE spGetEmployees
AS
BEGIN
   Select Name, Gender from tblEmployee
   order by Name
END

  
EXEC spGetEmployees
EXECUTE spGetEmployees


----------------------------------


spGetEmployeesByGenderAndDepartment 'Male',1

spGetEmployeesByGenderAndDepartment @DepartmentId = 1, @Gender = 'Male'

--Create Proc spGetEmployeesByGenderAndDepartment
--@Gender nvarchar(20),
--@DepartmentId int
--AS
--BEGIN
--	Select Name, Gender, DepartmentId
--	from tblEmployee 
--	where Gender=@Gender and
--	DepartmentId = @DepartmentId
--END

ALTER Proc spGetEmployeesByGenderAndDepartment
@Gender nvarchar(20),
@DepartmentId int
WITH Encryption
AS
BEGIN
	Select Name, Gender, DepartmentId
	from tblEmployee 
	where Gender=@Gender and
	DepartmentId = @DepartmentId
END



sp_helptext spGetEmployeesByGenderAndDepartment

--------------------------
--Stored procedures with output parameters Part 19

SELECT * from tblEmployee

Alter Procedure speGetEmplyeeCountByGender
@Gender nvarchar(20),
@EmployeeCount int output
as
Begin
	Select @EmployeeCount = COUNT(Id) from tblEmployee where Gender = @Gender
End

----Declare @TotalCount int
----Execute speGetEmplyeeCountByGender 'Male', @TotalCount Output
----Print @TotalCount

----if(@TotalCount is null)
----	Print '@TotalCount is null'
----else 
----	Print 'TotalCount is not null'

--or

Declare @TotalCount int
Execute speGetEmplyeeCountByGender @EmployeeCount = @TotalCount out, @Gender = 'Male'
Print @TotalCount

sp_help spGetEmployeesByGenderAndDepartment

sp_help tblEmployee

sp_helptext spGetEmployeesByGenderAndDepartment

sp_depends spGetEmployeesByGenderAndDepartment

sp_depends tblEmployee


--Stored procedure output parameters or return values Part 20

Create Proc spGetTotalCount1
@TotalCount int Out
as
Begin
	Select @TotalCount = Count(Id)
	FROM tblEmployee
END

Declare @Total int
Execute spGetTotalCount1 @Total Out
Print @Total


Create Procedure spGetTotalCountOfEmployees2
as 
Begin
	return (Select COUNT(ID) from tblEmployee)
End

Declare @TotalEmployees int
Execute @TotalEmployees = spGetTotalCountOfEmployees2
Print @TotalEmployees

-- now the question is, what's the differences between return and output statement? 
-- in some sceneario, return statement can not be used

Create Procedure spGetNameByID1
@Id int,
@Name nvarchar(20) Output
as
Begin
	Select @Name = Name from tblEmployee 
	Where Id = @Id
END

Declare @EmployeeName nvarchar(20)
Execute spGetNameByID1 3,@EmployeeName Out
Print 'Name of the Employee = ' + @EmployeeName

Create Procedure spGetNameById2
@Id int
as
Begin
	Return (Select name from tblEmployee Where Id = @Id)
End

Declare @EmployeeName nvarchar(20)
Execute @EmployeeName = spGetNameById2 1
Print 'Name of the Employee = ' + @EmployeeName

-- Convertion failed as return statement can only return int value
-- we can return only 1 value, so in this case we will use output parameter

--Built in string functions in sql server 2008 Part 22

SELECT ASCII('A')

Select CHAR(65)

Declare @Start int
Set @Start = 65
While(@Start <=90)
Begin
	Print CHAR(@Start)
	Set @Start = @Start + 1
End

--Declare @Start int
--Set @Start = 97
--While(@Start <= 122)
--Begin
--	Print CHAR(@Start)
--	Set @Start = @Start + 1
--End

Select LTRIM(' Hello')
Select RTRIM(' Hello ')

Create Table tblEmployee2
(
ID int primary key,
FirstName varchar(20),
MiddleName varchar(20),
LastName varchar(20),
Email varchar(20),
Gender varchar(20),
DepartmentID int,
Number int
)

Insert into tblEmployee2 values (1, ' Sam ', 'S', 'Sony','Sam@aaa.com', 'Male', 1, 1)
Insert into tblEmployee2 values (2, ' Ram ', 'R', 'Barber','Ram@aaa.com', 'Male', 1, 1)
Insert into tblEmployee2 values (3, ' Sara ', 'J', 'Sanosky','Sara@ccc.com', 'Female', 1, 1)
Insert into tblEmployee2 values (4, ' Todd ', '', 'Gartner','Todd@bbb.com', 'Male', 1, 1)
Insert into tblEmployee2 values (5, ' John ', '', 'Grover','John@aaa.com', 'Male', 1, 1)
Insert into tblEmployee2 values (6, ' Sana ', 'J', 'Lenin','Sana@ccc.com', 'Female', 1, 1)
Insert into tblEmployee2 values (7, ' James ', 'S', 'Bond','James@bbb.com', 'Male', 1, 1)
Insert into tblEmployee2 values (8, ' Rob ', 'J', 'Hunter','Rob@ccc.com', 'Male', 1, 1)
Insert into tblEmployee2 values (9, ' Steve ', 'R', 'Wilson','Steve@aaa.com', 'Male', 1, 1)
Insert into tblEmployee2 values (10, ' Pam ', 'P', 'Broker','Pam@bbb.com','Female', 1, 1)

Select REVERSE(UPPER(LTRIM(FirstName))) as FirstName, MiddleName, Lower(LastName),
RTRIM(LTRIM(FirstName)) + ' ' + MiddleName + ' ' + LastName as FullName
from tblEmployee2

Select FirstName, LEN(FIRSTNAME) as [Total Characters] 
FROM tblEmployee2

--LEFT, RIGHT, CHARINDEX and SUBSTRING functions in sql server Part 23

SELECT LEFT('ABCDEF',3)

SELECT RIGHT('ABCDEF',3)

Select CHARINDEX('@','sara@aaa.com')

SELECT SUBSTRING('sara@aaa.com',6,7)


SELECT SUBSTRING('pam@bbb.com',6,7)

--instead of hardcoding, let's do this

Select SUBSTRING('John@bbb.com',(CHARINDEX('@', 'John@bbb.com') + 1), (LEN('John@bbb.com') - CHARINDEX('@','John@bbb.com')))

Select SUBSTRING(Email,(CHARINDEX('@', Email) + 1),
(LEN(Email) - CHARINDEX('@',Email))) as EmailDomain
FROM tblEmployee2

Select * from tblEmployee2

Select SUBSTRING(Email, CHARINDEX('@', Email) + 1,
LEN(Email) - CHARINDEX('@', Email)) as EmailDomain,
COUNT(Email) as Total
from tblEmployee2
Group By SUBSTRING(Email, CHARINDEX('@', Email) + 1,
LEN(Email) - CHARINDEX('@', Email))

--Replicate, Space, Patindex, Replace and Stuff string functions in sql server 2008 Part 24

--https://csharp-video-tutorials.blogspot.com/2012/08/replicate-space-patindex-replace-and.html

--Mathematical functions in sql server Part 29

--https://csharp-video-tutorials.blogspot.com/2012/09/mathematical-functions-in-sql-server.html

--Scalar user defined functions in sql server Part 30

Select SQUARE(3)

Select GETDATE()

--DECLARE @DOB DATE
--DECLARE @Age INT
--SET @DOB = '07/14/1996'

--SET @Age = DATEDIFF(YEAR, @DOB, GETDATE()) - 
--           CASE 
--				WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR
--				(MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
--				THEN 1
--				ELSE 0
--		   END

--SELECT @Age

CREATE FUNCTION Age(@DOB Date)  
RETURNS INT  
AS  
BEGIN  
	 DECLARE @Age INT  
	 SET @Age = DATEDIFF(YEAR, @DOB, GETDATE()) -
	 CASE
	   WHEN (MONTH(@DOB) > MONTH(GETDATE())) OR 
			(MONTH(@DOB) = MONTH(GETDATE()) AND DAY(@DOB) > DAY(GETDATE()))
			THEN 1 
			ELSE 0 
	   END  
	 RETURN @Age  
END

Select dbo.Age('07/14/1996')

--Select Name, DateOfBirth, dbo.Age(DateOfBirth) as Age from tblEmployees

--Select Name, DateOfBirth, dbo.Age(DateOfBirth) as Age 
--from tblEmployees
--Where dbo.Age(DateOfBirth) > 30



--Inline table valued functions in sql server Part 31

CREATE TABLE tblEmployee3
(
Id INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
Name NVARCHAR(50),
DateOfBirth DATETIME,
Gender NVARCHAR(50),
DepartmentId INT
);

INSERT INTO tblEmployee3
VALUES ('Sam', '1980-12-30', 'Male', 1)

INSERT INTO tblEmployee3
VALUES ('Pam', '1982-09-01 12:02:36.260', 'Female', 2)

INSERT INTO tblEmployee3
VALUES ('John', '1985-08-22 12:03:30.370', 'Male', 1)

INSERT INTO tblEmployee3
VALUES ('Sara', '1979-11-29 12:59:30.670', 'Female', 3)

INSERT INTO tblEmployee3
VALUES ('Todd', '1978-11-29 12:59:30.670', 'Male', 1)﻿

-- SCALER FUNCTION - RETURNS A SCALER VALUE
-- INLINE TABLE VALUED FUNCTION - RETURNS A TABLE

CREATE FUNCTION fn_EmployeeByGender(@Gender nvarchar(10))
RETURNS TABLE
AS
RETURN 
(
	SELECT Id, Name, DateOfBirth, Gender, DepartmentId
	from tblEmployee3
	where Gender = @Gender
)

Select * from fn_EmployeeByGender('Male')

select * from tblDepartment

Select Name, Gender,DepartmentName
FROM fn_EmployeeByGender('Male') E
JOIN tblDepartment D ON D.Id = E.DepartmentId

--Multi statement table valued functions in sql server Part 32

--Inline Table Valued function(ILTVF):
Create Function fn_ILTVF_GetEmployees()
Returns Table
as
Return (Select Id, Name, Cast(DateOfBirth as Date) as DOB
        From tblEmployee3)


--Multi-statement Table Valued function(MSTVF):
Create Function fn_MSTVF_GetEmployees()
Returns @Table Table (Id int, Name nvarchar(20), DOB Date)
as
Begin
 Insert into @Table
 Select Id, Name, Cast(DateOfBirth as Date)
 From tblEmployee3
 
 Return
End

--Calling the Inline Table Valued Function:
Select * from fn_ILTVF_GetEmployees()

--Calling the Multi-statement Table Valued Function:
Select * from fn_MSTVF_GetEmployees()

Update  fn_ILTVF_GetEmployees() SET Name = 'Khalid' where Id = 1
select * from tblEmployee3

Update fn_MSTVF_GetEmployees() Set Name = 'Sam 1' where Id = 1
--Object 'fn_MSTVF_GetEmployees' cannot be modified.

--Important concepts related to functions in sql server Part 33

--https://csharp-video-tutorials.blogspot.com/2012/09/important-concepts-related-to-functions.html

--Create Function fn_GetEmployeeNameById(@Id int)
--Returns nvarchar(20)
--With Encryption
--as
--Begin
-- Return (Select Name from tblEmployees Where Id = @Id)
--End

--Alter Function fn_GetEmployeeNameById(@Id int)
--Returns nvarchar(20)
--With SchemaBinding
--as
--Begin
-- Return (Select Name from dbo.tblEmployees Where Id = @Id)
--End


-- Part 34 - Temporary Tables in SQL Server

Create Table #PersonDetails (Id int, Name nvarchar(20))

Insert into #PersonDetails Values(1,'Mike')
Insert into #PersonDetails Values(2,'John')
Insert into #PersonDetails Values(3,'Todd')

Select * from #PersonDetails

Select name from tempdb..sysobjects
where name like '#PersonDetails%'

-- If the temporary table is created inside the stored procedure, it gets dropped automatically upon
-- the completion of stored procedure execcution.

Create Procedure spCreateLocalTempTable
as
Begin
	Create Table #PersonDetails (Id int, Name nvarchar(20))

	Insert into #PersonDetails Values(1,'Mike')
	Insert into #PersonDetails Values(2,'John')
	Insert into #PersonDetails Values(3,'Todd')

	Select * from #PersonDetails
END

-- Select * from #PersonDetails (invalid object)

--It is also possible for different conncetions to create a local temporary table with the same name
-- For example User1 and User2, both can create a local temporary table with the same name.
-- #PersonDetails

-- Global temporary tables are visible to all the conncetions of the sql server, and are only destroyed when the last conncetion 
-- referencing the table is closed

-- Multiple users, across multiple conncections can have local temporary tables with the
-- same name but a global temporary table name has to be unique and if you inspect the name
-- of the global temp table, in the object explorer,there will be no random numbrers suffixed at the end of the table name.



-- Part 35 - Indexes
-- i. What are indexes
-- ii. Why do we use indexed
-- iii. Advantages of indexes

--Indexes in sql server - Part 35
--Why indexes?
--Indexes are used by queries to find data from tables quickly. Indexes are created on tables and views. Index on a table or a view, is very similar to an index that we find in a book.

--If you don't have an index in a book, and I ask you to locate a specific chapter in that book, you will have to look at every page starting from the first page of the book.

--On, the other hand, if you have the index, you lookup the page number of the chapter in the index, and then directly go to that page number to locate the chapter.

--Obviously, the book index is helping to drastically reduce the time it takes to find the chapter.

--In a similar way, Table and View indexes, can help the query to find data quickly.

--In fact, the existence of the right indexes, can drastically improve the performance of the query. If there is no index to help the query, then the query engine, checks every row in the table from the beginning to the end. This is called as Table Scan. Table scan is bad for performance.

SELECT * FROM tblEmployee

Select * from tblEmployee where Salary >=5000 AND Salary <=7000

Create Index IX_tblEmployee_Salary
ON tblEmployee (SALARY ASC)

sp_HelpIndex tblEmployee

drop index tblEmployee.IX_tblEmployee_Salary

--Clustered and nonclustered indexes in sql server Part 36

-- A clustered index determines the physical order of the data in a table, For this reason, a table can have only one clustered index.

-- Note that Id Column is marked as primary key. Primary key constrain craete clustered indexes automatically if no clustered index already exists on the table.


CREATE TABLE tblEmployee4
(
 [Id] int Primary Key,
 [Name] nvarchar(50),
 [Salary] int,
 [Gender] nvarchar(10),
 [City] nvarchar(50)
)


Insert into tblEmployee4 Values(3,'John',4500,'Male','New York')
Insert into tblEmployee4 Values(1,'Sam',2500,'Male','London')
Insert into tblEmployee4 Values(4,'Sara',5500,'Female','Tokyo')
Insert into tblEmployee4 Values(5,'Todd',3100,'Male','Toronto')
Insert into tblEmployee4 Values(2,'Pam',6500,'Female','Sydney')

Select * from tblEmployee4

-- firstly, drop the existing clustered index from object explorer

Create Clustered Index IX_tblEmoloyee4_Gender_Salary
ON tblEmployee4 (Gender DESC, Salary ASC)

Create NonClustered Index  IX_tblEmployee4_Name
ON tblEmployee4(Name)

--Unique and Non-Unique Indexes - Part 37

--https://csharp-video-tutorials.blogspot.com/2012/09/unique-and-non-unique-indexes-part-37.html

--Advantages and disadvantages of indexes in sql server Part 38


--Views in sql server Part 39

-- A view is nothing more than saved query. A view can also be considered as a virtual table
-- it does not store any data

Select * from tblEmployee
Select * from tblDepartment

Create View vWEmployeesByDepartment
as
Select tblEmployee.ID, Name, Salary, Gender, DepartmentName
from tblEmployee
join tblDepartment
on tblEmployee.DepartmentId = tblDepartment.Id

Select * from vWEmployeesByDepartment


--Updatable views in sql server Part 40


Create View vwEmployeeDataExceptSalary
as
Select Id,Name,Gender, DepartmentId
from tblEmployee

Select * from vwEmployeeDataExceptSalary

Update  vwEmployeeDataExceptSalary
Set Name = 'Mikey'  Where Id = 2

Select * from tblEmployee

Delete from vwEmployeeDataExceptSalary where Id = 2
Insert into vwEmployeeDataExceptSalary values (2,'Mikey','Male',2)


Create View vWEmployeeDetailsByDepartment
as
Select tblEmployee.ID, Name, Salary, Gender, DepartmentName
from tblEmployee
join tblDepartment
on tblEmployee.DepartmentId = tblDepartment.Id

Select * from vWEmployeeDetailsByDepartment


Update vWEmployeeDetailsByDepartment
set DepartmentName = 'IT' where Name = 'John'

Select * from tblEmployee
Select * from tblDepartment

-- if a view is based on multiplle tables, and if you update the view, it may not
-- update the underlying tables correctly, To correctly update a view, that view is based on
-- multiple tables, INSTEAD OF triggers are used.


--Indexed views in sql server Part 41

Create view vWTotalSalesByProduct
with SchemaBinding
as
Select Name, 
SUM(ISNULL((QuantitySold * UnitPrice), 0)) as TotalSales, 
COUNT_BIG(*) as TotalTransactions
from dbo.tblProductSales
join dbo.tblProduct
on dbo.tblProduct.ProductId = dbo.tblProductSales.ProductId
group by Name


--If you want to create an Index, on a view, the following rules should be followed by the view. For the complete list of all rules, please check MSDN.
--1. The view should be created with SchemaBinding option

--2. If an Aggregate function in the SELECT LIST, references an expression, and if there is a possibility for that expression to become NULL, then, a replacement value should be specified. In this example, we are using, ISNULL() function, to replace NULL values with ZERO.

--3. If GROUP BY is specified, the view select list must contain a COUNT_BIG(*) expression

--4. The base tables in the view, should be referenced with 2 part name. In this example, tblProduct and tblProductSales are referenced using dbo.tblProduct and dbo.tblProductSales respectively.

--Now, let's create an Index on the view:
--The first index that you create on a view, must be a unique clustered index. After the unique clustered index has been created, you can create additional nonclustered indexes.

Create Unique Clustered Index UIX_vWTotalSalesByProduct_Name
on vWTotalSalesByProduct(Name)


--Since, we now have an index on the view, the view gets materialized. The data is stored in the view. So when we execute Select * from vWTotalSalesByProduct, the data is retrurned from the view itself, rather than retrieving data from the underlying base tables.

--View limitations in sql server Part 42

--https://www.youtube.com/watch?v=NlJvzTpVX8Y&list=PL08903FB7ACA1C2FB&index=43


