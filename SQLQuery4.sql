--Derived tables and common table expressions in sql server Part 48

create database Sample5

CREATE TABLE tblEmployee
(
  Id int Primary Key,
  Name nvarchar(30),
  Gender nvarchar(10),
  DepartmentId int
)

CREATE TABLE tblDepartment
(
 DeptId int Primary Key,
 DeptName nvarchar(20)
)

Insert into tblDepartment values (1,'IT')
Insert into tblDepartment values (2,'Payroll')
Insert into tblDepartment values (3,'HR')
Insert into tblDepartment values (4,'Admin')


Insert into tblEmployee values (1,'John', 'Male', 3)
Insert into tblEmployee values (2,'Mike', 'Male', 2)
Insert into tblEmployee values (3,'Pam', 'Female', 1)
Insert into tblEmployee values (4,'Todd', 'Male', 4)
Insert into tblEmployee values (5,'Sara', 'Female', 1)
Insert into tblEmployee values (6,'Ben', 'Male', 3)

CREATE view vwEmployeeCount
as
select DeptName, COUNT(*) as TotalEmployees
FROM tblEmployee
JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.DeptId
GROUP BY DeptName

select * from vwEmployeeCount
where TotalEmployees >=2

--Now, let's see, how to achieve the same using, temporary tables

select DeptName, COUNT(*) as TotalEmployees
into #TempEmployeeCount
FROM tblEmployee
JOIN tblDepartment
ON tblEmployee.DepartmentId = tblDepartment.DeptId
GROUP BY DeptName


select * from #TempEmployeeCount
where TotalEmployees >=2

--Drop Table #TempEmployeeCount

--Using Table Variable
Declare @tblEmployeeCount table
(DeptName nvarchar(20), DepartmentId int, TotalEmployees int)

insert @tblEmployeeCount
select DeptName, DepartmentId, Count(*) as TotalEmployees
from tblEmployee
join tblDepartment
on tblEmployee.DepartmentId = tblDepartment.DeptId
group by DeptName,DepartmentId

select DeptName, TotalEmployees
from @tblEmployeeCount
where TotalEmployees >=2

-- using Derived Tables

select DeptName, TotalEmployees
from
(
	select DeptName, DepartmentId, Count(*) as TotalEmployees
	from tblEmployee
	join tblDepartment
	on tblEmployee.DepartmentId = tblDepartment.DeptId
	group by DeptName,DepartmentId
)
as EmployeeCount
where TotalEmployees >=2;

--Using CTE

With EmployeeCountt(DeptName, DepartmentId, TotalEmployees)
as
(
 Select DeptName, DepartmentId, COUNT(*) as TotalEmployees
 from tblEmployee
 join tblDepartment
 on tblEmployee.DepartmentId = tblDepartment.DeptId
 group by DeptName, DepartmentId
)

Select DeptName, TotalEmployees
from EmployeeCount
where TotalEmployees >= 2

--Common Table Expressions - Part 49

select * from tblEmployee
select * from tblDepartment

With EmployeeCount(DepartmentId, TotalEmployees)
as
(
 Select DepartmentId, COUNT(*) as TotalEmployees
 from tblEmployee
 group by DepartmentId
)

Select DeptName, TotalEmployees
from tblDepartment
join EmployeeCount
on tblDepartment.DeptId = EmployeeCount.DepartmentId
order by TotalEmployees


--It is also, possible to create multiple CTE's using a single WITH clause.
With EmployeesCountBy_Payroll_IT_Dept(DepartmentName, Total)
as
(
 Select DeptName, COUNT(Id) as TotalEmployees
 from tblEmployee
 join tblDepartment 
 on tblEmployee.DepartmentId = tblDepartment.DeptId
 where DeptName IN ('Payroll','IT')
 group by DeptName
),
EmployeesCountBy_HR_Admin_Dept(DepartmentName, Total)
as
(
 Select DeptName, COUNT(Id) as TotalEmployees
 from tblEmployee
 join tblDepartment 
 on tblEmployee.DepartmentId = tblDepartment.DeptId
 group by DeptName 
)
Select * from EmployeesCountBy_HR_Admin_Dept 
UNION
Select * from EmployeesCountBy_Payroll_IT_Dept


