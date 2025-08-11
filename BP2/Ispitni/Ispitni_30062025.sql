--(ADVENTUREWORKS)
USE AdventureWorks2017
GO
--2.a--Prikazati sve narudzbe iz 2011. godine koje sadrže tacno jedan proizvod.
--Zaglavlje (kolone): ID narudžbe
SELECT SOH.SalesOrderID
FROM Sales.SalesOrderHeader AS SOH
	INNER JOIN Sales.SalesOrderDetail AS OD ON SOH.SalesOrderID = OD.SalesOrderID
WHERE YEAR(SOH.OrderDate) = 2011
GROUP BY SOH.SalesOrderID
HAVING COUNT(OD.ProductID) = 1

--2.b--Prikazati ukupni prihod (kolicina * cijena) i broj narudzbi po kupcu i godini kupovine.
--Zaglavlje: Kupac, Godina kupovine, Prihodi, Broj narudzbi
SELECT
	C.CustomerID,
	YEAR(SOH.OrderDate) AS 'GODINA KUPOVINE',
	SUM(SOD.OrderQty * SOD.UnitPrice) AS PRIHODI,
	COUNT(SOH.SalesOrderID) AS 'BROJ NARUDZBI'
FROM Sales.SalesOrderDetail AS SOD
	INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
	INNER JOIN Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
GROUP BY C.CustomerID,YEAR(SOH.OrderDate)
--2.c Prikazati sve proizvode koji nikada nisu naruceni, imaju cijenu vecu od 100 i nalaze se na skladištu u kolicini vecoj od  800 komada. Rezultate sortirati po cijeni u opadajucem redosljedu
--Zaglavlje: Naziv proizvoda, Cijena, Kolicina.
SELECT
	P.Name AS PROIZVOD,
	P.ListPrice AS CIJENA,
	SUM(PI.Quantity) AS KOLICINA
FROM AdventureWorks2017.Production.Product AS P 
	INNER JOIN Production.ProductInventory AS PI ON P.ProductID = PI.ProductID
WHERE P.ListPrice > 100 AND P.ProductID NOT IN
(
	SELECT SOD.ProductID
	FROM Sales.SalesOrderDetail AS SOD
)
GROUP BY P.Name,P.ListPrice
HAVING SUM(PI.Quantity) > 800
ORDER BY 2 DESC
--(NORTHWIND)
USE Northwind
GO
--3.a Prikazati drzavu iz koje su narudzbe isporucene najbrze(najmanje prosjecno vrijeme isporuke).
--Zaglavlje: Država, Prosjecan broj dana.
SELECT TOP 1
	O.ShipCountry,
	AVG(DATEDIFF(DAY,O.OrderDate,O.ShippedDate)) AS 'BROJ DANA'
FROM Orders AS O
GROUP BY O.ShipCountry
ORDER BY 2 ASC
--3.b Prikazati kupce cije su sve narudzbe isporucene u roku kracem od 5 dana.
--Zaglavlje: Naziv kompanije kupca
SELECT C.CompanyName
FROM Customers AS C
WHERE NOT EXISTS
(
	SELECT 1
	FROM Orders AS O
	WHERE O.CustomerID = C.CustomerID AND
	DATEDIFF(YEAR,O.OrderDate,O.ShippedDate) >=5
)

--3.c Prikazati kupce koji su narucili samo jednom, i to proizvode kojih ima na stanju u kolicini manjoj od 20.
--Zaglavlje: Naziv kompanije kupca
SELECT C.CompanyName
FROM Customers AS C
	INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
	INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
	INNER JOIN Products AS P ON OD.ProductID = P.ProductID
WHERE P.UnitsInStock < 20
GROUP BY C.CompanyName
HAVING COUNT(O.OrderID) = 1
--ILI OVOO
SELECT C.CompanyName
FROM Customers AS C
	INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
	INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
	INNER JOIN Products AS P ON OD.ProductID = P.ProductID
GROUP BY C.CompanyName
HAVING MAX(P.UnitsInStock) < 20 AND COUNT(O.OrderID) = 1
--4.a)(PUBS) Prikazati naslove koji se nisu prodali nijednom u trgovinama koje su prodale vise od 5 razlicitih naslova.
USE pubs
GO
-- Zaglavlje: Naslov knjige
SELECT	T.title
FROM titles AS T
WHERE NOT EXISTS
(
	SELECT 1
	FROM sales AS S
	WHERE S.title_id = T.title_id
	AND S.stor_id IN
	(
		SELECT SL.stor_id
		FROM sales AS SL
		GROUP BY stor_id
		HAVING COUNT(DISTINCT SL.title_id) > 5
	)
)

--4.b) Prikazati naslove koji su se prodali isključivo u onim godinama u kojima ukupna prodaja svih naslova nije prelazila 80 primjeraka.
--Zaglavlja: title(naslov knjige)
SELECT DISTINCT T.title
FROM titles AS T
WHERE T.title_id IN 
(
	SELECT T.title_id
	FROM sales AS T
) AND T.title_id NOT IN
(
	SELECT T.title_id
	FROM titles AS T
		INNER JOIN sales AS S ON T.title_id = S.title_id
	WHERE YEAR(S.ord_date) IN
	(
		SELECT YEAR(S.ord_date)
		FROM sales AS  S
		GROUP BY YEAR(S.ord_date)
		HAVING SUM(S.qty) > 80
	)
)

