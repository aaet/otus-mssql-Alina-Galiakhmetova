USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [dbo].[TotalYearByStockItemId]    Script Date: 4/1/2025 1:17:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================  
CREATE PROCEDURE [dbo].[TotalYearByStockItemId] 
	-- Add the parameters for the stored procedure here
	@stockItemId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  Select year([InvoiceDate]) [year]
	  --,il.[Quantity]
   --   ,il.[UnitPrice]
	  ,SUM(il.[Quantity]*il.[UnitPrice]) Total
	  ,si.StockItemName
	  ,si.StockItemID
  FROM [WideWorldImporters].[Sales].[Invoices] i
  INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il ON il.InvoiceID = i.InvoiceID
  INNER JOIN [WideWorldImporters].[Warehouse].[StockItems] si ON si.[StockItemID] = il.[StockItemID]
  where si.StockItemID = @stockItemId
  group by year([InvoiceDate]),si.StockItemName,si.StockItemID

END
GO


