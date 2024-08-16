USE AdventureWorks2022

--EXERCISE 1
GO

SELECT ProductID, Name, Color, ListPrice, Size
FROM Production.Product 
WHERE ProductID NOT IN (SELECT DISTINCT ProductID
						FROM Sales.SalesOrderDetail)
ORDER BY ProductID;

--EXERCISE 2
GO

WITH Customer
AS
(
SELECT C.CustomerID, P.FirstName, P.LastName
	FROM Person.Person P RIGHT JOIN Sales.Customer C
	ON P.BusinessEntityID = C.CustomerID
	WHERE C.PersonID IS NULL
)
SELECT DISTINCT CustomerID, 
				ISNULL(LastName, 'Unknown') AS LastName, 
				ISNULL(FirstName, 'Unknown') AS FirstName 
FROM Customer
ORDER BY CustomerID;

--EXERCISE 3
GO

WITH Customer
AS
(
SELECT C.CustomerID, P.FirstName, P.LastName
	FROM Person.Person P JOIN Sales.Customer C
	ON P.BusinessEntityID = C.PersonID
),
Cus_Ord
AS
(
SELECT DISTINCT CustomerID, 
	COUNT(SalesOrderID) OVER (PARTITION BY CustomerID) AS CountOfOrders
	FROM Sales.SalesOrderHeader
)
SELECT TOP 10 C.CustomerID, C.FirstName, C.LastName, O.CountOfOrders
FROM Customer C JOIN Cus_Ord O
ON C.CustomerID = O.CustomerID
ORDER BY O.CountOfOrders DESC;


--EXERCISE 4
GO

SELECT P.FirstName, P.LastName,
	   E.JobTitle, E.HireDate, 
	   COUNT(*) OVER (PARTITION BY E.JobTitle) AS CountOfTitle
FROM HumanResources.Employee E JOIN Person.Person P
ON E.BusinessEntityID = P.BusinessEntityID;

--EXERCISE 5
/*בשאלה זו נתקלתי ב-2 בעיות שלא היה לי מענה עבורם
א. מספר השורות שעלו בשאילתה לא תאמו למספר השורות בתוצאה. במקרה זה אני חושבת שמדובר בשינויי דאטה 
היות ומספר הלקוחות הכולל הוא 19820, ומספר הלקוחות שלא בצעו הזמנה כלל הוא 701, מה שמצביע על כך שמספר השורות בתוצאות השאילתה שלי נכונות
ב. לא היה כלל מידע הגיוני לגבי מיון התשובה. מסיבה זו הצגתי 2 דרכים, אחת מביעה את הפתרון, השניה מביאה אותו לאותה תצוגה כמו בתוצאות
תודה
*/
--הדרך המציגה את הפתרון הפשוט ללא מיון
GO

WITH Cus
AS
(
SELECT S.CustomerID, P.LastName,P.FirstName
	FROM Person.Person P RIGHT JOIN Sales.Customer S
	ON P.BusinessEntityID = S.PersonID
),
OrderInfo
AS
(
SELECT CustomerID, SalesOrderID, OrderDate,
			LAG(OrderDate,1) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrder,
			ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS Row_Num
	FROM Sales.SalesOrderHeader
),
L_Order
AS
(
SELECT CustomerID, SalesOrderID, OrderDate, PreviousOrder 
	FROM OrderInfo
	WHERE Row_Num = 1
)
SELECT L.SalesOrderID, L.CustomerID, C.LastName, C.FirstName, L.OrderDate AS LastOrder, L.PreviousOrder
FROM Cus C JOIN L_Order L
ON C.CustomerID = L.CustomerID
ORDER BY CustomerID;

--תוספת על מנת לתת את אותו מיון כמו בתוצאות שהוצגו לנו
GO

WITH Cus
AS
(
SELECT S.CustomerID, P.LastName,P.FirstName
	FROM Person.Person P RIGHT JOIN Sales.Customer S
	ON P.BusinessEntityID = S.PersonID
),
OrderInfo
AS
(
SELECT CustomerID, SalesOrderID, OrderDate,
			LAG(OrderDate,1) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS PreviousOrder,
			ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS Row_Num
	FROM Sales.SalesOrderHeader
),
L_Order
AS
(
SELECT CustomerID, SalesOrderID, OrderDate, PreviousOrder 
	FROM OrderInfo
	WHERE Row_Num = 1
),
TBL1
AS
(
SELECT L.SalesOrderID, L.CustomerID, C.LastName, C.FirstName, L.OrderDate AS LastOrder, L.PreviousOrder
	FROM Cus C JOIN L_Order L
	ON C.CustomerID = L.CustomerID
	ORDER BY CustomerID
	OFFSET 18484 ROWS
),
TBL2
AS
(
SELECT L.SalesOrderID, L.CustomerID, C.LastName, C.FirstName, L.OrderDate AS LastOrder, L.PreviousOrder
	FROM Cus C JOIN L_Order L
	ON C.CustomerID = L.CustomerID
	WHERE C.CustomerID < 29484
)
SELECT *
FROM TBL1
UNION ALL
SELECT *
FROM TBL2;

