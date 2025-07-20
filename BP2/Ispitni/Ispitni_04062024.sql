--1.	Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
go
create database IB565656
go
use IB565656

--2.	Kreirati tabelu Kupci, te prilikom kreiranja uraditi insert podataka iz tabele Customers baze Northwind.
SELECT * 
INTO Kupci
FROM Northwind.dbo.Customers

--3.	(3 boda) Kreirati proceduru sp_insert_customers kojom će se izvršiti insert podataka u tabelu Kupci. OBAVEZNO kreirati testni slučaj.


GO
CREATE OR ALTER PROCEDURE sp_insert_customers
(
	@CustomerID NCHAR(5),
	@CompanyName NVARCHAR(40),
	@ContactName NVARCHAR(30) = NULL,
	@ContactTitle NVARCHAR(30) = NULL,
	@Address NVARCHAR(60) = NULL,
	@City NVARCHAR(15) = NULL,
	@Region NVARCHAR(15) = NULL,
	@PostalCode NVARCHAR(10) = NULL,
	@Country NVARCHAR(15) = NULL,
	@Phone NVARCHAR(24) = NULL,
	@Fax NVARCHAR(24) = NULL
)
as begin
insert into Kupci
(
	CustomerID,
	CompanyName,
	ContactName,
	ContactTitle,
	Address,
	City,
	Region,
	PostalCode,
	Country,
	Phone,
	Fax
)
VALUES
(
	@CustomerID,
	@CompanyName,
	@ContactName,
	@ContactTitle,
	@Address,
	@City,
	@Region,
	@PostalCode,
	@Country,
	@Phone,
	@Fax
)
END 
GO

EXEC sp_insert_customers 'SDFGS','SDA MDMA AAA'
select * from Kupci
--4.	(3 boda) Kreirati index koji je ubrzati pretragu po nazivu kompanije kupca i kontakt imenu. OBAVEZNO kreirati testni slučaj.
GO
CREATE INDEX IND_KUPCI
on Kupci(CompanyName,ContactName)
GO

SELECT *
FROM Kupci AS K
WHERE K.CompanyName LIKE '%P%' AND K.ContactName LIKE 'A%1%'

DROP INDEX IND_KUPCI ON Kupci
--5.	(5 boda) Kreirati funkciju f_satnice unutar novokreirane baze koja će vraćati podatke u vidu tabele iz baze AdventureWorks2017. Korisniku slanjem parametra satnica će biti ispisani uposlenici (ime, prezime, starost, staž i email) čija je satnica manja od vrijednosti poslanog parametra. Korisniku pored navedenih podataka treba prikazati razliku unesene i stvarne satnice.
GO
CREATE OR ALTER FUNCTION f_satnica
(
	@satnica MONEY 
)
RETURNS TABLE
AS RETURN 
SELECT 
	P.FirstName,
	P.LastName,
	DATEDIFF(YEAR,E.HireDate,GETDATE()) AS STAZ,
	EA.EmailAddress,
	(@satnica - EP.Rate) AS RAZLIKA,
	EP.Rate AS SATNICA
FROM AdventureWorks2017.HumanResources.Employee AS E
	INNER JOIN AdventureWorks2017.HumanResources.EmployeePayHistory AS EP ON E.BusinessEntityID = E.BusinessEntityID
	INNER JOIN AdventureWorks2017.Person.Person AS P ON E.BusinessEntityID = P.BusinessEntityID
	INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA ON E.BusinessEntityID = EA.BusinessEntityID
WHERE EP.Rate < @satnica
GO
SELECT * FROM f_satnica(10)
ORDER BY 5 ASC
--6.	(6 boda) Prikazati ime i prezime kupaca čiji je ukupan iznos potrošnje(ukupna vrijednost sa troškovima prevoza i taksom) veći od prosječnog ukupnog iznosa potrošnje svih kupaca. U obzir uzeti samo narudžbe koje su isporučene kupcima. (AdventureWorks2019)
GO 
USE AdventureWorks2017 

SELECT P.FirstName,P.LastName,SUM(SOH.TotalDue) AS 'UKUPNA POTROSNJA'
FROM Sales.Customer AS C
	INNER JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
	INNER JOIN Person.Person as p on p.BusinessEntityID = c.PersonID
