-- Transaction 2

use Sample6;

Set transaction isolation level serializable

Select ItemsInStock from tblInventory where Id = 1

---- Now change the isolation level of Transaction 2 to snapshot. To set snapshot isolation level, it must first be enabled at the database level. and then set the transaction 
-- isolation levle to snapshot.

-- Transaction 2
-- Enable snapshot isolation level for the database
Alter database Sample6 SET ALLOW_SNAPSHOT_ISOLATION ON

-- set the transaction isolation level to snapshot
set transaction isolation level snapshot
Select ItemsInStock from tblInventory where Id = 1

-------------------------------------------------------------------------------

Alter database Sample6 SET ALLOW_SNAPSHOT_ISOLATION OFF

-- set the transaction isolation  level to snapshot
set transaction isolation level snapshot
update tblInventory set ItemsInStock = 8 where Id = 1


-------------------------------------------------------------

-- Part 78 : Read Committed Snapshot Isolation level ( Transaction 2)

-- Transaction 2
set transaction isolation level read committed
begin transaction 
select ItemsInStock from tblInventory where Id = 1
commit transaction

---------------------------------------


Alter database Sample6 SET READ_COMMITTED_SNAPSHOT ON

set transaction isolation level read committed
begin transaction 
select ItemsInStock from tblInventory where Id = 1
commit transaction


--------------------------------------------

-- Part 78 - Transaction 2

set transaction isolation level snapshot
begin transaction
update tblInventory set ItemsInStock = 5 where Id = 1
commit transaction

