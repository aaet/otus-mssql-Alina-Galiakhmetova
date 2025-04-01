--создаю тестовую базу данных
create database forPartition
go 
alter database forPartition add filegroup year2013
alter database forPartition add filegroup year2014
alter database forPartition add filegroup year2015
alter database forPartition add filegroup year2016
go

--назначение файловой группы
alter database forPartition add file (name = 'year2013', filename = 'C:\sql\engine\data\year2013.ndf') to filegroup year2013
alter database forPartition add file (name = 'year2014', filename = 'C:\sql\engine\data\year2014.ndf') to filegroup year2014
alter database forPartition add file (name = 'year2015', filename = 'C:\sql\engine\data\year2015.ndf') to filegroup year2015
alter database forPartition add file (name = 'year2016', filename = 'C:\sql\engine\data\year2016.ndf') to filegroup year2016
go
--копирую таблицу из WWI в новую бд, она будет сначала кучей после копирования
Select * INTO [forPartition].dbo.[StockItemTransactions_copy]
FROM [WideWorldImporters].[Warehouse].[StockItemTransactions]

USE forPartition;
--выбор граничных точек
select year([TransactionOccurredWhen]), count(*)
from [dbo].[StockItemTransactions_copy]
group by year([TransactionOccurredWhen])
order by 1

--создание граничных точек
create partition function pf_dt(datetime2(7))
as
	range right for values ('2014-01-01 00:00:00.0000000','2015-01-01 00:00:00.0000000','2016-01-01 00:00:00.0000000')
go

--сопоставление секции файловой группе
create partition scheme ps_dt
as
	partition pf_dt to (year2013,year2014,year2015,year2016)
go

--удалить кластерный индекс, он был создан ранее без скрипта
alter table [dbo].[StockItemTransactions_copy] drop constraint [PK_StockItemTransactions_copy] with (move to ps_dt([TransactionOccurredWhen]))

-- как расположены данные
select $partition.pf_dt([TransactionOccurredWhen]) as section, min([TransactionOccurredWhen]) as [min], max([TransactionOccurredWhen]) as [max],
    count(*) as qty, fg.name as fg
from [dbo].[StockItemTransactions_copy]
join sys.partitions p on $partition.pf_dt([TransactionOccurredWhen]) = p.partition_number
join sys.destination_data_spaces dds on p.partition_number = dds.destination_id
join sys.filegroups fg on dds.data_space_id = fg.data_space_id
where p.object_id = object_id('[StockItemTransactions_copy]') -- указываем имя таблицы
group by $partition.pf_dt([TransactionOccurredWhen]), fg.name
order by section