WHERE SOH.ShipDate IS NOT NULL
GROUP BY P.FirstName,P.LastName
HAVING SUM(SOH.TotalDue) >
(
	SELECT AVG(SOH.TotalDue) AS PROSJEK
	FROM Sales.SalesOrderHeader AS SOH
)
ORDER BY 3 ASC
	--7.	(6 bodova) Prikazati prosječnu vrijednost od svih kreiranih narudžbi bez popusta (jedno polje) (AdventureWorks2019)
SELECT
	AVG(SOH.SubTotal) AS PROSJEK
FROM Sales.SalesOrderHeader AS SOH
WHERE NOT EXISTS
(
	SELECT 1
	FROM Sales.SalesOrderDetail AS SOD
	WHERE SOD.SalesOrderID = SOH.SalesOrderID AND SOD.UnitPriceDiscount > 0
)
--8.	(9 bodova) Prikazati naziv odjela na kojima trenutno radi najmanje, te naziv odjela na kojem radi najviše uposlenika starijih od 50 godina. Dodatni uslov je da odjeli pripadaju grupama proizvodnje, te prodaje i marketinga. (Adventureworks 2019)
SELECT *
FROM(
	SELECT TOP 1 D.Name AS 'NAJVISI'
	FROM HumanResources.Department AS D
		INNER JOIN HumanResources.EmployeeDepartmentHistory AS ED ON D.DepartmentID = ed.DepartmentID
		inner join HumanResources.Employee as E on ED.BusinessEntityID = E.BusinessEntityID
	WHERE 
		DATEDIFF(YEAR,E.BirthDate,GETDATE()) > 50 AND
		D.GroupName IN ('Manufacturing','Sales and Marketing')
	GROUP BY D.Name
	ORDER BY COUNT(*)DESC
)AS SBQ1
UNION ALL
SELECT *
FROM(
	SELECT TOP 1 D.Name AS 'NAJMANJI'
	FROM HumanResources.Department AS D
		INNER JOIN HumanResources.EmployeeDepartmentHistory AS ED ON D.DepartmentID = ed.DepartmentID
		inner join HumanResources.Employee as E on ED.BusinessEntityID = E.BusinessEntityID
	WHERE 
		DATEDIFF(YEAR,E.BirthDate,GETDATE()) > 50 AND
		D.GroupName IN ('Manufacturing','Sales and Marketing')
	GROUP BY D.Name
	ORDER BY COUNT(*)ASC
)AS SBQ2
--9.	(8 bodova) Prikazati najprodavaniji proizvod za svaku godinu pojedinačno. Ulogu najprodavanijeg proizvoda ima onaj koji je u najvećoj količini prodat.(Northwind)
USE Northwind
GO

SELECT 
 SQ.GODINA,
 SQ.ProductName
FROM
(
	SELECT
		P.ProductName,
		YEAR(O.OrderDate) AS GODINA,
		SUM(OD.Quantity) AS KOLICINA,
		ROW_NUMBER() OVER(PARTITION BY YEAR(O.OrderDate) ORDER BY SUM(OD.Quantity) DESC) AS RN
	FROM Products AS P 
		INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
		INNER JOIN Orders AS O ON OD.OrderID = O.OrderID
	GROUP BY P.ProductName,YEAR(O.OrderDate)
)AS SQ
WHERE SQ.RN = 1

--10.	(8 bodova) Prikazati ukupan broj narudžbi i ukupnu količinu proizvoda za svaku od teritorija pojedinačno. Uslov je da je ukupna količina manja od 30000 a popust nije odobren za te stavke, te ukupan broj narudžbi 1000 i više. (Adventureworks 2019)
 USE AdventureWorks2017
 GO
 
 SELECT
	ST.TerritoryID,
	COUNT(DISTINCT SOH.SalesOrderID) AS 'BROJ NARUDZBI',
	SUM(OD.OrderQty) AS 'UKUPNA KOLICINA NARUDZBI'
 FROM Sales.SalesOrderHeader AS SOH
	INNER JOIN Sales.SalesOrderDetail AS OD ON SOH.SalesOrderID = OD.SalesOrderID
	INNER JOIN Sales.SalesTerritory AS ST ON SOH.TerritoryID = ST.TerritoryID
WHERE OD.UnitPriceDiscount = 0
GROUP BY ST.TerritoryID
HAVING COUNT(DISTINCT SOH.SalesOrderID) >=1000 AND SUM(OD.OrderQty) < 30000
ORDER BY 1 ASC

