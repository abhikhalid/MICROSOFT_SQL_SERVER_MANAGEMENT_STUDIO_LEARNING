CREATE DATABASE Sample6;

use Sample 6

-- Creating tblInventory Table

Create Table tblInventory
(
 Id int identity primary key,
 Name nvarchar(40),
 ItemsInStock int
)

Insert into tblInventory values ('Iphone',10);

Select * from tblInventory


-- Part 76 - Snapshot Isolation Level in Sql Server

-- Transaction 1

Set transaction isolation level serializable

Begin Transaction

Update tblInventory set ItemsInStock = 5 where Id = 1
waitfor delay '00:00:10'

Commit Transaction

-- Transaction 2

--use Sample6;

--Set transaction isolation level serializable

--Select ItemsInStock from tblInventory where Id = 1

--#############################################################################################

---- Now change the isolation level of Transaction 2 to snapshot. To set snapshot isolation level, it must first be enabled at the database level. and then set the transaction 
-- isolation levle to snapshot.

-- Transaction 2
-- Enable snapshot isolation level for the database
Alter database Sample6 SET ALLOW_SNAPSHOT_ISOLATION ON

-- set the transaction isolation level to snapshot
set transaction isolation level snapshot
Select ItemsInStock from tblInventory where Id = 1


--Modifying data with snapshot isolation level 

-- Transaction 2

-- Enable snapshot isolation for the database
Alter database Sample6 SET ALLOW_SNAPSHOT_ISOLATION ON 

-- set the transaction isolation  level to snapshot
set transaction isolation level snapshot
update tblInventory set ItemsInStock = 8 where Id = 1


-- Part 78 : Read committed snapshot isolation level

-- Read committed snapshot isolation level is not a different isolation level. It is a different way of implementing read committed isolation level. One problem we have with read committed
-- isolation level is that, it block the transaction from reading the data that another transaction is updating at the same time.

-- Transaction 1

Set Transaction Isolation level Read Committed
Begin Transaction 
Update tblInventory set ItemsInStock = 5 where Id = 1
waitfor delay  '00:00:10'
commit transaction

---- Transaction 2
--set transaction isolation level read committed
--begin transaction 
--select ItemsInStock from tblInventory where Id = 1
--commit transaction

Alter database Sample6 SET READ_COMMITTED_SNAPSHOT ON

set transaction isolation level read committed
begin transaction 
select ItemsInStock from tblInventory where Id = 1
commit transaction





--So what is the point in using read committed snapshot isolation level over snapshot isolation level?


-- Part 78 : Difference between Snapshot Isoaltion and Read Committed Snapshot
-- transaction 1

set transaction isolation level snapshot
begin transaction
update tblInventory set ItemsInStock = 8 where Id = 1
waitfor delay '00:00:10'
commit transaction


-- transaction 2
--set transaction isolation level snapshot
--begin transaction
--update tblInventory set ItemsInStock = 5 where Id = 1
--commit transaction












