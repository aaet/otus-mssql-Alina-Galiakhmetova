USE [WideWorldImporters];
--велючить статистику с CPU 
--SET STATISTICS IO, TIME ON 
-- Ctrl + M
-- то, что мешает читать планы у Sales.Customers
-- ALTER SECURITY POLICY [Application].[FilterCustomersBySalesTerritoryRole] WITH (STATE = OFF)

Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

--применение хинтов. Получила значительное увеличение cost запроса
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    INNER MERGE JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    INNER HASH JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    INNER LOOP JOIN  Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID


--др порядок в запросе, по принципу отфильтровать как можно больше записей. Изменение порядка таблиц дало хорошие показатели CPU time
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Warehouse.StockItemTransactions AS ItemTrans
    JOIN Sales.Invoices AS Inv 
        ON Inv.InvoiceID = ItemTrans.InvoiceID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
	JOIN Sales.Orders AS ord
		ON ord.OrderID = Inv.OrderID
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

--изменение порядка запроса OPTION(FORCE ORDER) - порядок с самой маленькой таблицы. Это привело к появлению параллелизма и увеличению cost запроса, доптаблиц Worktable и Workfile
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
OPTION(FORCE ORDER)
