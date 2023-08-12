--Alter Database Sample1 Modify Name =  Sample

--sp_renameDB 'Sample1','Sample'

--Drop database Sample1 (it will drop corresponding ldf and mdf files)

-- Use [Sample]
-- Go
--CREATE TABLE tbGender
--(
--	ID int NOT NULL Primary Key,
--	Gender nvarchar(50) NOT NULL
--)


-- Add foreign key constraint to a foreign table

--Alter table tblPerson add constraint tblPerson_GenderID_FK
--FOREIGN KEY (GenderId) references tblGender (ID)

Select * from tbl_Gender
Select * from tbl_Personn

INSERT INTO tblPerson (ID, Name, Email) Values (9,'Israr','r@r.com')

-- adding a default constraint - Part 4

ALTER TABLE tblPerson
ADD CONSTRAINT DF_tblPerson_GenderId
DEFAULT 3 FOR GENDERID

-- dropping a constraint
ALTER TABLE tblPerson
DROP CONSTRAINT DF_tblPerson_GenderId 