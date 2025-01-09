-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/IPRIuu
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- Мой проект - инструмент для хранения данных
-- по сдаче экзаменов по то, тб,
-- электробезопасности и пр. экзаменам.
-- Есть разовые экзамены
-- и экзамены, которые сдаются периодически.
-- Предполагается, что за пару недель
-- до dtDeadlineAt сотруднику придет оповещение в виде
-- емайла и смс о необходимости сдать экзамен.
-- Также оповещение придет ответсвенному за экзамены в компании.
-- To reset the sample schema, replace everything with
-- two dots ('..' - without quotes).

SET XACT_ABORT ON

BEGIN TRANSACTION QUICKDBD

CREATE DATABASE [TO];

CREATE TABLE [Employees] (
    [nEmployeeID] int IDENTITY(1,1)  NOT NULL ,
    [szFistName] nvarchar(50)  NOT NULL ,
    [szLastName] nvarchar(50)  NOT NULL ,
    [szAddress] nvarchar(100)  NULL ,
    [szMobilePhone] nvarchar(50)  NOT NULL ,
    [szEmail] nvarchar(50)  NOT NULL ,
    [nDepartmentId] int  NOT NULL ,
    [nTitleId] int  NOT NULL ,
    [IsTeacher] bit  NOT NULL ,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED (
        [nEmployeeID] ASC
    ),
    CONSTRAINT [UK_Employees_szMobilePhone] UNIQUE (
        [szMobilePhone]
    ),
    CONSTRAINT [UK_Employees_szEmail] UNIQUE (
        [szEmail]
    )
)

-- список всех отделов
CREATE TABLE [Departments] (
    [nDepartmentId] int IDENTITY(1,1)  NOT NULL ,
    [szDepartmentName] nvarchar(100)  NOT NULL ,
    CONSTRAINT [PK_Departments] PRIMARY KEY CLUSTERED (
        [nDepartmentId] ASC
    )
)

-- список должностей
CREATE TABLE [EmployeeTitles] (
    [nTitleId] int IDENTITY(1,1)  NOT NULL ,
    [szTitleName] nvarchar(100)  NOT NULL ,
    [nDepartmentId] int  NOT NULL ,
    [isTOTeacher] bit  NOT NULL ,
    CONSTRAINT [PK_EmployeeTitles] PRIMARY KEY CLUSTERED (
        [nTitleId] ASC
    )
)

-- Для связи многие ко многим
CREATE TABLE [EmployeeTitlesExams] (
    [nTitleId] int  NOT NULL ,
    [nExamId] int  NOT NULL,
	CONSTRAINT [PK_EmployeeTitlesExams] PRIMARY KEY CLUSTERED (
        [nTitleId], [nExamId] ASC
    )
)

-- справочник всех экзаменов, nPeriod - периодичность сдачи. Если null, то непериодичный экзамен
CREATE TABLE [Exams] (
    [nExamId] int IDENTITY(1,1)  NOT NULL ,
    [szExamName] nvarchar(100)  NOT NULL ,
    [nTitleId] int  NOT NULL ,
    [nPeriod] int  NULL ,
    CONSTRAINT [PK_Exams] PRIMARY KEY CLUSTERED (
        [nExamId] ASC
    )
)

-- Все экзамены для всех сотрудников, которые необходимо сдать.
-- bCompleted 0, если экзамен не сдан, 1 если сдан.
CREATE TABLE [ExamLines] (
    [nId] int IDENTITY(1,1)  NOT NULL ,
    [nEmployeeID] int  NOT NULL ,
    [nExamId] int  NOT NULL ,
    [bCompleted] bit  NOT NULL ,
    [dtCreatedAt] datetime2(7)  NOT NULL ,
    [dtDeadlineAt] datetime2(7)  NOT NULL ,
    [dtCompletedAt] datetime2(7) ,
    CONSTRAINT [PK_ExamLines] PRIMARY KEY CLUSTERED (
        [nId] ASC
    )
)

ALTER TABLE [Employees] WITH CHECK ADD CONSTRAINT [FK_Employees_nDepartmentId] FOREIGN KEY([nDepartmentId])
REFERENCES [Departments] ([nDepartmentId])

ALTER TABLE [Employees] CHECK CONSTRAINT [FK_Employees_nDepartmentId]

ALTER TABLE [Employees] WITH CHECK ADD CONSTRAINT [FK_Employees_nTitleId] FOREIGN KEY([nTitleId])
REFERENCES [EmployeeTitles] ([nTitleId])

ALTER TABLE [Employees] CHECK CONSTRAINT [FK_Employees_nTitleId]

