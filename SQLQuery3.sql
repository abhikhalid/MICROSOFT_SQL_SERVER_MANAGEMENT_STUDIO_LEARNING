-- DML Triggers - Part 43

-- Trigger is a special kind of sp that fires automatically when an even occurs in sql server.

-- DML trigger can be classified into 2 types. 

-- i. After Triggers. ii. Instead of triggers.

CREATE DATABASE Sample3

CREATE TABLE tblEmployee
(
 Id int Primary Key,
 Name nvarchar(30),
 Salary int,
 Gender nvarchar(10),
 DepartmentId int
)

INSERT into tblEmployee values (1,'John',5000,'Male',3)
insert into tblEmployee values (2,'Mike',3400,'Male',2)
insert into tblEmployee values (3,'Pam',6000,'Female',1)

CREATE TABLE tblEmployeeAudit
(
 Id int identity(1,1) primary key,
 AuditData nvarchar(1000)
)

CREATE TRIGGER tr_tblEmployee_ForInsert
ON tblEmployee
FOR INSERT
AS
BEGIN
   Declare @Id int
   Select @Id = Id from inserted

   insert into tblEmployeeAudit
   values ('New employee with Id = '+Cast(@Id as nvarchar(5)) + 'is added at '
   + cast(GETDATE() as nvarchar(20)))
END

insert into tblEmployee values (4,'Khalid',60000,'Male',1)

select * from tblEmployeeAudit

CREATE TRIGGER tr_tblEmployee_ForDelete
ON tblEmployee
FOR DELETE
AS
BEGIN
	Declare @Id int
	Select @Id = Id from deleted

	insert into tblEmployeeAudit 
	values('An existing employee with Id = '+CAST(@Id as nvarchar(5)) + 'is deleted at '+ CAST(GETDATE() as nvarchar(20)))
END

DELETE FROM tblEmployee where Id = 1


-- Part 44 : After Update Trigger

--Triggers make use of 2 special tables, INSERTED and DELETED. The inserted table contains the updated data and the deleted table contains the old data. The After trigger for UPDATE event, makes use of both inserted and deleted tables. 

--CREATE TRIGGER tr_tblEmployee_ForUpdate
--on tblEmployee
--for Update
--as
--Begin
--	Select * from deleted
--	select * from inserted
--END

--select * from tblEmployee

--Update tblEmployee set Name = 'Israr' where id = 3

