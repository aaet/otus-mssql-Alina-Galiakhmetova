/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
DROP TABLE #tbl
CREATE Table #tbl (dt nvarchar(50), CustomerName nvarchar(100), kol int)
iNSERT INTO #tbl 
Select 
		'01.' + RIGHT(FORMAT([InvoiceDate], 'dd.MM.yyyy'),7),
		REPLACE(RIGHT(c.[CustomerName], lEN(c.[CustomerName])-15),')',''),
		count(*)
		--STRING_AGG(Str([InvoiceID]),' ,')
FROM [Sales].[Invoices] i
INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID AND (c.CustomerID between 1 AND 6)
GROUP BY '01.' + RIGHT(FORMAT([InvoiceDate], 'dd.MM.yyyy'),7),c.[CustomerName]
--ORDER BY 1

Select * FROM #tbl ORDER BY 1

select dt as InvoiceMonth --Ñîäåðæèìîå ïåðâîé êîëîíêè â ðàçâåðíóòîé ñòðîêå äàííûõ(îáû÷íî êðàòêîå îïèñàíèå ñòðîêè = ñðåäíåå êîëè÷åñòâî)
      ,[Peeples Valley, AZ],[Sylvanite, MT],[Gasport, NY],[Jessie, ND],[Medicine Lodge, KS],[Head Office]
from
(select dt, CustomerName, kol from #tbl) --òî êàê âûãëÿäèò èñõîäíûé íàáîð äàííûõ
as SourceTable
pivot
(AVG(kol)
for CustomerName  --â ýòîé êîëîíêå èç SourceTable èùåì íàçâàíèÿ êîëîíîê äëÿ áóäóùåé ðàçâåðíóòîé òàáëèöû
in ([Peeples Valley, AZ],[Sylvanite, MT],[Gasport, NY],[Jessie, ND],[Medicine Lodge, KS],[Head Office]) --òîëüêî ýòè íàçâàíèÿ êîëîíîê äëÿ áóäóùåé ðàçâåðíóòîé òàáëèöû áåðåì èç ñòðîê â êîëîíêå fio
)
as PivotTable

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
DROP TABLE #tbl
CREATE Table #tbl (CustomerName nvarchar(100), [DeliveryAddressLine1] nvarchar(100), [DeliveryAddressLine2] nvarchar(100), [PostalAddressLine1] nvarchar(100), [PostalAddressLine2] nvarchar(100))
iNSERT INTO #tbl 
Select CustomerName
	, [DeliveryAddressLine1]
	, [DeliveryAddressLine2]
	, [PostalAddressLine1]
	, [PostalAddressLine2]
FROM [Sales].[Customers]
WHERE CustomerName like 'Tailspin Toys%'
Select * FROM #tbl

SELECT CustomerName,  AddressLine
FROM (
    SELECT CustomerName, [DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2]
    FROM #tbl
) p
UNPIVOT
(
    AddressLine FOR AddressL IN ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])
) AS unpvt;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
DROP TABLE #tbl
CREATE Table #tbl (
		CountryID int
		, CountryName nvarchar(100)
		, [IsoAlpha3Code] nvarchar(100)
		, [IsoNumericCode]	nvarchar(100) 
)
iNSERT INTO #tbl 
Select CountryID
		, CountryName
		, [IsoAlpha3Code]
		, CAST([IsoNumericCode] AS nvarchar(100)) AS [IsoNumericCode]
FROM [Application].[Countries]

Select * FROM #tbl

SELECT CountryId, CountryName, Code
FROM (
    SELECT CountryID, CountryName, [IsoAlpha3Code], [IsoNumericCode]
    FROM #tbl
) p
UNPIVOT
(
    Code FOR CodeL IN ([IsoAlpha3Code], [IsoNumericCode])
) AS unpvt;
/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/


Select c.CustomerID
		, c.CustomerName
		, o.InvoiceID 
		, o.UnitPrice
		, o.InvoiceDate
FROM [Sales].[Customers] c 
CROSS APPLY (Select TOP 2 i.CustomerID
							, i.InvoiceID
							, il.UnitPrice
							, i.InvoiceDate
			FROM [Sales].[Invoices] i
			INNER JOIN [Sales].[InvoiceLines] il ON il.InvoiceID = i.InvoiceID
			WHERE i.CustomerID = c.CustomerID
			ORDER BY c.CustomerName
					, il.UnitPrice desc) o
ORDER BY c.CustomerName
