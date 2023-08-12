-- Part 81 - Logging deadlocks in sql server

-- here we will learn how to write the deadlock information to the SQL Server error log.

-- When deadlock occur, SQL Server chooses one of the transactions as the deadlock victim and rolls back. There are several ways in SQL server to track down  the queries that are causing deadlocks
-- One of the options is to use SQL Server trace flag 1222 to write the deadlock information to the SQL Server error log.

-- Enable Trace flag : to enable trace flags use DBCC command, -1 parameter indicates taht the trace flag must be set at teh global level. If you omit -1 parameter the trace flag will be set only at the session level.

DBCC Traceon(1222,-1)

-- To check the status of the trace flag
DBCC TraceStatus(1222,-1)  

-- To turn off the trace flag
DBCC Traceoff(1222,-1)


Create Table TableAA
(
 Id int identity primary key,
 Name nvarchar(50)
)

Insert into TableAA values ('Mark')
insert into TableAA values ('Ben')
Insert into TableAA values ('Todd')
insert into TableAA values ('Pam')
insert into TableAA values ('Sara')

Create Table TableBB
(
 Id int identity primary key,
 Name nvarchar(50)
)

Insert into TableBB values ('Mary')

-- SQL Script to create stored procedures

Create Proc spTransaction1
as 
Begin
	Begin Tran
		Update TableAA Set Name = 'Mark Transaction 1' where Id = 1
		Waitfor delay '00:00:05'

		Update TableBB Set Name = 'Mary Transaction 1' where Id = 1
	Commit Tran
End

Create Proc spTransaction2
as
Begin
   Begin Tran
	 Update TableBB Set Name = 'Mark Transaction 2' Where Id = 1
	 Waitfor delay '00:00:05'

	 Update TableAA Set Name = 'Mary Transaction 2 ' Where Id = 1
   Commit Tran
End

Exec spTransaction1

execute sp_readerrorlog

SELECT object_name([object_id])
FROM sys.partitions
WHERE hobt_id = 72057594045923328




-- Part 84 : SQL Server deadlock error handling

Alter Proc spTransaction1
as 
Begin
	Begin Tran
		Begin Try
			Update TableAA Set Name = 'Mark Transaction 1' where Id = 1
		    Waitfor delay '00:00:05'
		 	Update TableBB Set Name = 'Mary Transaction 1' where Id = 1
			--If both the update statements succeeded.
			--No Deadlock occured. So commit the transaction.
		    Commit Tran
			Select 'Transaction Successful'
		End Try
		Begin Catch
			-- Check if the error is deadlock error
			if(ERROR_NUMBER() = 1205)
			BEGIN
				Select 'Deadlock. Transction failed. Please retry'
			END
			--Rollback the transaction
			Rollback
		End Catch
End

-- open window 2

Alter Proc spTransaction2
as
Begin
   Begin Tran
	Begin Try
		 Update TableBB Set Name = 'Mark Transaction 2' Where Id = 1
		 Waitfor delay '00:00:05'

		 Update TableAA Set Name = 'Mary Transaction 2 ' Where Id = 1
	     Commit Tran
		 Select 'Transaction Successful'
	End Try
	Begin Catch
		if(ERROR_NUMBER() = 1205)
		 Begin
			Select 'Deadlock. Transaction failed. Please retry'
		 End
		 Rollback
	End Catch
End