Alter trigger tr_tblEmployee_ForUpdate
on tblEmployee
for Update
as 
Begin
	Declare @Id int
	Declare @Oldname nvarchar(20), @NewName nvarchar(20)
	Declare @OldSalary nvarchar(20), @NewSalary nvarchar(20)
	Declare @OldGender nvarchar(20), @NewGender nvarchar(20)
	Declare @OldDeptId int, @NewDeptId int

	Declare @AuditString nvarchar(1000)

	Select *
	into #TempTable
	FROM inserted

	while(Exists(select id from #TempTable))
	begin
	    --initialize the audit string to empty string
		set @AuditString = ''

		--select the first row from  temp table
		select top 1 @Id = Id, @NewName = Name,
		@NewGender = Gender, @NewSalary = Salary,
		@NewDeptId = DepartmentId
		from #TempTable

		--select the corresponding row from deleted table
		select @OldName = Name, @OldGender = Gender, @OldSalary = Salary,
		@OldDeptId = DepartmentId from deleted where Id = @Id

		-- Build the audit string dynamically           
            Set @AuditString = 'Employee with Id = ' + Cast(@Id as nvarchar(4)) + ' changed'
            if(@OldName <> @NewName)
                  Set @AuditString = @AuditString + ' NAME from ' + @OldName + ' to ' + @NewName
                 
            if(@OldGender <> @NewGender)
                  Set @AuditString = @AuditString + ' GENDER from ' + @OldGender + ' to ' + @NewGender
                 
            if(@OldSalary <> @NewSalary)
                  Set @AuditString = @AuditString + ' SALARY from ' + Cast(@OldSalary as nvarchar(10))+ ' to ' + Cast(@NewSalary as nvarchar(10))
                  
     if(@OldDeptId <> @NewDeptId)
                  Set @AuditString = @AuditString + ' DepartmentId from ' + Cast(@OldDeptId as nvarchar(10))+ ' to ' + Cast(@NewDeptId as nvarchar(10))
           
            insert into tblEmployeeAudit values(@AuditString)
            
            -- Delete the row from temp table, so we can move to the next row
            Delete from #TempTable where Id = @Id
	end
End


-- Instead of insert trigger Part 45

CREATE DATABASE Sample4

CREATE TABLE tblEmployee
(
 Id int primary key,
 Name nvarchar(30),
 Gender nvarchar(10),
 DepartmentId int
)

Create table tblDepartment
(
 DeptId int Primary Key,
 DeptName nvarchar(20)
)

insert into tblDepartment values (1,'IT')
insert into tblDepartment values (2,'Paroll')
insert into tblDepartment values (3,'HR')
insert into tblDepartment values (4,'Admin')

insert into tblEmployee values (1,'John','Male',3)
insert into tblEmployee values (2,'Mike', 'Male',2)
insert into tblEmployee values (3,'Pam','Female',1)
insert into tblEmployee values (4,'Todd','Male',4)
insert into tblEmployee values (5,'Sara','Female',1)
insert into tblEmployee values (6,'Ben', 'Male',3)

--Since, we now have the required tables, let's create a view based on these tables. The view should return Employee Id, Name, Gender and DepartmentName columns. So, the view is obviously based on multiple tables.

Create view vWEmployeeDetails
as
Select Id,Name,Gender,DeptName
from tblEmployee
join tblDepartment
on tblEmployee.DepartmentId = tblDepartment.DeptId

select * from vWEmployeeDetails


-- 'View or function vWEmployeeDetails is not updatable because the modification affects multiple base tables.'
Insert into vWEmployeeDetails values(7, 'Valarie', 'Female', 'IT')

--So, inserting a row into a view that is based on multipe tables, raises an error by default. Now, let's understand, how INSTEAD OF TRIGGERS can help us in this situation. Since, we are getting an error, when we are trying to insert a row into the view, let's create an INSTEAD OF INSERT trigger on the view vWEmployeeDetails

alter trigger tr_vWEmployeeDetails_InsteadOfInsert
on vWEmployeeDetails
instead of insert
as 
begin
 Declare @DeptId int

 SELECT @DeptId = DeptId
 FROM tblDepartment
 JOIN inserted 
 on inserted.DeptName = tblDepartment.DeptName

 if(@DeptId is null)
 Begin
	Raiserror('Invalid Department Name. Statement terminated',16,1)
	return
 End
 
  insert into tblEmployee
  Select Id, Name, Gender, @DeptId
  from inserted
end


--Instead of update triggers - Part 46
--use Sample4

select * from vWEmployeeDetails

-- error, because it will affect multiple base table
Update vWEmployeeDetails 
set Name = 'Johny', DeptName = 'IT'
where Id = 1

-- it will not update correctly, change hr dept to it dept
Update vWEmployeeDetails 
set DeptName = 'IT'
where Id = 1

--so, if a view is based on multiple tables, updates may not work correctly.
alter Trigger tr_vWEmployeeDetails_InsteadOfUpdate
on vWEmployeeDetails
instead of update
as
Begin
 -- if EmployeeId is updated
 if(Update(Id))
 Begin
  Raiserror('Id cannot be changed', 16, 1)
  Return
 End
 
 -- If DeptName is updated
 if(Update(DeptName)) 
 Begin
  Declare @DeptId int

  Select @DeptId = DeptId
  from tblDepartment
  join inserted
  on inserted.DeptName = tblDepartment.DeptName
  
  if(@DeptId is NULL )
  Begin
   Raiserror('Invalid Department Name', 16, 1)
   Return
  End
  
  Update tblEmployee set DepartmentId = @DeptId
  from inserted
  join tblEmployee
  on tblEmployee.Id = inserted.id
 End
 
 -- If gender is updated
 if(Update(Gender))
 Begin
  Update tblEmployee set Gender = inserted.Gender
  from inserted
  join tblEmployee
  on tblEmployee.Id = inserted.id
 End
 
 -- If Name is updated
 if(Update(Name))
 Begin
  Update tblEmployee set Name = inserted.Name
  from inserted
  join tblEmployee
  on tblEmployee.Id = inserted.id
 End
End


--Instead of delete trigger - Part 47
use Sample4;

delete from vWEmployeeDetails where id = 1

create trigger tr_vWEmployeeDetails_InsteadOfDelete
on vWEmployeeDetails
instead of delete
as
begin
	delete tblEmployee
	from tblEmployee
	join deleted
	on tblEmployee.Id = deleted.id
end