--Updatable common table expressions in sql server Part 50


With Employees_Name_Gender(Id,Name,Gender)
as
(
 Select Id, Name, Gender from tblEmployee
)

select * from Employees_Name_Gender

Update Employees_Name_Gender Set Gender = 'Female' where Id = 1


With EmployeesByDepartment
as
(
 Select Id,Name,Gender,DeptName
 from tblEmployee
 join tblDepartment
 on tblDepartment.DeptId = tblEmployee.DepartmentId
)

select * from EmployeesByDepartment

--CTE is based on more than one table, and if the UPDATE affects only one base table, then the UPDATE is allowed. 

WITH EmployeesByDepartment
as
(
 select Id,Name,Gender,DeptName
 From tblEmployee
 JOIN tblDepartment
 on tblEmployee.DepartmentId = tblDepartment.DeptId
)

--UPDATE EmployeesByDepartment set Gender = 'Male' where Id = 1

-- not possible, because this update will affect multiple base table
--Update EmployeesByDepartment set Gender = 'Female', DeptName = 'IT'
--where Id = 1

--let's try to update just the DeptName

Update EmployeesByDepartment
set DeptName = 'IT' where Id = 1

--So in short if, 
--1. A CTE is based on a single base table, then the UPDATE suceeds and works as expected.
--2. A CTE is based on more than one base table, and if the UPDATE affects multiple base tables, the update is not allowed and the statement terminates with an error.
--3. A CTE is based on more than one base table, and if the UPDATE affects only one base table, the UPDATE succeeds(but not as expected always)


--Error handling in sql server 2000 - Part 55

use Sample5;

Create Table tblProduct
(
  ProductId int NOT NULL primary key,
  Name nvarchar(50),
  UnitPrice int,
  QtyAvailable int
)

insert into tblProduct values(1,'Laptops',2340,100)
insert into tblProduct values(2,'Desktops',3467,50)

Create Table tblProductSales
(
  ProductSalesId int primary key,
  ProductId int,
  QuantitySold int
)

Create Procedure spSellProduct
@ProductId int,
@QuantityToSell int
as
Begin
	Declare @StockAvailable int
	Select @StockAvailable = QtyAvailable from tblProduct
	where ProductId = @ProductId

	if(@StockAvailable < @QuantityToSell)
		begin
		Raiserror('Not enough stock available',16,1)
		end
    else
	 begin
		begin tran
			--fisrt reduce the quantity available
			update tblProduct set QtyAvailable = QtyAvailable - @QuantityToSell where ProductId = @ProductId

			Declare @MaxProductSalesId int

			Select @MaxProductSalesId = Case When Max(ProductSalesId) IS NULL Then 0 else Max(ProductSalesId)
			from tblProductSales

			insert into tblProductSales values (@MaxProductSalesId+1,@ProductId,@QuantityToSell)
		commit tran
	 end
End

-- the problem with this procedure is that, the transaction is always committed. Even, if there is an error somewhere, between updating tblProduct and tblProductSales table

Alter Procedure spSellProductCorrected
@ProductId int,
@QuantityToSell int
as
begin
	--check the stock available for the product we want to sell
	Declare @StockAvailable int
	Select @StockAvailable = QuantitySold from tblProduct where ProductId = @ProductId

	-- Throw an error to the calling function, if enough stock is not available
	if(@StockAvailable <@QuantityToSell)
		Begin
			Raiserror('Not enough stock available',16,1)
		End
     else
	   begin
		begin tran
			-- first reduce the quantity available
			update tblProduct set QtyAvailable = QtyAvailable - @StockAvailable
				   where ProductId = @ProductId
			
			Declare @MaxProductSalesId int
			--Calculate Max ProductSalesId

			Select @MaxProductSalesId = Case When  MAX(tblProductSales) IS NULL Then 0 else Max(tblProductSales) end
			from tblProductSales

			Set @MaxProductSalesId = @MaxProductSalesId + 1

			Insert into tblProductSales(@MaxProductSalesId,@ProductId,@QuantityToSell)

			if(@@ERROR !=0)
				begin
					Rollback Tran
					Print 'Rolled Back Transaction'
				end
			else 
				begin
					Commit Tran
					Print 'Committed Transaction'
				end
	   end
