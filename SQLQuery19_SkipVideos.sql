-- Part 26 : IsDate, Day, Month, Year and DateName functions in SQL Server 

-- ISDATE() - Checks if the given value, is a valid date, tiem or datetime. Returns 1 for success, 0 for failure

SELECT ISDATE('Khalid')
SELECT ISDATE(GetDate())
SELECT ISDATE('2022-08-31 21:02:04.167')
Select ISDATE('2012-09-01 11:34:21.1918447')


-- DAY() - RETURNS the 'Day number of the Month' of the given value

SELECT DAY(GETDATE())
SELECT DAY('01/31/2012') 

-- MONTH() - Returns the 'Month number of the year' of the given value

Select MONTH(GETDATE())

SELECT MONTH('01/31/2022')

-- YEAR() - Returns the 'Year Number' of the given value

SELECT YEAR(GETDATE())
SELECT YEAR('01/31/2012')


--DateName(DatePart, Date) - Returns a string, that represents a part of the given date. This functions takes 2 parameters.
--The first parameter 'DatePart' specifies, the part of the date, we want. The second parameter, is the actual date, from which we want the part of the Date.


--Examples:
Select DATENAME(Day, '2012-09-30 12:43:46.837') -- Returns 30
Select DATENAME(WEEKDAY, '2012-09-30 12:43:46.837') -- Returns Sunday

Select DATENAME(MONTH, '2012-09-30 12:43:46.837') -- Returns September

Select Name, DateOfBirth, DateName(WEEKDAY,DateOfBirth) as [Day], 
            Month(DateOfBirth) as MonthNumber, 
            DateName(MONTH, DateOfBirth) as [MonthName],
            Year(DateOfBirth) as [Year]
From   tblEmployees