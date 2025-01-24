/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
﻿USE WideWorldImporters;
IF OBJECT_ID (N'dbo.fGetCustomerOfMaxTotalSum', N'FN') IS NOT NULL
DROP FUNCTION dbo.fGetCustomerOfMaxTotalSum;

CREATE FUNCTION dbo.fGetCustomerOfMaxTotalSum()
RETURNS TABLE
AS
RETURN
    (
	Select DISTINCT CustomerID
	FROM [Sales].[OrderLines] ol
	INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID
	WHERE UnitPrice*Quantity = (Select max(UnitPrice*Quantity) FROM [Sales].[OrderLines]))

Select * from dbo.fGetCustomerOfMaxTotalSum()

--USE WideWorldImporters
--Select DISTINCT CustomerID
--FROM [Sales].[OrderLines] ol
--INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID
--WHERE UnitPrice*Quantity = (Select max(UnitPrice*Quantity) FROM [Sales].[OrderLines])
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
IF OBJECT_ID (N'dbo.TotalSumOfCustomerID', N'P') IS NOT NULL
DROP procedure dbo.TotalSumOfCustomerID;


CREATE procedure  dbo.TotalSumOfCustomerID 
(@CustomerId int)
AS
BEGIN

	Select UnitPrice*Quantity
	FROM [Sales].[OrderLines] ol
	INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID
	WHERE o.CustomerID = @CustomerId

END

EXEC TotalSumOfCustomerID 925

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
IF OBJECT_ID (N'dbo.AvgTotalSumOfOrder', N'FN') IS NOT NULL
DROP FUNCTION dbo.AvgTotalSumOfOrder

CREATE FUNCTION dbo.AvgTotalSumOfOrder (@CustomerId INT)
RETURNS DECIMAL (18,6)
AS
BEGIN
	DECLARE @Result DECIMAL (18,6);
	SELECT @Result = 
		(	Select AVG(UnitPrice*Quantity)
			FROM [Sales].[OrderLines] ol
			INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID and o.CustomerID = @CustomerId)
	RETURN @Result;
END;

IF OBJECT_ID (N'dbo.AvgTotalSumOfOrderSP', N'P') IS NOT NULL
DROP procedure dbo.AvgTotalSumOfOrderSP

CREATE procedure dbo.AvgTotalSumOfOrderSP (@CustomerId int)
AS
BEGIN
	Select AVG(UnitPrice*Quantity)
	FROM [Sales].[OrderLines] ol
	INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID and o.CustomerID = @CustomerId
END

Select dbo.AvgTotalSumOfOrder(103)
EXEC dbo.AvgTotalSumOfOrderSP 103

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
--Список товаров для клиентов
IF OBJECT_ID (N'dbo.TotalCustomerListOfCategory', N'FN') IS NOT NULL
DROP FUNCTION dbo.TotalCustomerListOfCategory

CREATE FUNCTION dbo.TotalCustomerListOfCategory (@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
	Select DISTINCT [StockItemName]
	FROM [Sales].[OrderLines] ol
	INNER JOIN [Sales].[Orders] o ON o.OrderID = ol.OrderID 
	INNER JOIN [Warehouse].[StockItems] si ON si.StockItemID = ol.StockItemID
	WHERE [CustomerID] = @CustomerID
);

Select c.CustomerID,c.[CustomerName],f.StockItemName
FROM [Sales].[Customers] c
CROSS APPLY dbo.TotalCustomerListOfCategory(c.CustomerID) f
ORDER BY c.CustomerID


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
