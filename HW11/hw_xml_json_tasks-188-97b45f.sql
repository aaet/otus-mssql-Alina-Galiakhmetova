/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--1 вариант с OPENXML

-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument XML;

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'C:\otus-mssql-Alina-Galiakhmetova\HW11\StockItems-188-1fb5df.xml', 
 SINGLE_CLOB)
AS data;

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;


-- docHandle - это просто число
SELECT @docHandle AS docHandle;

SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR(100) '@Name', 
	SupplierID int 'SupplierID', 
	UnitPackageID int 'Package/UnitPackageID', 
	OuterPackageID int 'Package/OuterPackageID',
	QuantityPerOuter int 'Package/QuantityPerOuter', 
	TypicalWeightPerUnit float 'Package/TypicalWeightPerUnit', 
	LeadTimeDays int 'LeadTimeDays', 
	IsChillerStock bit 'IsChillerStock', 
	TaxRate  float 'TaxRate', 
	UnitPrice float 'UnitPrice');

	DROP TABLE IF EXISTS #tbl 
	CREATE TABLE #tbl (
		[StockItemName] NVARCHAR(100), 
		SupplierID int, 
		UnitPackageID int, 
		OuterPackageID int,
		QuantityPerOuter int, 
		TypicalWeightPerUnit float, 
		LeadTimeDays int, 
		IsChillerStock bit, 
		TaxRate  float, 
		UnitPrice float);

INSERT INTO #tbl
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR(100) '@Name', 
	SupplierID int 'SupplierID', 
	UnitPackageID int 'Package/UnitPackageID', 
	OuterPackageID int 'Package/OuterPackageID',
	QuantityPerOuter int 'Package/QuantityPerOuter', 
	TypicalWeightPerUnit float 'Package/TypicalWeightPerUnit', 
	LeadTimeDays int 'LeadTimeDays', 
	IsChillerStock bit 'IsChillerStock', 
	TaxRate  float 'TaxRate', 
	UnitPrice float 'UnitPrice');;

-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle;

MERGE [Warehouse].[StockItems] AS Target
USING #tbl AS Source
    ON (Target.StockItemName = Source.StockItemName COLLATE Latin1_General_100_CI_AI)
WHEN MATCHED 
    THEN UPDATE 
		SET SupplierID = Source.[SupplierID], 
		    UnitPackageID = Source.[UnitPackageID],
			OuterPackageID = Source.[OuterPackageID],
			QuantityPerOuter = Source.QuantityPerOuter,
			TypicalWeightPerUnit = Source.TypicalWeightPerUnit, 
			LeadTimeDays = Source.LeadTimeDays, 
			IsChillerStock = Source.IsChillerStock, 
			TaxRate = Source.TaxRate, 
			UnitPrice = Source.UnitPrice
WHEN NOT MATCHED 
    THEN INSERT (
				[StockItemID],
				[StockItemName],
				[SupplierID],
				[UnitPackageID],
				[OuterPackageID],
				[QuantityPerOuter],
				[TypicalWeightPerUnit],
				[LeadTimeDays],
				[IsChillerStock],
				[TaxRate],
				[UnitPrice],
				[LastEditedBy],
				[ValidFrom],
				[ValidTo])
        VALUES (
				DEFAULT,
				Source.StockItemName,
				Source.[SupplierID], 
				Source.[UnitPackageID],
				Source.[OuterPackageID],
				Source.QuantityPerOuter,
				Source.TypicalWeightPerUnit, 
				Source.LeadTimeDays, 
				Source.IsChillerStock, 
				Source.TaxRate, 
				Source.UnitPrice,
				1,
				DEFAULT,
				DEFAULT);
-- 2 вариант 

DECLARE @x XML,
		@rowNumber int = 1

--Select @strRowNumber

DROP TABLE IF EXISTS #tbl 
CREATE TABLE #tbl (
	[StockItemName] NVARCHAR(100), 
	SupplierID int, 
	UnitPackageID int, 
	OuterPackageID int,
	QuantityPerOuter int, 
	TypicalWeightPerUnit float, 
	LeadTimeDays int, 
	IsChillerStock bit, 
	TaxRate  float, 
	UnitPrice float)
SET @x = ( 
  SELECT * FROM OPENROWSET
  (BULK 'C:\otus-mssql-Alina-Galiakhmetova\HW11\StockItems-188-1fb5df.xml',
   SINGLE_CLOB) AS d);

