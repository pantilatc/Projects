GO

CREATE DATABASE  PCP;

GO

USE PCP;

GO

CREATE TABLE Department
(DepID INT IDENTITY(10,10) CONSTRAINT dep_id_pk PRIMARY KEY,
DepName VARCHAR(15)
);

GO

CREATE TABLE Employees
(EmpID INT IDENTITY,
EmpName VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
StreetAddress VARCHAR(40),
City VARCHAR(15),
Country VARCHAR(6) DEFAULT('Israel'),
Phon VARCHAR(10),
Email VARCHAR(50),
DManager INT,
DepID INT NOT NULL,
CONSTRAINT emp_id_pk PRIMARY KEY(EmpID),
CONSTRAINT emp_birth_ck CHECK(YEAR(GETDATE())-YEAR(BirthDate) > 18),
CONSTRAINT emp_phon_uk UNIQUE(Phon),
CONSTRAINT emp_email_uk UNIQUE(Email),
CONSTRAINT emp_email_ck CHECK(Email LIKE '%@%.%'),
CONSTRAINT emp_dman_fk FOREIGN KEY(DManager) REFERENCES Employees(EmpID),
CONSTRAINT emp_dep_fk FOREIGN KEY(DepID) REFERENCES Department(DepID)
);

GO

CREATE TABLE Attendence
(EmpID INT,
DateAtt DATE NOT NULL,
BeginHour TIME(0) NOT NULL,
EndHour TIME(0) NOT NULL,
TotalWork MONEY,
CONSTRAINT att_id_pk PRIMARY KEY(EmpID, DateAtt),
CONSTRAINT att_emp_fk FOREIGN KEY(EmpID) REFERENCES Employees(EmpID),
CONSTRAINT att_hour_ck CHECK(EndHour > BeginHour),
CONSTRAINT att_total_ck CHECK(11 > TotalWork)
);

GO

CREATE TABLE [Daily sales]
(EmpID INT NOT NULL,
DayDate DATE NOT NULL,
Subscription INT,
Donation MONEY
CONSTRAINT daisale_id_pk PRIMARY KEY(EmpID, DayDate),
CONSTRAINT daisale_emp_fk FOREIGN KEY(EmpID) REFERENCES Employees(EmpID)
);

GO

CREATE TABLE Salary
(EmpID INT NOT NULL,
MmSalary INT NOT NULL,
YYSalary  INT NOT NULL,
SumTotalWork MONEY,
BasicSalary MONEY,
SumSubscrip INT,
BonusSub MONEY,
SumDonation INT,
BonusDon MONEY,
TotalSalary MONEY,
CONSTRAINT sal_id_pk PRIMARY KEY(EmpID, MmSalary, YYSalary),
CONSTRAINT sal_emp_fk FOREIGN KEY(EmpID) REFERENCES Employees(EmpID),
CONSTRAINT sal_bonsub_ck CHECK (BonusSub < 500)
);

GO

INSERT INTO Department
VALUES ('Management'),
	   ('Dep management'),
	   ('Secretariat'),
	   ('Telephony');

GO

INSERT INTO Employees
VALUES ('Chaya Pantliat','1997-09-16','Tzokerman 12','Jerosalem',DEFAULT,'0583285353','pchaya@bhl.org.il',NULL,10),
	   ('Hadassa Nosboim','1999-01-01','RavHamnona 8','Beit-shemesh',DEFAULT,'0533124227','hadassa@bhl.org.il',1,20),
	   ('Rot doitsh','1968-05-14','kutler 6','Jerosalem',DEFAULT,'0534182794','rut@bhl.org.il',2,30),
	   ('Chaya Goldberg','1964-08-22','Tzvieli 22','Jerosalem',DEFAULT,'0527170536','chaya@bhl.org.il',2,30),
	   ('Sara hershler','1964-08-18','RabiAkiva 26','Beitar',DEFAULT,'0548420303','sara@bhl.org.il',2,30),
	   ('Rot Chasin','2003-07-01','Yermiaho 40','Jerosalem',DEFAULT,'0527698704','rotchsin@gmail.com',2,40),
	   ('Batsheva Ben-menachem','2003-08-08','Zevin 46','Jerosalem',DEFAULT,'0527638077','bat7benmenachem@gmail.com',2,40);

GO

