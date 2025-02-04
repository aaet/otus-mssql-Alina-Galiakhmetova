--Включаем CLR
exec sp_configure 'show advanced options', 1;
GO
reconfigure;
GO

exec sp_configure 'clr_enabled', 1;
exec sp_configure 'clr_strict_security', 0
GO
reconfigure;
GO

--Для возмодности создания сборок
ALTER DATABASE TO SET TRUSTWORTHY ON;

--Подключаем dll
 
 --DROP ASSEMBLY CLRFunction

CREATE ASSEMBLY CLRFunctions
FROM 'C:\SQLServerCLRSortString.dll'
WITH PERMISSION_SET = SAFE;

--Посмотреть assemblies
SELECT * FROM sys.assemblies


--Создаем функцию
CREATE FUNCTION dbo.SortString(@name AS NVARCHAR(255))     
RETURNS NVARCHAR(255)    
AS EXTERNAL NAME CLRFunctions.CLRFunctions.SortString 
GO 

--Create test table
CREATE TABLE testSort (data VARCHAR(255)) 
GO
INSERT INTO testSort VALUES('apple,pear,orange,banana,grape,kiwi') 
INSERT INTO testSort VALUES('pineapple,grape,banana,apple') 
INSERT INTO testSort VALUES('apricot,pear,strawberry,banana') 
INSERT INTO testSort VALUES('cherry,watermelon,orange,melon,grape') 

--Test new function
SELECT data, dbo.sortString(data) as sorted FROM testSort 
