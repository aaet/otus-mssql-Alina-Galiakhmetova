/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
--Select SUM(UnitPrice*Quantity)
--FROM 
--		[Sales].[InvoiceLines] IL 
--		INNER JOIN [Sales].[Invoices] I ON I.[InvoiceID] = IL.[InvoiceID] and  i.InvoiceDate Like '2015-01%'
SET STATISTICS TIME ON;
select 
	idпродажи		= IL.[InvoiceID],
	названиеклиента = c.[CustomerName],
	датупродажи		= I.[InvoiceDate],
	MonthOfIvoice   = Month(i.[InvoiceDate]),
	суммaпродажи	= UnitPrice*Quantity,
	сумманарастающимитогом	= (select		  sum(UnitPrice*Quantity) 
								from  [Sales].[InvoiceLines] IL2
								inner join [Sales].[Invoices] I2 ON I2.InvoiceID = IL2.InvoiceID and  i2.InvoiceDate BETWEEN '2015-01-01' AND '2015-12-31'
								where MONTH(i.InvoiceDate) = MONTH(i2.InvoiceDate)
								)--IL.InvoiceID=IL2.InvoiceID 
from 
		[Sales].[InvoiceLines] IL 
		INNER JOIN [Sales].[Invoices] I ON I.[InvoiceID] = IL.[InvoiceID] and  i.InvoiceDate BETWEEN '2015-01-01' AND '2015-12-31'
		INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID
order by 
1,3,4
SET STATISTICS TIME OFF;

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
SET STATISTICS TIME ON;
select 
	idпродажи		= IL.[InvoiceID],
	названиеклиента = c.[CustomerName],
	датупродажи		= I.[InvoiceDate],
	MonthOfIvoice   = Month(i.[InvoiceDate]),
	суммaпродажи	= UnitPrice*Quantity,
	сумманарастающимитогом	= SUM(UnitPrice*Quantity) OVER(PARTITION BY Month(i.[InvoiceDate]))
from 
		[Sales].[InvoiceLines] IL 
		INNER JOIN [Sales].[Invoices] I ON I.[InvoiceID] = IL.[InvoiceID] and  i.InvoiceDate BETWEEN '2015-01-01' AND '2015-12-31'
		INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID
order by 
1,3,4
SET STATISTICS TIME OFF;

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
Drop table #t
Create table #t (
	monthI int,
	StockItemID int,
	StockItemName nvarchar(255),
	kol int,
	Position int)
;WITH cte AS (
SELECT 
	MONTH(i.[InvoiceDate]) monthI,
	si.StockItemID,
	si.StockItemName,
	--il.Quantity,
	SUM(il.Quantity) kol --OVER(PARTITION BY MONTH(i.[InvoiceDate]) ORDER BY il.Quantity desc) kol
FROM [Sales].[Invoices] i
INNER JOIN [Sales].[InvoiceLines] il ON il.InvoiceID = i.InvoiceID AND i.InvoiceDate BETWEEN '2016-01-01' AND '2016-12-31'
INNER JOIN [Warehouse].[StockItems] si ON si.StockItemID = il.StockItemID
GROUP BY MONTH(i.[InvoiceDate]),
	si.StockItemID,
	si.StockItemName
--ORDER BY MONTH(i.[InvoiceDate]), SUM(il.Quantity) desc
)
INSERT INTO #t 
Select *,
	(rank() OVER(partition by monthI order by kol desc)) Position
FROM cte
--ORDER BY monthI, kol desc
Select * 
From #t
where Position in (1,2)
ORDER BY monthI, kol desc

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

Select 
	[StockItemID],
	[StockItemName],
	[Brand],
	[UnitPrice],
	row_number() over (partition by LEFT([StockItemName],1) order by LEFT([StockItemName],1)),
	count(*) OVER (),
	count([StockItemID]) over (partition by LEFT([StockItemName],1)),
	Следующая     = last_value ([StockItemID]) over  (order by LEFT([StockItemName],1) rows between 1 following and 1 following),
	Предыдущая    = first_value([StockItemID]) over  (order by LEFT([StockItemName],1) rows between 1 preceding and 1 preceding),
	[названия товара 2 строки назад]    = ISNULL(first_value([StockItemName]) over  (order by LEFT([StockItemName],1) rows between 2 preceding and 2 preceding),'No items'),
	ntile(30) over (partition by [TypicalWeightPerUnit] order by [TypicalWeightPerUnit]) WeightGroup

FROM [Warehouse].[StockItems]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
;WITH cte as (SELECT 
	p.PersonID,
	p.FullName,
	c.CustomerID,
	c.CustomerName,
	i.InvoiceDate,
	il.UnitPrice*il.Quantity as summa,
	ROW_NUMBER() over (partition by p.PersonID order by i.InvoiceDate desc) as PositionNumber
FROM [Sales].[Invoices] i
INNER JOIN [Application].[People] p ON p.PersonID = i.SalespersonPersonID
INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID 
INNER JOIN [Sales].[InvoiceLines] il ON il.InvoiceID = i.InvoiceID)
Select PersonID,
	FullName,
	CustomerID,
	CustomerName,
	InvoiceDate,
	summa
	--PositionNumber
FROM cte 
WHERE PositionNumber = 1


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;WITH cte as (SELECT 
	c.CustomerID,
	c.CustomerName,
	il.StockItemID,
	il.UnitPrice,
	i.InvoiceDate,
	dense_rank() over (partition by c.CustomerID order by il.UnitPrice desc) as PositionNumber
FROM [Sales].[Customers] c
INNER JOIN [Sales].[Invoices] i ON i.CustomerID = c.CustomerID
INNER JOIN [Sales].[InvoiceLines] il ON il.InvoiceID = i.InvoiceID
--ORDER BY c.CustomerID, il.UnitPrice desc
)
Select CustomerID,
	CustomerName,
	StockItemID,
	UnitPrice,
	InvoiceDate,
	PositionNumber
FROM cte
WHERE PositionNumber in (1,2)



--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 