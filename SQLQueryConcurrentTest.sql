-- Dirty Read Transaction 2

Set Transaction Isolation Level Read Uncommitted

use Sample6;
begin tran
Select * from tblInventory where Id = 1
commit tran


-- Lost Update Transaction 2

Begin Tran
Declare @ItemsInStock int

Select @ItemsInStock = ItemsInStock
From tblInventory where Id = 1

-- Transaction takes 1 second
Waitfor delay '00:00:1'

Set @ItemsInStock = @ItemsInStock - 2

Update tblInventory
Set ItemsInStock = @ItemsInStock where Id = 1

Print @ItemsInStock

Commit Transaction


--Non Repeatable Read
use Sample6;
Update tblInventory set ItemsInStock = 5
where Id = 1


--When you execute Transaction 1 and 2 from 2 different instances of SQL Server management studio, Transaction 2 is blocked until Transaction 1 completes and at the end of Transaction 1, both the reads get the same value for ItemsInStock.

-- Transaction 1
Set transaction isolation level repeatable read
Begin Transaction
Select ItemsInStock from tblInventory where Id = 1

-- Do Some work
waitfor delay '00:00:10'

Select ItemsInStock from tblInventory where Id = 1
Commit Transaction

-- Transaction 2
Update tblInventory set ItemsInStock = 5 where Id = 1





