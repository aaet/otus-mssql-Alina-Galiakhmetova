/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


Declare @cnt int = 1

while @cnt < 6 
Begin
INSERT INTO [Sales].[Customers]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     VALUES
           (NEXT VALUE FOR Sequences.CustomerID
           ,'NewCustomer1' + CAST(@cnt as nvarchar)
           ,1
           ,3
           ,1
           ,1001
           ,1002
           ,3
           ,19586
           ,19586
           ,NULL
           ,'2013-01-01'
           ,0.000
           ,0
           ,0
           ,7
           ,'(308) 555-0100'
           ,'(308) 555-0101'
           ,' '
           ,' '
           ,'http://www.tailspintoys.com'
           ,'Shop 38'
           ,'1877 Mittal Road'
           ,'90410'
           ,NULL
           ,'PO Box 8975'
           ,'Ribeiroville'
           ,'90410'
           ,1)
Set @cnt += 1
--Select @cnt
END


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

Delete from [Sales].[Customers]
where CustomerName like 'NewCustomer11'

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Sales].[Customers]
SET [CustomerName] = 'NewCustomer12_updated'
where [CustomerName] = 'NewCustomer12'

/*
4. Написать MERGE, который вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
--create copy table
--SELECT * INTO  Sales.Customers_copy
--FROM [Sales].[Customers]
--Delete from Sales.Customers_copy

--Select * from [Sales].[Customers_copy]

--Update copy table
--UPDATE Sales.Customers_copy
--SET [CustomerName] = 'NewCustomer13_updated' 
--where [CustomerName] = 'NewCustomer13'

--insert to copy table
--INSERT INTO [Sales].[Customers]
--           ([CustomerID]
--           ,[CustomerName]
--           ,[BillToCustomerID]
--           ,[CustomerCategoryID]
--           ,[BuyingGroupID]
--           ,[PrimaryContactPersonID]
--           ,[AlternateContactPersonID]
--           ,[DeliveryMethodID]
--           ,[DeliveryCityID]
--           ,[PostalCityID]
--           ,[CreditLimit]
--           ,[AccountOpenedDate]
--           ,[StandardDiscountPercentage]
--           ,[IsStatementSent]
--           ,[IsOnCreditHold]
--           ,[PaymentDays]
--           ,[PhoneNumber]
--           ,[FaxNumber]
--           ,[DeliveryRun]
--           ,[RunPosition]
--           ,[WebsiteURL]
--           ,[DeliveryAddressLine1]
--           ,[DeliveryAddressLine2]
--           ,[DeliveryPostalCode]
--           ,[DeliveryLocation]
--           ,[PostalAddressLine1]
--           ,[PostalAddressLine2]
--           ,[PostalPostalCode]
--           ,[LastEditedBy])
--     VALUES
--           (NEXT VALUE FOR Sequences.CustomerID
--           ,'NewCustomer100'
--           ,1
--           ,3
--           ,1
--           ,1001
--           ,1002
--           ,3
--           ,19586
--           ,19586
--           ,NULL
--           ,'2013-01-01'
--           ,0.000
--           ,0
--           ,0
--           ,7
--           ,'(308) 555-0100'
--           ,'(308) 555-0101'
--           ,' '
--           ,' '
--           ,'http://www.tailspintoys.com'
--           ,'Shop 38'
--           ,'1877 Mittal Road'
--           ,'90410'
--           ,NULL
--           ,'PO Box 8975'
--           ,'Ribeiroville'
--           ,'90410'
--           ,1)
--Check data tables
--Select * FROM [Sales].[Customers]
--where CustomerName like 'NewCustomer%'

--Select * FROM [Sales].[Customers_copy]
--where CustomerName like 'NewCustomer%'

--MERGE
MERGE [Sales].[Customers_copy] t USING [Sales].[Customers] s
ON t.CustomerID = s.CustomerID
WHEN MATCHED
THEN UPDATE
	SET t.CustomerName = s.CustomerName
WHEN NOT MATCHED
THEN INSERT
	VALUES(s.[CustomerID]
           ,s.[CustomerName]
           ,s.[BillToCustomerID]
           ,s.[CustomerCategoryID]
           ,s.[BuyingGroupID]
           ,s.[PrimaryContactPersonID]
           ,s.[AlternateContactPersonID]
           ,s.[DeliveryMethodID]
           ,s.[DeliveryCityID]
           ,s.[PostalCityID]
           ,s.[CreditLimit]
           ,s.[AccountOpenedDate]
           ,s.[StandardDiscountPercentage]
           ,s.[IsStatementSent]
           ,s.[IsOnCreditHold]
           ,s.[PaymentDays]
           ,s.[PhoneNumber]
           ,s.[FaxNumber]
           ,s.[DeliveryRun]
           ,s.[RunPosition]
           ,s.[WebsiteURL]
           ,s.[DeliveryAddressLine1]
           ,s.[DeliveryAddressLine2]
           ,s.[DeliveryPostalCode]
           ,s.[DeliveryLocation]
           ,s.[PostalAddressLine1]
           ,s.[PostalAddressLine2]
           ,s.[PostalPostalCode]
           ,s.[LastEditedBy]
		   ,s.[ValidFrom]
		   ,s.[ValidTo])
WHEN NOT MATCHED BY SOURCE
THEN DELETE
OUTPUT deleted.*, $action, inserted.*;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

DECLARE @sql VARCHAR(8000);

Select @sql = 'bcp "select top 10 CustomerID, CustomerName FROM [WideWorldImporters].[Sales].[Customers] " queryout "C:\Test\Test.txt" -c -t, -T  -S ' + @@Servername;

EXEC master..xp_cmdshell @sql;


DROP TABLE if exists Sales.Customers_INFO;
SELECT CustomerID, CustomerName INTO  Sales.Customers_INFO
FROM [Sales].[Customers]
WHERE 1=2

Select * FROM Sales.Customers_INFO

BULK INSERT [WideWorldImporters].[Sales].[Customers_INFO]
    FROM "C:\Test\Test.txt"
	WITH 
		(
		BATCHSIZE = 100,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = ',',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK
		);

--USE master;
--GO

--EXECUTE sp_configure 'show advanced options', 1;
--GO

--RECONFIGURE;
--GO

--EXECUTE sp_configure 'xp_cmdshell', 1;
--GO

--RECONFIGURE;
--GO

--EXECUTE sp_configure 'show advanced options', 0;
--GO

--RECONFIGURE;
--GO