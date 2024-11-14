/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT --*
	YEAR(i.InvoiceDate) AS [Год продажи]
	, MONTH(i.InvoiceDate) AS [Месяц продажи]
	, AVG(il.UnitPrice) AS [Средняя цена за месяц по всем товарам]
	, SUM(il.UnitPrice*il.Quantity) AS [Общая сумма продаж за месяц]
FROM [Sales].[Invoices] AS i
INNER JOIN [Sales].[InvoiceLines] AS il ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)

--SELECT * FROM [Sales].[InvoiceLines]

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT --*
	YEAR(i.InvoiceDate) AS [Год продажи]
	, MONTH(i.InvoiceDate) AS [Месяц продажи]
	, SUM(il.UnitPrice*il.Quantity) AS [Общая сумма продаж]
FROM [Sales].[Invoices] AS i
INNER JOIN [Sales].[InvoiceLines] AS il ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(il.UnitPrice*il.Quantity) > 4600000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT --*
	 YEAR(i.InvoiceDate) AS [Год продажи]
	, MONTH(i.InvoiceDate) AS [Месяц продажи]
	, il.Description AS [Наименование товара]
	, SUM(il.UnitPrice*il.Quantity) AS [Сумма продаж]
	, (SELECT top 1 InvoiceDate FROM [Sales].[Invoices]
    ) AS [Дата первой продажи]
	, Count(il.Quantity) AS [Количество проданного]
FROM [Sales].[Invoices] AS i
INNER JOIN [Sales].[InvoiceLines] AS il ON il.InvoiceID = i.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), il.Description
HAVING Count(il.Quantity) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)


--Select * from [Sales].[InvoiceLines]

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
