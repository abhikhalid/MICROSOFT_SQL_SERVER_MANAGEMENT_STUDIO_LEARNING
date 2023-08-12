-- Part 79 : SQL SERVER deadlock example

-- When can a deadlock occur
-- In a database, a deadlock occurs when two or more processes have a resource locked, and each process requests a lock on the resource that another process has already locked.
-- Neither of the transactions here can move forward, as each one is waiting for the other to release the lock. When deadlocks occur, SQL Server will choose one of processes as the deadlock
-- victim .

use Sample6;

Create table TableA
(
	Id int identity primary key,
	Name nvarchar(50)
)


Insert into TableA values ('Mark')

Create table TableB
(
	Id int identity primary key,
	Name nvarchar(50)
)

Insert into TableB values ('Mary')

-- Trasaction 1

Begin Tran
Update TableA Set Name = 'Mark Transaction 1' where Id = 1

-- From Transaction 2 window, execute the first udpate statement.
Update TableB Set Name = 'Mary Transaction 1' where Id = 1

--from transaction 2 window, execute the second update statement.
Commit Tran


-- write these following code in Transaction 2 window

Begin Tran
Update TableB Set Name = 'Mark Transaction 2' where Id = 1

-- From, Transaction 1 window execute the second update statment.

Update TableA Set Name = 'Mary Transaction 2' where Id = 1

-- after a few seconds, notice that one of the transactions complete successfully while the other transaction is made the deadlock victim

Commit Transaction


-- Part 80 : SQL Server Deadlock victim selection

-- How SQL Server detects deadlocks ?

-- Lock monitor thread in SQL Server, runs every 5 serconds by default to detect if there are any deadlocks. If the lock monitor thread finds deadlocks, the deadlokc detection interval
-- detection interval will drop from 5 seconds to as low as 100 miliseconds depending on the frequency of deadlocks. If the lock monitor thread stops finding deadlocks, the Database engine increases the interval between to 5 seconds.

-- What happens when a deadlock is deteceted? 

-- When a deadlock is detected, the database engine ends the deadlock by choosing one of threads as deadlock victim. The deadlock victim's transaction is then rolled back and returns a 1205 error to the application. Rolling back the transaction of the deadlock victim releases all locks held by that transaction.
-- This allows the other transactions to become unblocked and move forward.

-- What is DEADLOC_PRIORITY? 

-- By default, SQL Server chooses a transaction as the deadlock victim that is least expensive to roll back. However, a user can specify the priority of sessions in a deadlock situation using the 
-- SET DEADLOCK_PRIORITY statement. The session with the lowest deadlock priority as the deadlock victim.

-- Example : SET DEADLOCK__PRIORITY NORMAL

-- DEADLOCK_PRIORITY

-- LOW : -5
-- NORMAL : 0
-- HIGH : 5

-- What is the deadlock victim selection criteria?
-- i. if the DEADLOCK_PRIORITY is different, the session with the lowest priority is selected as the victim.
-- ii. if both the sessions have the same priority, the transaction that is least expensive to rollback is selected as the victim.
-- iii. if both the sessions have the same deadlock priority and the same cost, a victimis chosen randomly.

create database Sample7;
use Sample7;


Create Table TableA
(
 Id int identity primary key,
 Name nvarchar(50)
)

Insert into TableA values ('Mark')
insert into TableA values ('Ben')
Insert into TableA values ('Todd')
insert into TableA values ('Pam')
insert into TableA values ('Sara')

Create Table TableB
(
 Id int identity primary key,
 Name nvarchar(50)
)

Insert into TableB values ('Mary')

Select * from TableA;
Select * from TableB;

-- open 2 instances of sql server management studio. From the fist window, execute Transaction 1 code and from the second window execute Transaction 2 code. We have not explicitly DEADLOCK_PRIORITY, so both sessions have the default DEADLOCK_PRIORITY which is NORMAL.
-- So in this case SQL Server is going to choose Transaction 2 as the deadlock victim as it is the least expensive one to rollback.

-- Transaction 1
Begin Tran
Update TableA Set Name = Name + 'Transaction 1' where Id in (1,2,3,4,5)

-- From Transaction 2 window execute the first update statement.

Update TableB Set Name = Name + 'Transaction 1' where Id = 1

-- From Transaction 2 window, execute the second update statmenet.
Commit Transaction


-- Transaction 2

--Begin Tran
--Update TableB Set Name = Name + 'Transaction 2' Where Id = 1

----From Transction 1 window, execute the second update statment.

--Update TableA Set Name = Name + 'Transaction 2' Where Id in (1,2,3,4,5

---- After a few seconds notice that, this transaction will be chosen as the deadlock victim as it is less expensive to rollback this transaction than Transaction 1

--Commit Transaction


-- In the following example, we have set DEADLOCK_PRIORITY of Tranaction 2 to HIGH. Transaction 1 will be choosen as the deadlock victim, because it's DEADLOCK_PRIORITY (NORMAL)
-- is lower than the DEADLOCK_PRIORITY of Transacion 2.

-- Transaction 1

Begin Tran
Update TableA Set Name = Name + ' Transaction 1' Where Id IN (1,2,3,4,5)

--From Transaction 2 window, execute the first update statment.

Update TableB Set Name = Name + ' Transaction 1' Where Id = 1

-- From Transaction 2 window, execute the second update statement.

Commit Transaction

-- Transaction 2
SET DEADLOCK_PRIORITY HIGH

Begin Tran
Update TableB Set Name = Name + 'Transaction 2' Where Id = 1

-- From Transaction 1 window execute the second update statement

Update TableA Set Name = Name + ' Transaction 2' Where ID In (1,2,3,4,5)

-- after a few seconds notice that, Transaction 2 will be choosen as the deadlock victim as it's DEADLOCK_PRIORITY() is lower than the DEADLOCK_PRIORITY this transaction (HIGH)
Commit Transaction