-- value(XQuery/XPath, Type) - возвращает скалярное (единичное) значение
-- query(XQuery/XPath) - возвращает XML
---- exists(XQuery/XPath) - проверяет есть ли данные; 0 - not exists, 1 - exists
--Select @x.query('count(/StockItems/Item/@Name)')
WHILE @rowNumber<CAST(CAST(@x.query('count(/StockItems/Item/@Name)') AS nvarchar(50)) AS INT)+1
BEGIN 
INSERT INTO #tbl (
	[StockItemName], 
	[SupplierID], 
	UnitPackageID, 
	OuterPackageID,
	QuantityPerOuter, 
	TypicalWeightPerUnit, 
	LeadTimeDays, 
	IsChillerStock, 
	TaxRate, 
	UnitPrice)

VALUES( 
   @x.value('(/StockItems/Item/@Name)[position()=sql:variable("@rowNumber")][1]', 'nvarchar(255)'),
   @x.value('(/StockItems/Item/SupplierID)[position()=sql:variable("@rowNumber")][1]', 'int'),
   @x.value('(/StockItems/Item/Package/UnitPackageID)[position()=sql:variable("@rowNumber")][1]', 'int'),
   @x.value('(/StockItems/Item/Package/OuterPackageID)[position()=sql:variable("@rowNumber")][1]', 'int'),
   @x.value('(/StockItems/Item/Package/QuantityPerOuter)[position()=sql:variable("@rowNumber")][1]', 'int'),
   @x.value('(/StockItems/Item/Package/TypicalWeightPerUnit)[position()=sql:variable("@rowNumber")][1]', 'decimal(18,2)'),
   @x.value('(/StockItems/Item/LeadTimeDays)[position()=sql:variable("@rowNumber")][1]', 'int'),
   @x.value('(/StockItems/Item/IsChillerStock)[position()=sql:variable("@rowNumber")][1]', 'bit'),
   @x.value('(/StockItems/Item/TaxRate)[position()=sql:variable("@rowNumber")][1]', 'decimal(18,2)'),
   @x.value('(/StockItems/Item/UnitPrice)[position()=sql:variable("@rowNumber")][1]', 'decimal(18,2)')
   )

SET @rowNumber += 1
END


MERGE [Warehouse].[StockItems] AS Target
USING #tbl AS Source
    ON (Target.StockItemName = Source.StockItemName COLLATE Latin1_General_100_CI_AI)
WHEN MATCHED 
    THEN UPDATE 
		SET SupplierID = Source.[SupplierID], 
		    UnitPackageID = Source.[UnitPackageID],
			OuterPackageID = Source.[OuterPackageID],
			QuantityPerOuter = Source.QuantityPerOuter,
			TypicalWeightPerUnit = Source.TypicalWeightPerUnit, 
			LeadTimeDays = Source.LeadTimeDays, 
			IsChillerStock = Source.IsChillerStock, 
			TaxRate = Source.TaxRate, 
			UnitPrice = Source.UnitPrice
WHEN NOT MATCHED 
    THEN INSERT (
				[StockItemID],
				[StockItemName],
				[SupplierID],
				[UnitPackageID],
				[OuterPackageID],
				[QuantityPerOuter],
				[TypicalWeightPerUnit],
				[LeadTimeDays],
				[IsChillerStock],
				[TaxRate],
				[UnitPrice],
				[LastEditedBy],
				[ValidFrom],
				[ValidTo])
        VALUES (
				DEFAULT,
				Source.StockItemName,
				Source.[SupplierID], 
				Source.[UnitPackageID],
				Source.[OuterPackageID],
				Source.QuantityPerOuter,
				Source.TypicalWeightPerUnit, 
				Source.LeadTimeDays, 
				Source.IsChillerStock, 
				Source.TaxRate, 
				Source.UnitPrice,
				1,
				DEFAULT,
				DEFAULT);


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
USE [WideWorldImporters]
Select StockItemName [@Name], SupplierID [SupplierID], UnitPackageID [Package/UnitPackageID], OuterPackageID [Package/OuterPackageID], QuantityPerOuter [Package/QuantityPerOuter], TypicalWeightPerUnit [Package/TypicalWeightPerUnit], LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 
FROM [Warehouse].[StockItems] 
FOR XML PATH('Item'), ROOT('StockItems')


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

Select 
	StockItemID,
	StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM [Warehouse].[StockItems]

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/
Select 
	StockItemID,
	StockItemName,
	CustomFields,
	JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
FROM [Warehouse].[StockItems] 
CROSS APPLY OPENJSON(CustomFields, '$.Tags') s
WHERE s.value = 'Vintage';
--WHERE CustomFields like '%Vintage%'