ALTER TABLE [EmployeeTitlesExams] WITH CHECK ADD CONSTRAINT [FK_EmployeeTitles_nTitleId] FOREIGN KEY([nTitleId])
REFERENCES [EmployeeTitles] ([nTitleId])

ALTER TABLE [EmployeeTitlesExams] CHECK CONSTRAINT [FK_EmployeeTitles_nTitleId]

ALTER TABLE [EmployeeTitles] WITH CHECK ADD CONSTRAINT [FK_EmployeeTitles_nDepartmentId] FOREIGN KEY([nDepartmentId])
REFERENCES [Departments] ([nDepartmentId])

ALTER TABLE [EmployeeTitles] CHECK CONSTRAINT [FK_EmployeeTitles_nDepartmentId]

ALTER TABLE [EmployeeTitlesExams] WITH CHECK ADD CONSTRAINT [FK_Exams_nExamId] FOREIGN KEY([nExamId])
REFERENCES [Exams] ([nExamId])

ALTER TABLE [EmployeeTitlesExams] CHECK CONSTRAINT [FK_Exams_nExamId]

ALTER TABLE [ExamLines] WITH CHECK ADD CONSTRAINT [FK_ExamLines_nEmployeeID] FOREIGN KEY([nEmployeeID])
REFERENCES [Employees] ([nEmployeeID])

ALTER TABLE [ExamLines] CHECK CONSTRAINT [FK_ExamLines_nEmployeeID]

ALTER TABLE [ExamLines] WITH CHECK ADD CONSTRAINT [FK_ExamLines_nExamId] FOREIGN KEY([nExamId])
REFERENCES [Exams] ([nExamId])

ALTER TABLE [ExamLines] CHECK CONSTRAINT [FK_ExamLines_nExamId]

COMMIT TRANSACTION QUICKDBD


--заполнение таблиц
USE [TO]
GO

INSERT INTO [dbo].[Departments]
           (
           [szDepartmentName])
     VALUES
           ('Administration'),
		   ('ASUTP')
GO
--
USE [TO]
GO

INSERT INTO [dbo].[EmployeeTitles]
           (
           [szTitleName]
			,[nDepartmentId]
			,[isTOTeacher])
     VALUES
		(N'Бухгалтер',1,0),
           (N'Наладчик 1 категории',2,0),
		   (N'Наладчик 2 категории',2,0),
		   (N'Наладчик 3 категории',2,0)
GO

--
USE [TO]
GO

INSERT INTO [dbo].[Employees]
           (
           [szFistName]
           ,[szLastName]
           ,[szAddress]
           ,[szMobilePhone]
           ,[szEmail]
           ,[nDepartmentId]
           ,[nTitleId])
     VALUES
		('Zaliya','Aitova','Adress3','8900004','zaitova@mail.ru',1,8),
           ('Ivan','Ivanov','Adress1','8900001','ivanova@mail.ru',2,5),
		   ('Oleg','Olegov','Adress1','8900002','olegov@mail.ru',2,6),
		   ('Sergey','Olegov','Adress1','8900003','solegov@mail.ru',2,7)
GO

--
USE [TO]
GO

INSERT INTO [dbo].[Exams]
           (
           [szExamName]
           ,[nTitleId]
           ,[nPeriod])
     VALUES
			(N'ТО и ТБ',5,30),
			(N'Электробезопасность 2 группа',8,30),
           (N'Электробезопасность 2 группа',5,30),
		   (N'Электробезопасность 3 группа',6,30),
		   (N'Электробезопасность 4 группа',7,30)
GO


USE [TO]
GO
--- Уже сданные экзамены
INSERT INTO [dbo].[ExamLines]
           ([nEmployeeID]
           ,[nExamId]
           ,[bCompleted]
           ,[dtCreatedAt]
           ,[dtDeadlineAt]
           ,[dtCompletedAt])
     VALUES
           (3,5,1,GETUTCDATE(),DATEADD(d, 14, GETUTCDATE()),GETUTCDATE()),
		   (4,4,1,GETUTCDATE(),DATEADD(d, 14, GETUTCDATE()),GETUTCDATE()),
		   (5,5,1,GETUTCDATE(),DATEADD(d, 14, GETUTCDATE()),GETUTCDATE()),
		   (6,2,0,GETUTCDATE(),DATEADD(d, 14, GETUTCDATE()),NULL)

INSERT INTO [dbo].[EmployeeTitlesExams]
           ([nTitleId]
           ,[nExamId])
     VALUES
           (5,6),
		   (5,2),
		   (8,2),
		   (7,6),
		   (7,2)

