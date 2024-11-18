/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
-- 1
SELECT 
	PersonID
	, FullName
FROM [Application].[People]
WHERE IsSalesperson = 1
AND  PersonID IN 
			(SELECT DISTINCT SalespersonPersonID FROM [Sales].[Invoices] WHERE InvoiceDate <> '2015-07-04')
ORDER BY PersonID
-- 2
; WITH cte (PersonID) AS (
	SELECT DISTINCT SalespersonPersonID FROM [Sales].[Invoices] WHERE InvoiceDate <> '2015-07-04'
)
SELECT 
	p.PersonID
	, p. FullName
	--, cte.PersonID
FROM [Application].[People] AS p
INNER JOIN cte ON p.PersonID = cte.PersonID
WHERE p.IsSalesperson = 1
ORDER BY p.PersonID

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 
--1
SELECT [StockItemID]  AS [ИД товара], [StockItemName] AS [наименование товара], [UnitPrice] AS [цена]
FROM [Warehouse].[StockItems]
WHERE [UnitPrice] = (SELECT MIN(UnitPrice) FROM [Warehouse].[StockItems])

--2
; WITH cte (UnitPrice) AS (SELECT MIN(UnitPrice) FROM [Warehouse].[StockItems])
SELECT [StockItemID]  AS [ИД товара], [StockItemName] AS [наименование товара], [UnitPrice] AS [цена]
FROM [Warehouse].[StockItems]
WHERE [UnitPrice] IN (SELECT * FROM cte)


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO: 
--1
SELECT TOP 5 
	c.CustomerID
	, c.CustomerName
	, ct.TransactionAmount
FROM [Sales].[CustomerTransactions] AS ct
INNER JOIN [Sales].[Customers] AS c ON c.CustomerID = ct.CustomerID
ORDER BY [TransactionAmount] desc

--2
;WITH cte(CustomerID,TransactionAmount) AS (SELECT TOP 5 CustomerID,TransactionAmount FROM [Sales].[CustomerTransactions] ORDER BY TransactionAmount desc)
SELECT 
	c.CustomerID
	, c.CustomerName
	, cte.TransactionAmount
FROM [Sales].[Customers] AS c
INNER JOIN cte ON cte.CustomerID = c.CustomerID


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 

;WITH cte(UnitPrice,StockItemName,StockItemID) AS (SELECT TOP 3 WITH ties UnitPrice,StockItemName,StockItemID FROM [WideWorldImporters].[Warehouse].[StockItems] ORDER BY UnitPrice desc)

SELECT --il.[StockItemID]
      --,cte.[StockItemName]
      --,cte.[UnitPrice]
	  --,il.InvoiceID
	   city.CityID
	  ,city.CityName
	  --,i.PackedByPersonID
	  ,p.FullName
  FROM cte
 INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il ON il.StockItemID = cte.StockItemID
 INNER JOIN [Sales].[Invoices] i ON il.InvoiceID = i.InvoiceID
 INNER JOIN [Application].[People] p ON p.PersonID = i.PackedByPersonID
 INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID
 INNER JOIN [Application].[Cities] city ON city.CityID = c.DeliveryCityID
 ORDER BY city.CityName

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
