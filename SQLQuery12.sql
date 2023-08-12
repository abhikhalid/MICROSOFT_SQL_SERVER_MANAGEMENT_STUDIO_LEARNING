
-- write these following code in Transaction 2 window

Begin Tran
Update TableB Set Name = 'Mark Transaction 2' where Id = 1

-- From, Transaction 1 window execute the second update statment.

Update TableA Set Name = 'Mary Transaction 2' where Id = 1

Commit Transaction
