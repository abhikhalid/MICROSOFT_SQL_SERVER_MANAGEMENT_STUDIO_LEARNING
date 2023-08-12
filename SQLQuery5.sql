--Part 72 - sql server dirty read example

-- A dirty read happens when one transaction is permitted to read data that has been modified by
-- another transaction that has not yet been committed. In most cases this would not cause a problem. However, if the first transaction is rolled
-- back after the second reads the data, the second transaction has dirty data that does not exist anymore.

use Sample6;

Create table tblInventory
(
 Id int identity primary key,
 Product nvarchar(100),
 ItemsInStock int
)
Go

Insert into tblInventory values('IPhone',10)

-- Transaction 1

Begin Tran

Update tblInventory set ItemsInStock = 9 Where Id = 1

-- Billing Customer
Waitfor Delay '00:00:15'
-- Insufficient Funds. Rollback transaction

Rollback Transaction

--Create seperate query window to write the following line
Set Transaction Isolation Level Read Uncommitted

Select * from tblInventory where Id = 1

-- Read Uncommitted transaction isolation level is the only isolation level that has dirty read side effect.
-- This is the least restrictive of all isolation levels.


-- Part 73 - sql server lost update problem

--Lost update problem happens when 2 transactions read and update the same data

-- Transaction 1
use Sample6;

Begin Tran
Declare @ItemsInStock int

Select @ItemsInStock = ItemsInStock
from tblInventory where id = 1

-- Transaction takes 10 seconds

waitfor delay '00:00:20'

set @ItemsInStock = @ItemsInStock - 1

update tblInventory
set ItemsInStock = @ItemsInStock where Id = 1

Print @ItemsInStock

Commit transaction

--open another window for another transaction
--Transaction 2


--Part 74 : Non repeatable read example in sql server

-- Non repeatable read happens when one transaction reads the same data twice and another transaction updates that data in between the first and second read of transaction one.

-- Transaction 1
Begin Transaction
Select ItemsInStock from tblInventory where Id = 1

-- Do Some Work
waitfor delay '00:00:10'

Select ItemsInStock from tblInventory where Id = 1
Commit Transaction 


-- Part 75 : Phantom reads example in sql server

-- Phantom read happens when one transaction executes a query twice and it gets a different number of rows in the result set each time.
-- This happens when second transaction inserts a new row that matches the WHERE clause of the query executed by the first transaction.

use Sample6;

Create table tblEmployees
(
 Id int primary key,
 Name nvarchar(50)
)

Go

Insert into tblEmployees values(1,'Mark')
Insert into tblEmployees values(3, 'Sara')
Insert into tblEmployees values(100, 'Mary')

-- Transaction 1
Begin Transaction 
Select * from tblEmployees where Id between 1 and 3

-- Do Some Work
waitfor delay '00:00:10'

select * from tblEmployees where Id between 1 and 3

Commit Transaction

-- Transaction 2

Insert into tblEmployees values (2,'Marcus')

--Fixing phantom read concurrency problem

-- to fix the phantom read problem, set transaction isolation level of transaction 1 to serializable.
-- this will place a range lock on the rows between 1 and 3, which prevents any other transaction from
-- inserting new rows in that range. This solves the phantom read problem.
-- Transaction 1
Set transaction isolation level serializable
Begin Transaction
Select * from tblEmployees where Id between 1 and 3
-- Do Some work
waitfor delay '00:00:10'
Select * from tblEmployees where Id between 1 and 3
Commit Transaction

-- Transaction 2

Insert into tblEmployees values(2, 'Marcus')

--Difference between repeatable read and serializable
--Repeatable read prevents only non-repeatable read. Repeatable read isolation level ensures that the data that one transaction has read, will be prevented from being updated or deleted by any other transaction, but it doe not prevent new rows from being inserted by other transactions resulting in phantom read concurrency problem.

--Serializable prevents both non-repeatable read and phantom read problems. Serializable isolation level ensures that the data that one transaction has read, will be prevented from being updated or deleted by any other transaction. It also prevents new rows from being inserted by other transactions, so this isolation level prevents both non-repeatable read and phantom read problems.























