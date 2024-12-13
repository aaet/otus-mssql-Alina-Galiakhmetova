/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DROP table if EXISTS #tbl
CREATE Table #tbl (dt nvarchar(50), CustomerName nvarchar(100), kol int)
iNSERT INTO #tbl 
Select 
		'01.' + RIGHT(FORMAT([InvoiceDate], 'dd.MM.yyyy'),7),
		'['+REPLACE(RIGHT(c.[CustomerName], lEN(c.[CustomerName])-CHARINDEX('(',c.[CustomerName])),')','')+']' ,
		count(*)
		--STRING_AGG(Str([InvoiceID]),' ,')
FROM [Sales].[Invoices] i
INNER JOIN [Sales].[Customers] c ON c.CustomerID = i.CustomerID
GROUP BY '01.' + RIGHT(FORMAT([InvoiceDate], 'dd.MM.yyyy'),7),c.[CustomerName]

--Здесь пришлось часть клиентов вырезать, так как столкнулась с ограничением row в 8060 bytes
Declare @list nvarchar(max) = LEFT(REPLACE((SELECT STUFF((SELECT DISTINCT (', ' + CustomerName) FROM #tbl order by (', ' + CustomerName) FOR XML PATH('')), 1, 2, '')),'''', ''''''),LEN(REPLACE((SELECT STUFF((SELECT DISTINCT (', ' + CustomerName) FROM #tbl order by (', ' + CustomerName) FOR XML PATH('')), 1, 2, '')),'''', '''''')) - 62),
		@query nvarchar(max)
Select * FROM #tbl
Select @list

SET @query = N'
select dt as InvoiceMont
      ,'+@list+'
from
(select dt, CustomerName, kol from #tbl)
as SourceTable
pivot
(AVG(kol)
for CustomerName  
in ('+@list+')
)
as PivotTable
ORDER BY InvoiceMont;'

	select @query;
EXEC sp_executesql @query, @parameters = N'@list nvarchar(max)', @list = @list

