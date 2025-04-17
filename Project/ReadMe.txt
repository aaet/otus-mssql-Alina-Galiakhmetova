# Мой проект - инструмент для хранения данных 
# по сдаче экзаменов по то, тб, 
# электробезопасности и пр. экзаменам. 
# Есть разовые экзамены
# и экзамены, которые сдаются периодически.
# Предполагается, что за пару недель 
# до dtDeadlineAt сотруднику придет оповещение в виде
# емайла и смс о необходимости сдать экзамен.
# Также оповещение придет ответсвенному за экзамены в компании.
# To reset the sample schema, replace everything with
# two dots ('..' - without quotes).

Employees
-
nEmployeeID IDENTITY(1,1) PK
szName nvarchar(50)
szAddress NULL nvarchar(100)
szMobilePhone unique nvarchar(50)
szEmail unique nvarchar(50)
nDepartmentId int FK >- Departments.nDepartmentId
nTitleId int FK >- EmployeeTitles.nTitleId
IsTeacher bit

#список всех отделов
Departments
--
nDepartmentId IDENTITY(1,1) PK
szDepartmentName nvarchar(100)

#список должностей
EmployeeTitles
--
nTitleId IDENTITY(1,1) PK
szTitleName nvarchar(100)
nDepartmentId int FK >- Departments.nDepartmentId
isTOTeacher bit

#Для связи многие ко многим
EmployeeTitlesExams
--
nTitleId int FK >- EmployeeTitles.nTitleId
nExamId int FK >- Exams.nExamId
PK (nTitleId,nExamId)

#справочник всех экзаменов, nPeriod - периодичность сдачи
Exams
--
nExamId IDENTITY(1,1) PK
szExamName nvarchar(100)
nTitleId int
nPeriod NULL int

#Все экзамены для всех сотрудников, которые необходимо сдать.
#bCompleted 0, если экзамен не сдан, 1 если сдан.
ExamLines
--
nId IDENTITY(1,1) PK 
nEmployeeID int FK >- Employees.nEmployeeID
nExamId int FK >- Exams.nExamId
bCompleted bit
dtCreatedAt datetime2(7)
dtDeadlineAt datetime2(7)
dtCompletedAt datetime2(7)


