/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID, StockItemName
FROM [Warehouse].[StockItems]
WHERE StockItemName like N'%urgent%'
OR StockItemName like N'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT
s.SupplierID, s.SupplierName
--, o.*
FROM [Purchasing].[Suppliers] AS s
LEFT JOIN [Purchasing].[PurchaseOrders] AS o ON o.SupplierID = s.SupplierID 
WHERE o.SupplierID is NULL
ORDER BY 1

--Select * FROM [Purchasing].[PurchaseOrders] where SupplierID = 4

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT 
	  FORMAT(o.OrderDate, 'dd.MM.yyyy','ru-ru') AS OrderDate
	, DATENAME(MONTH,o.OrderDate) AS Month
	, DATENAME(QUARTER,o.OrderDate) AS Quarter
	, CASE 
		WHEN MONTH(o.OrderDate) >= 1 AND MONTH(o.OrderDate) <= 4 THEN 1
		WHEN MONTH(o.OrderDate) >= 5 AND MONTH(o.OrderDate) <= 8 THEN 2
		WHEN MONTH(o.OrderDate) >= 9 AND MONTH(o.OrderDate) <= 12 THEN 3
	END 
		AS Triad
	, c.[CustomerName]
	, ol.UnitPrice
	, ol.Quantity
FROM [Sales].[Orders] AS o
INNER JOIN [Sales].[OrderLines] AS ol ON o.OrderID = ol.OrderID AND (ol.UnitPrice > 100 OR ol.Quantity > 10)
INNER JOIN [Sales].[Customers] AS c	  ON o.CustomerID = c.CustomerID
ORDER BY Quarter, Triad,  o.OrderDate
offset 1000 rows    
    fetch next 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT	d.[DeliveryMethodName]
		--, s.SupplierID
		, o.[ExpectedDeliveryDate]
		, s.SupplierName
		--, o.[IsOrderFinalized]--
 		--, s.[SupplierName]
		, p.[FullName]
		--, p.IsEmployee
		--, s.*
		
FROM [Purchasing].[Suppliers] AS s
INNER JOIN [Purchasing].[PurchaseOrders] AS o ON o.SupplierID = s.SupplierCategoryID AND o.ExpectedDeliveryDate like '2013-01%' AND o.IsOrderFinalized = 1
INNER JOIN [Application].[DeliveryMethods] AS d ON d.DeliveryMethodID = s.DeliveryMethodID AND (d.DeliveryMethodName = 'Air Freight' OR d.DeliveryMethodName = 'Refrigerated Air Freight')
INNER JOIN [Application].[People] AS p ON p.PersonID = o.ContactPersonID 



/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT top 10 --with ties
	o.OrderDate
	, c.CustomerName
	, p.FullName
	--, p.IsEmployee
FROM [Sales].[Orders] AS o
INNER JOIN [Sales].[Customers] AS c ON c.CustomerID = o.CustomerID
INNER JOIN [Application].[People] AS p ON p.PersonID = o.SalespersonPersonID
ORDER BY o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT 
	c.CustomerID
	, c.CustomerName
	, c.PhoneNumber
	--ol.*
FROM [Sales].[Orders] o 
INNER JOIN [Sales].[OrderLines] ol ON ol.OrderID = o.OrderID
INNER JOIN [Warehouse].[StockItems] si ON si.StockItemID = ol.StockItemID AND si.StockItemName = 'Chocolate frogs 250g'
INNER JOIN [Sales].[Customers] AS c ON c.CustomerID = o.CustomerID