--EXERCISE 6
GO

WITH Total
AS
(
SELECT SalesOrderID, SUM(UnitPrice*(1- UnitPriceDiscount)*OrderQty) AS Total
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
),
OrderInfo
AS
(
SELECT S.SalesOrderID, YEAR(S.DueDate) AS Year, S.CustomerID, T.Total
	FROM Sales.SalesOrderHeader S JOIN Total T
	ON S.SalesOrderID = T.SalesOrderID
),
Max_Total
AS
(
SELECT Year, MAX(Total) AS Total
	FROM OrderInfo
	GROUP BY Year
),
Customer
AS
(
SELECT  P.FirstName, P.LastName, C.CustomerID
	FROM Person.Person P JOIN Sales.Customer C
	ON P.BusinessEntityID = C.PersonID
)
SELECT O.Year, O.SalesOrderID, C.LastName, C.FirstName ,ROUND(M.Total,1) AS Total
FROM Customer C JOIN OrderInfo O  
ON C.CustomerID = O.CustomerID
JOIN Max_Total M
ON O.Year = M.Year
WHERE O.Total = M.Total; 

--EXERCISE 7
GO

SELECT Month,[2011],[2012],[2013],[2014]
FROM (SELECT SalesOrderID , YEAR(orderdate) AS YY, MONTH(orderdate) AS Month
	  FROM Sales.SalesOrderHeader) AS tbl
PIVOT (COUNT(SalesOrderID) FOR YY IN ([2011],[2012],[2013],[2014])) PVT
ORDER BY Month;

--EXERCISE 8
GO

WITH Sum_Total
AS
(
SELECT DISTINCT YEAR(OrderDate) AS Year, CAST(MONTH(OrderDate) AS VARCHAR(12)) AS Month,
		SUM(TotalDue) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) AS Sum_Price,
		SUM(TotalDue) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) AS CumSum
FROM Sales.SalesOrderHeader
UNION ALL
SELECT DISTINCT YEAR(OrderDate) AS Year, 'grand_total' AS Month, NULL AS Sum_Price, SUM(TotalDue) OVER (PARTITION BY YEAR(OrderDate)) AS CumSum
FROM Sales.SalesOrderHeader
)
SELECT *
FROM Sum_Total
ORDER BY Year, CumSum, Month;

--EXERCISE 9
GO

WITH DEP
AS
(
SELECT DE.BusinessEntityID AS [Employee'sID], D.Name AS DepartmentName
	FROM HumanResources.EmployeeDepartmentHistory DE JOIN HumanResources.Department D
	ON DE.DepartmentID = D.DepartmentID
),
EMP
AS
(
SELECT P.BusinessEntityID, P.FirstName +' '+ P.LastName AS [Employee'sFullName], E.HireDate
	FROM HumanResources.Employee E JOIN Person.Person P
	ON E.BusinessEntityID = P.BusinessEntityID
)
SELECT D.DepartmentName, D.[Employee'sID], E.[Employee'sFullName], E.HireDate,
	   DATEDIFF(MM,E.HireDate,GETDATE()) AS Seniority,
	   LAG(E.[Employee'sFullName],1) OVER (PARTITION BY D.DepartmentName ORDER BY E.HireDate) AS PreviuseEmpName,
	   LAG(E.HireDate,1) OVER (PARTITION BY D.DepartmentName ORDER BY E.HireDate) AS PreviuseEmpHDate,
	   DATEDIFF(DD,LAG(E.HireDate,1) OVER (PARTITION BY D.DepartmentName ORDER BY E.HireDate),E.HireDate) AS DiffDays
FROM DEP D JOIN EMP E
ON D.[Employee'sID] = E.BusinessEntityID
ORDER BY D.DepartmentName, E.HireDate DESC;

--EXERCISE 10
GO

WITH EmpInfo
AS
(
SELECT CAST(P.BusinessEntityID AS VARCHAR(8))+' '+P.FirstName+' '+P.LastName AS FullName, E.DepartmentID, E.BusinessEntityID
		FROM Person.Person P JOIN HumanResources.EmployeeDepartmentHistory E
		ON P.BusinessEntityID = E.BusinessEntityID
		WHERE E.EndDate IS NULL
) 
SELECT E.HireDate, I.DepartmentID, STRING_AGG(I.FullName, ',') AS TeamEmployees 
FROM HumanResources.Employee E JOIN EmpInfo I
ON E.BusinessEntityID= I.BusinessEntityID
GROUP BY E.HireDate, I.DepartmentID
ORDER BY E.HireDate DESC;