INSERT INTO Attendence (EmpID,DateAtt,BeginHour,EndHour)
VALUES (2,'2023-11-05','07:08:00','14:36:00'),
	   (3,'2023-11-05','08:39:00','13:45:00'),
	   (4,'2023-11-05','15:18:00','21:54:00'),
	   (6,'2023-11-05','16:32:00','20:32:00'),
	   (7,'2023-11-05','16:32:00','20:08:00'),
	   (2,'2023-11-06','07:09:00','14:36:00'),
	   (3,'2023-11-06','08:31:00','11:53:00'),
	   (5,'2023-11-06','13:57:00','21:31:00'),
	   (4,'2023-11-06','15:06:00','21:55:00'),
	   (6,'2023-11-06','16:03:00','20:08:00'),
	   (7,'2023-11-06','16:07:00','20:14:00'),
	   (2,'2023-11-07','07:06:00','14:38:00'),
	   (3,'2023-11-07','08:27:00','13:54:00'),
	   (5,'2023-11-07','14:10:00','21:29:00'),
	   (4,'2023-11-07','15:06:00','21:55:00'),
	   (7,'2023-11-07','16:49:00','21:28:00'),
	   (6,'2023-11-07','17:25:00','21:27:00'),
	   (2,'2023-11-08','07:02:00','17:16:00'),
	   (3,'2023-11-08','09:31:00','13:55:00'),
	   (5,'2023-11-08','14:00:00','20:59:00'),
	   (4,'2023-11-08','15:07:00','21:55:00'),
	   (7,'2023-11-08','16:24:00','20:27:00'),
	   (6,'2023-11-08','16:58:00','21:07:00'),
	   (2,'2023-11-09','07:02:00','14:31:00'),
	   (3,'2023-11-09','08:53:00','13:30:00'),
	   (5,'2023-11-09','14:17:00','20:38:00'),
	   (4,'2023-11-09','15:19:00','21:53:00'),
	   (7,'2023-11-09','16:02:00','20:15:00'),
	   (6,'2023-11-09','16:06:00','20:13:00');

GO

WITH MinHour
AS
(SELECT EmpID, DateAtt, 
		CAST(DATEDIFF(MI,BeginHour,EndHour) AS MONEY)/60 AS MinHour
FROM  Attendence)
UPDATE Attendence
SET TotalWork =  (SELECT MinHour
				  FROM MinHour
				  WHERE Attendence.EmpID = MinHour.EmpID
				  AND Attendence.DateAtt = MinHour.DateAtt);

GO

INSERT INTO [Daily sales]
VALUES (3,'2023-11-05',30,50),
	   (4,'2023-11-05',43,567),
	   (6,'2023-11-05',9,0),
	   (7,'2023-11-05',9,195),
	   (3,'2023-11-06',12,481),
	   (4,'2023-11-06',56,501),
	   (5,'2023-11-06',29,90),
	   (6,'2023-11-06',12,181),
	   (7,'2023-11-06',9,420),
	   (3,'2023-11-07',24,103),
	   (4,'2023-11-07',48,1275),
	   (5,'2023-11-07',40,156),
	   (6,'2023-11-07',10,294),
	   (7,'2023-11-07',12,252),
	   (3,'2023-11-08',37,585),
	   (4,'2023-11-08',47,716),
	   (5,'2023-11-08',33,380),
	   (6,'2023-11-08',12,231),
	   (7,'2023-11-08',11,253),
	   (3,'2023-11-09',12,250),
	   (4,'2023-11-09',39,770),
	   (5,'2023-11-09',27,30),
	   (6,'2023-11-09',11,301),
	   (7,'2023-11-09',13,190);

GO

INSERT INTO Salary (EmpID,MmSalary,YYSalary)
VALUES (3,11,2023),
	   (4,11,2023),
	   (5,11,2023),
	   (6,11,2023),
	   (7,11,2023);

GO

WITH SumHour
AS
(SELECT DISTINCT EmpID, 
		CAST(SUM(TotalWork) OVER(PARTITION BY EmpID) AS MONEY) AS SumHour
FROM Attendence)
UPDATE Salary
SET SumTotalWork = (SELECT SumHour
					FROM SumHour
					WHERE Salary.EmpID= SumHour.EMPID); 

GO

UPDATE Salary
SET BasicSalary = SumTotalWork*32

GO

WITH SumSub
AS
(SELECT DISTINCT EmpID, 
		SUM(Subscription) OVER(PARTITION BY EmpID) AS SumSub
FROM [Daily sales])
UPDATE Salary
SET SumSubscrip = (SELECT SumSub
					FROM SumSub
					WHERE Salary.EmpID= SumSub.EMPID);

GO

UPDATE Salary
SET BonusSub = SumSubscrip*0.5;

GO

WITH SumDon
AS
(SELECT DISTINCT EmpID, 
		SUM(Donation) OVER(PARTITION BY EmpID) AS SumDon
FROM [Daily sales])
UPDATE Salary
SET SumDonation = (SELECT SumDon
					FROM SumDon
					WHERE Salary.EmpID= SumDon.EMPID);

GO

UPDATE Salary
SET BonusDon = SumDonation*0.05;

GO

UPDATE Salary 
SET TotalSalary = BasicSalary+BonusSub+BonusDon;


--For ease of reading and evaluating the result:

GO

SELECT * FROM Department

SELECT * FROM Employees

SELECT * FROM Attendence

SELECT * FROM [Daily sales]

SELECT * FROM Salary