end

--Error handling in sql server 2005, and later versions - Part 56

Create Procedure spSellProduct
@ProductId int,
@QuantityToSell int
as
Begin
	-- Check the stock available, for the product we want to sell
	Declare @StockAvailable

	Select @StockAvailable = QtyAvailable
	from tblProduct where ProductId = @ProductId

	--Throw and error to the calling function, if enough stock is not available
	if(@StockAvailable <@QuantityToSell)
		begin
			Raiserror('Not enough stock available',16,1)
		end
	-- if enough stock available
	else
	 begin
		begin try
		 begin transaction
			--first reduce the quantity available
			update tblProduct set QtyAvailable = QtyAvailable - @StockAvailable
			where ProductId = @ProductId

			Declare @MaxProductSalesId

			Select @MaxProductSalesId = CASE WHEN MAX(ProductSalesId) is null then 0 else MAX(ProductSalesId) end
			from tblProductSales

			set @MaxProductSalesId = @MaxProductSalesId + 1

			insert into tblProductSales values (@MaxProductSalesId,@ProductId,@QuantityToSell)

		 commit transaction
		end try
		begin catch
			rollback transaction
			--in the scope of the CATCH block, there are several system functions, that are used to retrieve more information about the error that occurred  These functions return NULL if they are executed outside the scope of the CATCH block.

			Select ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage,
			ERROR_PROCEDURE() as ErrorProcedure,
			ERROR_STATE() as ErrorState,
			ERROR_SEVERITY() as ErrorSeverity,
			ERROR_LINE() AS ErrorLine
		end catch
	 end
End


--Transactions in SQL Server - Part 57
use Sample5;

Create Table tblMailingAddress
(
	AddressId int NOT NULL primary key,
	EmployeeNumber int,
	HouseNumber nvarchar(50),
	StreetAddress nvarchar(50),
	City nvarchar(10),
	PostalCode nvarchar(50)
)

