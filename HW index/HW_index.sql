USE [TO]
GO
--Кластерные индексы и поля уникальности были сгенерированы автоматически с помощью ресурса https://app.quickdatabasediagrams.com/ Далее добавила недостающие некластерные индексы с помощью конструкции
CREATE NONCLUSTERED INDEX <имя индекса>
    ON <имя таблицы> (имя поля);

--ниже даны скрипты создания таблиц со всеми индексами

--1. В таблице Департамент (это справочник отделов компании) только 2 поля и досаточно кластерного индекса, поиск будет по нему
/****** Object:  Table [dbo].[Departments]    Script Date: 3/21/2025 9:45:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Departments](
	[nDepartmentId] [int] IDENTITY(1,1) NOT NULL,
	[szDepartmentName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Departments] PRIMARY KEY CLUSTERED 
(
	[nDepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--2. В таблице Сотрудники некластерным индексом назначен имя сотрудника, по имени будет частый поиск
/****** Object:  Table [dbo].[Employees]    Script Date: 3/21/2025 9:51:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employees](
	[nEmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[szName] [nvarchar](50) NOT NULL,
	[szAddress] [nvarchar](100) NULL,
	[szMobilePhone] [nvarchar](50) NOT NULL,
	[szEmail] [nvarchar](50) NOT NULL,
	[nDepartmentId] [int] NOT NULL,
	[nTitleId] [int] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[nEmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Employees_szEmail] UNIQUE NONCLUSTERED 
(
	[szEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_Employees_szMobilePhone] UNIQUE NONCLUSTERED 
(
	[szMobilePhone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--3. Таблица [dbo].[EmployeeTitles] является справочником, кластерные индексы не нужны
/****** Object:  Table [dbo].[EmployeeTitles]    Script Date: 3/21/2025 9:53:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmployeeTitles](
	[nTitleId] [int] IDENTITY(1,1) NOT NULL,
	[szTitleName] [nvarchar](100) NOT NULL,
	[nDepartmentId] [int] NOT NULL,
	[isTOTeacher] [bit] NOT NULL,
 CONSTRAINT [PK_EmployeeTitles] PRIMARY KEY CLUSTERED 
(
	[nTitleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeTitles]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeTitles_nDepartmentId] FOREIGN KEY([nDepartmentId])
REFERENCES [dbo].[Departments] ([nDepartmentId])
GO

ALTER TABLE [dbo].[EmployeeTitles] CHECK CONSTRAINT [FK_EmployeeTitles_nDepartmentId]
GO

--4. Таблица [dbo].[EmployeeTitlesExams] это таблица связи много ко многим для [dbo].[EmployeeTitles] и [dbo].[Exams] кластерные индексы не требуются
/****** Object:  Table [dbo].[EmployeeTitlesExams]    Script Date: 3/21/2025 9:58:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EmployeeTitlesExams](
	[nTitleId] [int] NOT NULL,
	[nExamId] [int] NOT NULL,
 CONSTRAINT [PK_EmployeeTitlesExams] PRIMARY KEY CLUSTERED 
(
	[nTitleId] ASC,
	[nExamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeTitlesExams]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeTitles_nTitleId] FOREIGN KEY([nTitleId])
REFERENCES [dbo].[EmployeeTitles] ([nTitleId])
GO

ALTER TABLE [dbo].[EmployeeTitlesExams] CHECK CONSTRAINT [FK_EmployeeTitles_nTitleId]
GO

ALTER TABLE [dbo].[EmployeeTitlesExams]  WITH CHECK ADD  CONSTRAINT [FK_Exams_nExamId] FOREIGN KEY([nExamId])
REFERENCES [dbo].[Exams] ([nExamId])
GO

ALTER TABLE [dbo].[EmployeeTitlesExams] CHECK CONSTRAINT [FK_Exams_nExamId]
GO

--5 Таблица [dbo].[ExamLines] - список всех экзаменов, которые сданы и которые предстоит сдать. Созданы кластерный индекс nId экзамена 2 некластерных индекса [AK_nExamId] и [AK_dtDeadlineAt],это поля по которым наиболее часто будет поиск
/****** Object:  Table [dbo].[ExamLines]    Script Date: 3/21/2025 10:03:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExamLines](
	[nId] [int] IDENTITY(1,1) NOT NULL,
	[nEmployeeID] [int] NOT NULL,
	[nExamId] [int] NOT NULL,
	[bCompleted] [bit] NOT NULL,
	[dtCreatedAt] [datetime2](7) NOT NULL,
	[dtDeadlineAt] [datetime2](7) NOT NULL,
	[dtCompletedAt] [datetime2](7) NULL,
 CONSTRAINT [PK_ExamLines] PRIMARY KEY CLUSTERED 
(
	[nId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--6 Таблица [dbo].[Exams] - это справочник экзаменов,nExamId - кластерный индекс, некластерный 1 - [AK_szExamName] - имя экзамена
/****** Object:  Table [dbo].[Exams]    Script Date: 3/21/2025 10:05:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Exams](
	[nExamId] [int] IDENTITY(1,1) NOT NULL,
	[szExamName] [nvarchar](100) NOT NULL,
	[nTitleId] [int] NOT NULL,
	[nPeriod] [int] NULL,
 CONSTRAINT [PK_Exams] PRIMARY KEY CLUSTERED 
(
	[nExamId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO