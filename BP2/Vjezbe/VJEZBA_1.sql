--1.	Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE IB220086
GO
USE IB220086
--2.	U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a)	Proizvodi
--•	ProizvodID, cjelobrojna vrijednost i primarni ključ
--•	Naziv, 40 UNICODE karaktera (obavezan unos)
--•	Cijena, novčani tip (obavezan unos)
--•	KoličinaNaSkladistu, smallint 
--•	NazivKompanijeDobavljaca, 40 UNICODE (obavezan unos)
--•	Raspolozivost, bit (obavezan unos)
CREATE TABLE Proizvodi
(
	ProizvodID INT CONSTRAINT PK_Proizvodi PRIMARY KEY ,
	Naziv NVARCHAR(40) NOT NULL,
	Cijena MONEY NOT NULL,
	KoličinaNaSkladistu SMALLINT,
	NazivKompanijeDobavljaca NVARCHAR(40) NOT NULL,
	Raspolozivost BIT NOT NULL
)
--b)	Narudzbe
--•	NarudzbaID, cjelobrojna vrijednost i primarni ključ,
--•	DatumNarudzbe, polje za unos datuma
--•	DatumPrijema, polje za unos datuma
--•	DatumIsporuke, polje za unos datuma
--•	Drzava, 15 UNICODE znakova
--•	Regija, 15 UNICODE znakova
--•	Grad, 15 UNICODE znakova
--•	Adresa, 60 UNICODE znakova
CREATE TABLE Narudzbe
(
	NarudzbaID INT CONSTRAINT PK_Narudzbe PRIMARY KEY,
	DatumNarudzbe DATETIME,
	DatumPrijema DATETIME,
	DatumIsporuke DATETIME,
	Drzava NVARCHAR(15),
	Regija NVARCHAR(15),
	Grad NVARCHAR(15),
	Adresa NVARCHAR(60)
)
--c)	StavkeNarudzbe
--•	NarudzbaID, cjelobrojna vrijednost, strani ključ
--•	ProizvodID, cjelobrojna vrijednost, strani ključ
--•	Cijena, novčani tip (obavezan unos),
--•	Količina, smallint (obavezan unos),
--•	Popust, real vrijednost (obavezan unos)
CREATE TABLE StavkeNarudzbe
(
	NarudzbaID INT CONSTRAINT FK_StavkeNarudzbe_Narudzbe FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
	ProizvodID INT CONSTRAINT FK_StavkeNarudzbe_Proizvodi FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Cijena MONEY NOT NULL,
	Količina smallint NOT NULL,
	Popust real NOT NULL,
	CONSTRAINT PK_StavkeNarudzbe PRIMARY KEY (NarudzbaID,ProizvodID)
)

--3.	Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a)	U tabelu Proizvodi dodati sve proizvode 
--•	ProductID -> ProizvodID
--•	ProductName -> Naziv 	
--•	UnitPrice -> Cijena 	
--•	UnitsInStock -> KolicinaNaSkladistu
--•	CompanyName -> NazivKompanijeDobavljaca	
--•	Discontinued -> Raspolozivost 	
INSERT INTO Proizvodi(ProizvodID,Naziv,Cijena,KoličinaNaSkladistu,NazivKompanijeDobavljaca,Raspolozivost)
SELECT
	P.ProductID,
	P.ProductName,
	P.UnitPrice,
	P.UnitsInStock,
	S.CompanyName,
	P.Discontinued
FROM Northwind.dbo.Products AS P
	INNER JOIN Northwind.dbo.Suppliers AS S ON P.SupplierID = S.SupplierID
--b)	U tabelu Narudzbe dodati sve narudžbe, na mjestima gdje nema pohranjenih podataka o regiji zamijeniti vrijednost sa nije naznaceno
--•	OrderID -> NarudzbaID
--•	OrderDate -> DatumNarudzbe
--•	RequiredDate -> DatumPrijema
--•	ShippedDate -> DatumIsporuke
--•	ShipCountry -> Drzava
--•	ShipRegion -> Regija
--•	ShipCity -> Grad
--•	ShipAddress -> Adresa
INSERT INTO Narudzbe(NarudzbaID,DatumNarudzbe,DatumPrijema,DatumIsporuke,Drzava,Regija,Grad,Adresa)
SELECT
	O.OrderID,
	O.OrderDate,
	O.RequiredDate,
	O.ShippedDate,
	O.ShipCountry,
	ISNULL(O.ShipRegion,'NIJE NAZNACENO'),
	O.ShipCity,
	O.ShipAddress
FROM Northwind.dbo.Orders AS O 
--c)	U tabelu StavkeNarudzbe dodati sve stavke narudžbe gdje je količina veća od 4
--•	OrderID -> NarudzbaID
--•	ProductID -> ProizvodID
--•	UnitPrice -> Cijena
--•	Quantity -> Količina
--•	Discount -> Popust
INSERT INTO StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Količina,Popust)
SELECT
	O.OrderID,
	O.ProductID,
	O.UnitPrice,
	O.Quantity,
	O.Discount
FROM Northwind.dbo.[Order Details] AS O
--4.	
--a)	Prikazati sve proizvode koji počinju sa slovom a ili c a trenutno nisu raspoloživi.
SELECT	*
FROM IB220086.dbo.Proizvodi AS P
WHERE (P.Naziv LIKE 'a%' OR P.Naziv LIKE 'c%') and P.Raspolozivost = 0
--b)	Prikazati narudžbe koje su kreirane 1996 godine i čija ukupna vrijednost je veća od 500KM.
SELECT	
	N.NarudzbaID,
	SUM(SN.Količina*SN.Cijena) AS KOLICINA
FROM IB220086.dbo.Narudzbe AS N
	INNER JOIN IB220086.dbo.StavkeNarudzbe AS SN ON N.NarudzbaID = SN.NarudzbaID
WHERE YEAR(N.DatumNarudzbe) = 1996
GROUP BY N.NarudzbaID
HAVING SUM(SN.Količina*SN.Cijena)>500
--c)	Prikazati ukupni promet (uzimajući u obzir i popust) od narudžbi po teritorijama. (AdventureWorks2017)
SELECT
	ST.TerritoryID,
	SUM(SOD.LineTotal) AS 'UKUPNI PROMET'
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
	INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
	INNER JOIN AdventureWorks2017.Sales.SalesTerritory AS ST ON SOH.TerritoryID = ST.TerritoryID
GROUP BY ST.TerritoryID
--d)	Napisati upit koji će prebrojati stavke narudžbe za svaku narudžbu pojedinačno. U rezultatima prikazati ID narudžbe i broj stavki, te uzeti u obzir samo one narudžbe čiji je broj stavki veći od 1, te koje su napravljene između 1.6. i 10.6. bilo koje godine. Rezultate prikazati prema ukupnom broju stavki obrnuto abecedno. (AdventureWorks2017)
 SELECT
	SOH.SalesOrderID,
	COUNT(*) AS BROJ_STAVKI
 FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE DAY(SOH.OrderDate) BETWEEN 1 AND 10 AND MONTH(SOH.OrderDate) = 6
GROUP BY SOH.SalesOrderID
HAVING COUNT(*)>1
ORDER BY 2 DESC
--e)	Napisati upit koji će prikazati sljedeće podatke o proizvodima: ID proizvoda, naziv proizvoda, šifru proizvoda, te novokreiranu šifru proizvoda. Nova šifra se sastoji od sljedećih vrijednosti: (AdventureWorks2017)
--•	Svi karakteri nakon prvog znaka - (crtica)
--•	Karakter /
--•	ID proizvoda
--Npr. Za proizvod sa ID-om 716 i šifrom LJ-0192-X, nova šifra će biti 0192-X/716.
SELECT 
    P.ProductID,
    P.Name,
    P.ProductNumber,
    CONCAT(SUBSTRING(P.ProductNumber, CHARINDEX('-', P.ProductNumber) + 1, 1000), '/', P.ProductID) AS NovaSifra
FROM AdventureWorks2017.Production.Product AS P;
--5.	
--a)	Kreirati proceduru sp_search_proizvodi kojom će se u tabeli Proizvodi uraditi pretraga proizvoda prema nazivu prizvoda ili nazivu dobavljača. Pretraga treba da radi i prilikom unosa bilo kojeg od slova, ne samo potpune riječi. Ukoliko korisnik ne unese ništa od navedenog vratiti sve zapise. Proceduru obavezno pokrenuti.(KORISTITI KREIRANU BAZU)
GO
CREATE OR ALTER PROCEDURE sp_search_proizvodi
(
	@Naziv NVARCHAR(40) = NULL,
	@NazivKompanijeDobavljaca NVARCHAR(40) = NULL
)
AS
BEGIN
SELECT *
FROM IB220086.dbo.Proizvodi AS P
WHERE (P.Naziv LIKE @Naziv +'%' OR @Naziv IS NULL) AND (P.NazivKompanijeDobavljaca LIKE @NazivKompanijeDobavljaca + '%' OR @NazivKompanijeDobavljaca IS NULL)
END 
GO

EXEC sp_search_proizvodi @Naziv = 'C' 
EXEC sp_search_proizvodi @NazivKompanijeDobavljaca = 'A'
--b)	Kreirati proceduru sp_insert_stavkeNarudzbe koje će vršiti insert nove stavke narudžbe u tabelu stavkeNarudzbe. Proceduru obavezno pokrenuti.
GO
CREATE OR ALTER PROCEDURE sp_insert_stavkeNarudzbe
(
	@NarudzbaID INT ,
	@ProizvodID INT ,
	@Cijena MONEY,
	@Količina smallint,
	@Popust real
)
AS
BEGIN 
INSERT INTO IB220086.dbo.StavkeNarudzbe
VALUES(@NarudzbaID,@ProizvodID,@Cijena,@Količina,@Popust)
END 
GO

EXEC sp_insert_stavkeNarudzbe 10248,51,55,69,0.420

SELECT * 
FROM IB220086.dbo.StavkeNarudzbe AS S
WHERE S.ProizvodID = 51
--c)	Kreirati view koji prikazuje sljedeće kolone: ID narudžbe, datum narudžbe, spojeno ime i prezime kupca i ukupnu vrijednost narudžbe. Podatke sortirati prema ukupnoj vrijednosti u opadajućem redoslijedu. (AdventureWorks2017)
GO
CREATE OR ALTER VIEW V_5C
AS
SELECT	
	SOH.SalesOrderID,
	SOH.OrderDate,
	CONCAT(P.FirstName,' ',P.LastName) AS IME_PREZIME,
	SUM(SOD.OrderQty * SOD.UnitPrice) AS UKUPNA_VRIJEDNOST
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH 
	INNER JOIN AdventureWorks2017.Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER JOIN AdventureWorks2017.Person.Person AS P ON C.PersonID = P.BusinessEntityID
GROUP BY SOH.SalesOrderID,SOH.OrderDate,CONCAT(P.FirstName,' ',P.LastName)
GO

SELECT *
FROM V_5C AS V
ORDER BY V.UKUPNA_VRIJEDNOST DESC
--d)	Kreirati okidač kojim će se onemogućiti brisanje zapisa iz tabele StavkeNarudzbe. Korisnicima je potrebno ispisati poruku Arhivske zapise nije moguće izbrisati.
USE IB220086

GO
CREATE OR ALTER TRIGGER T_5D
ON StavkeNarudzbe
INSTEAD OF DELETE
AS 
BEGIN
SELECT('Arhivske zapise nije moguće izbrisati.')
END 
GO

DELETE StavkeNarudzbe
WHERE ProizvodID = 1
--e)	Kreirati index kojim će se ubrzati pretraga po nazivu proizvoda.
CREATE INDEX IX_IMEPROIZVODA
ON Proizvodi(Naziv)

SELECT*
FROM Proizvodi
WHERE Naziv LIKE 'M%'
--f)	U tabeli StavkeNarudzbe kreirati polje ModifiedDate u kojem će se nakon kreiranja okidača za izmjenu podataka spremati datum modifikacije podataka za konkretan red na kojem je izvršena modifikacija. 

ALTER TABLE StavkeNarudzbe
ADD ModifiedDate DATE

GO 
CREATE OR ALTER TRIGGER T5_F
ON StavkeNarudzbe
AFTER UPDATE 
AS
BEGIN 
UPDATE StavkeNarudzbe
SET ModifiedDate = GETDATE()
WHERE NarudzbaID IN 
(
	SELECT	DISTINCT NarudzbaID
	FROM inserted
) 
AND ProizvodID IN
(
	SELECT	DISTINCT ProizvodID
	FROM inserted
)
END
GO

UPDATE StavkeNarudzbe
SET Cijena = 8000
WHERE ProizvodID = 51 AND NarudzbaID = 10248

SELECT*
FROM StavkeNarudzbe
WHERE ProizvodID = 51 AND NarudzbaID = 10248