Insert into tblMailingAddress values (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW')

Create Table tblPhysicalAddress
(
	AddressId int NOT NULL primary key,
	EmployeeNumber int,
	HouseNumber nvarchar(50),
	StreetAddress nvarchar(50),
	City nvarchar(10),
	PostalCode nvarchar(50)
)

Insert into tblPhysicalAddress values (1, 101, '#10', 'King Street', 'Londoon', 'CR27DW')

Create Procedure spUpdateAddress
as
Begin
	Begin Try
   BEGIN transaction
   Update tblMailingAddress set City = 'LONDON' 
   where AddressId = 1 and EmployeeNumber = 101
   
   Update tblPhysicalAddress set City = 'LONDON' 
   where AddressId = 1 and EmployeeNumber = 101
	
	commit transaction
	End Try
	begin catch
		rollback transaction
	end catch
End


--Let's now make the second UPDATE statement, fail. CITY column length in tblPhysicalAddress table is 10. The second UPDATE statement fails, because the value for CITY column is more than 10 characters.

Alter Procedure spUpdateAddress
as
begin
	begin try
		begin transaction
			  Update tblMailingAddress set City = 'LONDON12' 
			   where AddressId = 1 and EmployeeNumber = 101
   
			   Update tblPhysicalAddress set City = 'LONDON LONDON' 
			   where AddressId = 1 and EmployeeNumber = 101
		commit transaction
	end try
	begin catch
	  rollback transaction
	end catch
end

--Transactions in sql server and ACID Tests Part 58

--Subqueries in sql - Part 59

Create Database Sample6;

use Sample6;

Create Table tblProducts
(
	Id int identity primary key,
	Name nvarchar(50),
	Description nvarchar(50)
)

Create Table tblProductSales
(
 Id int primary key identity,
 ProductId int foreign key references tblProducts(Id),
 UnitPrice int,
 QuantitySold int
)

Insert into tblProducts values ('TV', '52 inch black color LCD TV')
Insert into tblProducts values ('Laptop', 'Very thin black color acer laptop')
Insert into tblProducts values ('Desktop', 'HP high performance desktop')

Insert into tblProductSales values(3, 450, 5)
Insert into tblProductSales values(2, 250, 7)
Insert into tblProductSales values(3, 450, 4)
Insert into tblProductSales values(3, 450, 9)

--Write a query to retrieve products that are not at all sold?

Select * from tblProducts
where Id not in (Select Id from tblProductSales)

--Query with an equivalent join that produces the same result.

Select *
FROM tblProducts
LEFT JOIN tblProductSales
ON tblProducts.Id = tblProductSales.Id
WHERE tblProducts.Id IS NOT NULL

--In this example, we have seen how to use a subquery in the where clause.

--Let us now discuss about using a sub query in the SELECT clause. Write a query to retrieve the NAME and TOTALQUANTITY sold, using a subquery.

Select [Name],
(Select SUM(QuantitySold) from tblProductSales where ProductId = tblProducts.Id) as TotalQuantity
from tblProducts
order by Name


--Query with an equivalent join that produces the same result.

Select [Name], SUM(QuantitySold) as TotalQuantity
from tblProducts
left join tblProductSales
on tblProducts.Id = tblProductSales.ProductId
group by [Name]
order by Name

--From these examples, it should be very clear that, a subquery is simply a select statement, that returns a single value and can be nested inside a SELECT, UPDATE, INSERT, or DELETE statement. 


--Correlated subquery in sql - Part 60

--here subquery is executed first and only once.
-- The subquery result are then used by the outer query.
-- A non-corelated sub query can be executed independently of the outer query.

Select Id, Name, Description
From tblProducts
Where Id not In (Select Distinct ProductId from tblProductSales)

-- If the subquery depends on the outer query for its value then the sub query is called as a correlated subquery.

Select [Name],
(Select SUM(QuantitySold) from tblProductSales where ProductId = tblProducts.Id) as TotalQuantity
from tblProducts
order by Name


--Creating a large table with random data for performance testing - Part 61



-- If Table exists drop the tables
If (Exists (select * 
            from information_schema.tables 
            where table_name = 'tblProductSales'))
Begin
 Drop Table tblProductSales
End

If (Exists (select * 
            from information_schema.tables 
            where table_name = 'tblProducts'))
Begin
 Drop Table tblProducts
End



-- Recreate tables
Create Table tblProducts
(
 [Id] int identity primary key,
 [Name] nvarchar(50),
 [Description] nvarchar(250)
)

Create Table tblProductSales
(
 Id int primary key identity,
 ProductId int foreign key references tblProducts(Id),
 UnitPrice int,
 QuantitySold int
)

--Insert Sample data into tblProducts table
Declare @Id int
Set @Id = 1

While(@Id <= 300000)
Begin
 Insert into tblProducts values('Product - ' + CAST(@Id as nvarchar(20)), 
 'Product - ' + CAST(@Id as nvarchar(20)) + ' Description')
 
 Print @Id
 Set @Id = @Id + 1
End

-- Declare variables to hold a random ProductId, 
-- UnitPrice and QuantitySold
declare @RandomProductId int
declare @RandomUnitPrice int
declare @RandomQuantitySold int

-- Declare and set variables to generate a 
-- random ProductId between 1 and 100000
declare @UpperLimitForProductId int
declare @LowerLimitForProductId int

set @LowerLimitForProductId = 1
set @UpperLimitForProductId = 100000

-- Declare and set variables to generate a 
-- random UnitPrice between 1 and 100
declare @UpperLimitForUnitPrice int
declare @LowerLimitForUnitPrice int

set @LowerLimitForUnitPrice = 1
set @UpperLimitForUnitPrice = 100

-- Declare and set variables to generate a 
-- random QuantitySold between 1 and 10
declare @UpperLimitForQuantitySold int
declare @LowerLimitForQuantitySold int

set @LowerLimitForQuantitySold = 1
set @UpperLimitForQuantitySold = 10

--Insert Sample data into tblProductSales table
Declare @Counter int
Set @Counter = 1

While(@Counter <= 450000)
Begin
 select @RandomProductId = Round(((@UpperLimitForProductId - @LowerLimitForProductId) * Rand() + @LowerLimitForProductId), 0)
 select @RandomUnitPrice = Round(((@UpperLimitForUnitPrice - @LowerLimitForUnitPrice) * Rand() + @LowerLimitForUnitPrice), 0)
 select @RandomQuantitySold = Round(((@UpperLimitForQuantitySold - @LowerLimitForQuantitySold) * Rand() + @LowerLimitForQuantitySold), 0)
 
 Insert into tblProductsales 
 values(@RandomProductId, @RandomUnitPrice, @RandomQuantitySold)

 Print @Counter
 Set @Counter = @Counter + 1
End

--Finally, check the data in the tables using a simple SELECT query to make sure the data has been inserted as expected.
Select * from tblProducts
Select * from tblProductSales


--Part 65 - List all tables in a sql server database using a query

--https://csharp-video-tutorials.blogspot.com/2013/06/part-65-list-all-tables-in-sql-server.html

--Writing re runnable sql server scripts Part 66

Use Sample6;

Create Table tblEmployee
(
  ID int identity primary key,
  Name nvarchar(100),
  Gender nvarchar(10),
  DataOfBirth DateTime
)

-- if you run this script more than once, you will get an error

-- to make this re-runnable

Use Sample6;

if not exists(Select * from INFORMATION_SCHEMA where table_name = 'tblEmployee')
Begin
	Create Table tblEmployee
	(
	 ID int identity primary key,
	 Name nvarchar(100),
	 Gender nvarchar(10),
	 DateOfBirth DateTime
	)
	Print 'Table tblEmployee successfully created'
End
Else
Begin
	print 'Table tblEmployee alreayd exists'
End

-- the above script is re-runnable and can be run any number of times.

-- Sql server built-in function OBJECT_ID() can also be used to check for the existence of the table

IF OBJECT_ID('tblEmployee') IS NULL
BEGIN
   --sql statement to create table
   Print 'Table tblEmployee created'
END
ELSE
BEGIN
   Print 'Table tblEmployee already exists!'
END

--Let's look at another example. The following sql script adds column "EmailAddress" to table tblEmployee. This script is not re-runnable because, if the column exists we get a script error.
--Col_length() function can also be used to check for the existence of a column
If col_length('tblEmployee','EmailAddress') is not null
Begin
 Print 'Column already exists'
End
Else
Begin
 Print 'Column does not exist'
End



--Part 67 - Alter database table columns without dropping table

Alter table tblEmployee
Alter column Salary int

--Part 68 - Optional parameters in sql server stored procedures
use Sample6;

CREATE TABLE tblEmployee
(
 Id int IDENTITY PRIMARY KEY,
 Name nvarchar(50),
 Email nvarchar(50),
 Age int,
 Gender nvarchar(50),
 HireDate date,
)

Insert into tblEmployee values
('Sara Nan','Sara.Nan@test.com',35,'Female','1999-04-04')
Insert into tblEmployee values
('James Histo','James.Histo@test.com',33,'Male','2008-07-13')
Insert into tblEmployee values
('Mary Jane','Mary.Jane@test.com',28,'Female','2005-11-11')
Insert into tblEmployee values
('Paul Sensit','Paul.Sensit@test.com',29,'Male','2007-10-23')

Create Proc spSearchEmployees
as
@Name nvarchar(50) = NULL,
@Email nvarchar(50) = NULL,
@Age int = NULL,
@Gender nvarchar(50) = NULL
Begin
  Select * from tblEmployee where
  (Name = @Name or @Name is NULL) AND
  (Email = @Email or @Email is NULL) AND
  (Age = @Age or @Age is NULL) AND
  (Gender = @Gender or @Gender is NULL)
End

Execute spSearchEmployees -- this command will return all the rows
Execute spSearchEmployees @Gender = 'Male' -- Returns only male employees
Execute spSearchEmployees @Gender = 'Male',@Age = 29 -- Returns male employees whose age is 29


-- Part 70 : sql server concurrent transactions

--Database Concurrency Problem

--i. Dirty Read
--ii. Lost Update
--iii. Non-Repeatable Read
--iv. Phantom Reads

--Sql Server Provides different Isolation Level to balance 
--concurrency problem and performance depending on our application needs.

--i. Read Uncommitted.
--ii. Read Committed.
--iii. Repeatable Read.
--iv. Snapshot.
--v. Serializable