--5. U kreiranoj bazi podataka kreirati tabele sa sljedećom stukturom:
create database BrojIndeksa
use BrojIndeksa
--5.1 
--a) Uposlenici
create table Uposlenici
(
	UposlenikID int primary key identity(1,1),
	Ime nvarchar(10) not null,
	Prezime nvarchar(20) not null,
	DatumRodjenja datetime not null,
	UkupanBrojTeritorija int
)
--b) Narudzbe
create table Narudzbe
(
	NarudzbaID int primary key identity(1,1),
	UposlenikID int foreign key references Uposlenici(UposlenikID),
	DisavljaciID int foreign key references Dostavljaci(DostavljacID),
	DatumNarudzbe datetime,
	ImeKompanijeKupca nvarchar(40),
	AdresaKupca nvarchar(60),
	UkupnaVrijednostNarudzbeSaPopustom decimal(18,2),
	UkupnaVrijednostNarudzbeBezPopusta money
)
--c) Dostavljaci
create table Dostavljaci
(
	DostavljacID int primary key identity(1,1),
	NazivKompanijeDostavljaca nvarchar(40) not null,
	Telefon nvarchar(24)
)
--5.2 Kopiranje podataka
SET  IDENTITY_INSERT Uposlenici ON
INSERT INTO Uposlenici
(
	UposlenikID,
	Ime,
	Prezime,
	DatumRodjenja,
	UkupanBrojTeritorija
)
SELECT E.EmployeeID,E.FirstName,E.LastName,E.BirthDate,COUNT(ET.TerritoryID)
FROM Northwind.dbo.Employees AS E
	INNER JOIN Northwind.dbo.EmployeeTerritories AS ET ON E.EmployeeID = ET.EmployeeID
GROUP BY E.EmployeeID,E.FirstName,E.LastName,E.BirthDate
SET  IDENTITY_INSERT Uposlenici OFF
--b) Narudzbe
SET  IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe
(
	NarudzbaID,
	UposlenikID,
	DisavljaciID,
	DatumNarudzbe,
	ImeKompanijeKupca,
	AdresaKupca,
	UkupnaVrijednostNarudzbeSaPopustom,
	UkupnaVrijednostNarudzbeBezPopusta
)
SELECT O.OrderID,O.EmployeeID,S.ShipperID,O.OrderDate,C.CompanyName,C.Address,SUM(OD.Quantity* OD.UnitPrice *(1- OD.Discount)),SUM(OD.Quantity* OD.UnitPrice)
FROM Northwind.dbo.Orders AS O
	INNER JOIN Northwind.dbo.Shippers AS S ON O.ShipVia = S.ShipperID
	INNER JOIN Northwind.dbo.Customers AS C ON O.CustomerID = C.CustomerID
	INNER JOIN Northwind.dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID,O.EmployeeID,S.ShipperID,O.OrderDate,C.CompanyName,C.Address
SET  IDENTITY_INSERT Narudzbe OFF
--DOSTAVLJAC
SET  IDENTITY_INSERT Dostavljaci ON
INSERT INTO Dostavljaci
(
	DostavljacID,
	NazivKompanijeDostavljaca,
	Telefon
)
SELECT S.ShipperID,S.CompanyName,S.Phone
FROM Northwind.dbo.Shippers AS S
GROUP BY S.ShipperID,S.CompanyName,S.Phone
SET  IDENTITY_INSERT Dostavljaci OFF
--5.a) Kreirati proceduru sp_Dostavljaci_insert kojom ce se izvrsiti insertovanje podataka unutar tabele dostavljaci.Obavezno kreirati testni slucaj.
go
CREATE OR ALTER PROCEDURE sp_Dostavljac_insert
(
	@NazivKompanijeDostavljaca nvarchar(40),
	@Telefon nvarchar(24)
)
as 
begin
	insert into Dostavljaci(NazivKompanijeDostavljaca,Telefon)
	values(@NazivKompanijeDostavljaca,@Telefon)
end
go

exec sp_Dostavljac_insert 'EKE TOO BRUDAA','060 307 43 26'

SELECT * FROM Dostavljaci
--5.b) Kreirati okidač kojim će se nakon izmjene zapisa u tabeli dosavljači pohraniti prepisani podaci
--(podaci koji su bili pohranjeni) u log tabelu. U log tabelu sačuvati id dostavljača, ime kompanije i telefon
create table LogDostavljaci
(
	logID int primary key identity(1,1),
	DostavljacID int,
	NazivKompanijeDostavljaca nvarchar(40),
	Telefon nvarchar(24)
)
GO
CREATE OR ALTER TRIGGER  TRGDostavljac
ON Dostavljaci
AFTER UPDATE
AS
BEGIN
	INSERT INTO LogDostavljaci(DostavljacID,NazivKompanijeDostavljaca,Telefon)
	SELECT D.DostavljacID,
			D.NazivKompanijeDostavljaca,
			D.Telefon
	FROM deleted D
END
GO
--5.c) Kreirati tabelarnu funkciju f_53c koja prima dva parametra: uposlenikID i maksimalna vrijednost. Zadatak funkcije jeste da vrati sve narudzbe koje je obradio
--navedeni uposlenik uz uslov da je ukupna vrijednost narudzbe sa popustom manja od zadane vrijednosti.
GO
CREATE FUNCTION F_53C
(
	@uposlenikID int,
	@maxVrijednost decimal(18,2)
)
RETURNS TABLE 
AS RETURN 
	SELECT	N.NarudzbaID
	FROM Narudzbe AS N
	WHERE N.UkupnaVrijednostNarudzbeSaPopustom < @maxVrijednost
GO
