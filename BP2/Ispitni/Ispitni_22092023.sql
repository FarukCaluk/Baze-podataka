--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
CREATE DATABASE IB220086
GO
USE IB220086
--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Uposlenici
--• UposlenikID, 9 karaktera fiksne dužine i primarni ključ,
--• Ime, 20 karaktera (obavezan unos),
--• Prezime, 20 karaktera (obavezan unos),
--• DatumZaposlenja, polje za unos datuma i vremena (obavezan unos),
--• OpisPosla, 50 karaktera (obavezan unos)
CREATE TABLE Uposlenici
(
	UposlenikID CHAR(9)CONSTRAINT PK_Uposlenici PRIMARY KEY,
	Ime VARCHAR(20) NOT NULL,
	Prezime VARCHAR(20) NOT NULL,
	DatumZaposlenja DATETIME NOT NULL,
	OpisPosla VARCHAR(50) NOT NULL
)
--b) Naslovi
--• NaslovID, 6 karaktera i primarni ključ,
--• Naslov, 80 karaktera (obavezan unos),
--• Tip, 12 karaktera fiksne dužine (obavezan unos),
--• Cijena, novčani tip podataka,
--• NazivIzdavaca, 40 karaktera,
--• GradIzadavaca, 20 karaktera,
--• DrzavaIzdavaca, 30 karaktera
CREATE TABLE Naslovi
(
	NaslovID VARCHAR(6) CONSTRAINT PK_Naslovi PRIMARY KEY,
	Naslov VARCHAR(80) NOT NULL,
	Tip CHAR(12)NOT NULL,
	Cijena MONEY,
	NazivIzdavaca VARCHAR(40),
	GradIzadavaca VARCHAR(20),
	DrzavaIzdavaca VARCHAR(30)
)
--d) Prodavnice
--• ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ,
--• NazivProdavnice, 40 karaktera,
--• Grad, 40 karaktera
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) CONSTRAINT PK_Prodavnica PRIMARY KEY,
	NazivProdavnice VARCHAR(40),
	Grad VARCHAR(40)
)
--c) Prodaja
--• ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ,
--• BrojNarudzbe, 20 karaktera, primarni ključ,
--• NaslovID, 6 karaktera, strani i primarni ključ,
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos)
CREATE TABLE Prodaja
(
	ProdavnicaID CHAR(4)CONSTRAINT PK_Prodaja_Prodavnica FOREIGN KEY REFERENCES Prodavnice(ProdavnicaID),
	BrojNarudzbe VARCHAR(20),
	NaslovID VARCHAR(6)CONSTRAINT PK_Prodaja_Naslovi FOREIGN KEY REFERENCES Naslovi(NaslovID),
	DatumNarudzbe DATETIME NOT NULL,
	Kolicina SMALLINT NOT NULL,
	CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID,BrojNarudzbe,NaslovID)
)
--6 bodova
--3. Iz baze podataka Pubs u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--• emp_id -> UposlenikID
--• fname -> Ime
--• lname -> Prezime
--• hire_date -> DatumZaposlenja
--• job_desc -> OpisPosla
INSERT INTO Uposlenici(UposlenikID,Ime,Prezime,DatumZaposlenja,OpisPosla)
SELECT
	E.emp_id,
	E.fname,
	E.lname,
	E.hire_date,
	J.job_desc
FROM pubs.dbo.employee AS E
	INNER JOIN pubs.dbo.jobs AS J ON E.job_id = J.job_id
--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka -o- nazivima izdavača
--zamijeniti vrijednost sa nepoznat izdavac
--• title_id -> NaslovID
--• title -> Naslov
--• type -> Tip
--• price -> Cijena
--• pub_name -> NazivIzdavaca
--• city -> GradIzdavaca
--• country -> DrzavaIzdavaca
INSERT INTO Naslovi(NaslovID,Naslov,Tip,Cijena,NazivIzdavaca,GradIzadavaca,DrzavaIzdavaca)
SELECT
	T.title_id,
	T.title,
	T.type,
	T.price,
	ISNULL(P.pub_name,'NEPOZNAT'),
	P.city,
	P.country
FROM pubs.dbo.titles AS T
	INNER JOIN pubs.dbo.publishers AS P ON T.pub_id = P.pub_id 
--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id -> ProdavnicaID
--• store_name -> NazivProdavnice
--• city -> Grad
INSERT INTO Prodavnice(ProdavnicaID,NazivProdavnice,Grad)
SELECT
	S.stor_id,S.stor_name,S.city
FROM pubs.dbo.stores AS S
--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id -> ProdavnicaID
--• order_num -> BrojNarudzbe
--• title_id -> NaslovID
--• ord_date -> DatumNarudzbe
--• qty -> Kolicina
INSERT INTO Prodaja(ProdavnicaID,BrojNarudzbe,NaslovID,DatumNarudzbe,Kolicina)
SELECT
	S.stor_id,
	S.ord_num,
	S.title_id,
	S.ord_date,
	S.qty
FROM pubs.dbo.sales AS S
--22.09.2023.

SELECT  * FROM Prodaja
--6 bodova

--4.
--a) (6 bodova) Kreirati proceduru sp_update_naslov kojom će se uraditi update --podataka u tabelu Naslovi.
--Korisnik može da pošalje jedan ili više parametara i pri tome voditi računa da se -ne- desi gubitak/brisanje
--zapisa. OBAVEZNO kreirati testni slučaj za kreiranu proceduru. (Novokreirana baza)
GO
CREATE PROCEDURE sp_update_naslov
(
	@NaslovID VARCHAR(6),
	@Naslov VARCHAR(80)=  NULL,
	@Tip CHAR(12)= NULL,
	@Cijena MONEY= NULL,
	@NazivIzdavaca VARCHAR(40)= NULL,
	@GradIzadavaca VARCHAR(20)= NULL,
	@DrzavaIzdavaca VARCHAR(30)= NULL
)
AS 
BEGIN
UPDATE Naslovi
SET
	NaslovID=IIF(@NaslovID IS NULL,NaslovID,@NaslovID),
	Naslov=IIF(@Naslov IS NULL,Naslov,@Naslov),
	Tip=IIF(@Tip IS NULL,Tip,@Tip),
	Cijena=IIF(@Cijena IS NULL,Cijena,@Cijena),
	NazivIzdavaca=IIF(@NazivIzdavaca IS NULL,NazivIzdavaca,@NazivIzdavaca),
	GradIzadavaca=IIF(@GradIzadavaca IS NULL,GradIzadavaca,@GradIzadavaca),
	DrzavaIzdavaca=IIF(@DrzavaIzdavaca IS NULL,DrzavaIzdavaca,@DrzavaIzdavaca)
WHERE NaslovID = @NaslovID
END

EXEC sp_update_naslov @NaslovID = TC7777,@Cijena = 32

SELECT * FROM Naslovi
--b) (7 bodova) Kreirati upit kojim će se prikazati ukupna prodana količina i ukupna --zarada bez popusta za
--svaku kategoriju proizvoda pojedinačno. Uslov je da proizvodi ne pripadaju --kategoriji bicikala, da im je
--boja bijela ili crna te da ukupna prodana količina nije veća od 20000. Rezultate --sortirati prema ukupnoj
--zaradi u opadajućem redoslijedu. (AdventureWorks2017)

SELECT
	C.Name AS KATEGORIJA,
	SUM(SOD.OrderQty) KOLICINA,
	SUM(SOD.UnitPrice*SOD.OrderQty)ZARADA
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
	INNER JOIN AdventureWorks2017.Production.Product AS P ON SOD.ProductID = P.ProductID
	INNER JOIN AdventureWorks2017.Production.ProductSubcategory AS SC ON P.ProductSubcategoryID = SC.ProductSubcategoryID
	INNER JOIN AdventureWorks2017.Production.ProductCategory AS C ON SC.ProductCategoryID = C.ProductCategoryID
WHERE C.Name NOT LIKE 'Bikes' AND P.Color IN ('White','Black')	
GROUP BY C.Name
HAVING SUM(SOD.OrderQty)<=20000
ORDER BY SUM(SOD.UnitPrice*SOD.OrderQty) DESC
--c) (8 bodova) Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2013 ili --2014 godine naručili
--proizvod „Front Brakes“ u količini većoj od 5. Upitom prikazati spojeno ime i --prezime kupca, email,
--naručenu količinu i datum narudžbe formatiran na način dan.mjesec.godina --(AdventureWorks2017)


SELECT
	CONCAT(P.FirstName ,' ',P.LastName) AS IME_PREZIME,
	EA.EmailAddress,
	SOD.OrderQty,
	FORMAT(SOH.OrderDate,'	dd.MM.yyyy') AS DATUM_NARUDZBE
FROM AdventureWorks2017.Sales.Customer AS C
	INNER JOIN AdventureWorks2017.Person.Person AS P ON C.PersonID = P.BusinessEntityID
	INNER JOIN AdventureWorks2017.Person.EmailAddress AS EA ON P.BusinessEntityID = EA.BusinessEntityID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
	INNER JOIN AdventureWorks2017.Production.Product AS PR ON SOD.ProductID = PR.ProductID
WHERE MONTH(soh.OrderDate)= 5 AND 
	YEAR(SOH.OrderDate) IN (2013,2014) AND 
	PR.Name LIKE 'Front Brakes' AND 
	SOD.OrderQty>5
	
--d) (10 bodova) Kreirati upit koji će prikazati naziv kompanije dobavljača koja je --dobavila proizvode, koji
--se u najvećoj količini prodaju (najprodavaniji). Uslov je da proizvod pripada --kategoriji morske hrane i
--da je dostavljen/isporučen kupcu. Također uzeti u obzir samo one proizvode na -kojima- je popust odobren.
--U rezultatima upita prikazati naziv kompanije dobavljača i ukupnu prodanu količinu --proizvoda.
--(Northwind)

SELECT TOP 1
	S.CompanyName,
	SUM(OD.Quantity) AS KOLICINA
FROM Northwind.dbo.Suppliers AS S 
	INNER JOIN Northwind.dbo.Products AS P ON S.SupplierID = P.SupplierID
	INNER JOIN Northwind.dbo.[Order Details] AS OD ON P.ProductID = OD.ProductID
	INNER JOIN Northwind.dbo.Categories AS C ON P.CategoryID = C.CategoryID
	INNER JOIN Northwind.dbo.Orders AS O ON OD.OrderID = O.OrderID
WHERE C.CategoryName LIKE '%Sea%' AND O.ShippedDate IS NOT NULL AND OD.Discount > 0
GROUP BY S.CompanyName
ORDER BY 2 DESC
--e) (11 bodova) Kreirati upit kojim će se prikazati narudžbe u kojima je na osnovu --popusta kupac uštedio
--2000KM i više. Upit treba da sadrži identifikacijski broj narudžbe, spojeno ime i --prezime kupca, te
--stvarnu ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Rezultate sortirati po- -ukupnoj vrijednosti
--narudžbe u opadajućem redoslijedu.
-- 43 boda
SELECT
	O.OrderID,
	C.ContactName,
	ROUND(SUM(OD.Quantity*OD.UnitPrice),2) AS STVARNA_VRIJENOST
FROM Northwind.dbo.Orders AS O 
	INNER JOIN Northwind.dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
	INNER JOIN Northwind.dbo.Customers AS C ON O.CustomerID = C.CustomerID
GROUP BY O.OrderID,C.ContactName
HAVING SUM(OD.Quantity*OD.UnitPrice) -SUM(OD.Quantity*OD.UnitPrice)>=2000
--5.
--a) (13 bodova) Kreirati upit koji će prikazati kojom kompanijom (ShipMethod(Name)) --je isporučen najveći
--broj narudžbi, a kojom najveća ukupna količina proizvoda. (AdventureWorks2017)
SELECT * FROM
(
	SELECT TOP 1 
		sm.Name, 
		COUNT(*) BrojNarudzbi
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	GROUP BY sm.Name
	ORDER BY 2 DESC
)AS sq1
UNION
SELECT * FROM
(
	SELECT TOP 1 
		sm.Name, 
		SUM(sod.OrderQty) UkupnaKolicinaProizvoda
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC
)AS sq2
--b) (8 bodova) Modificirati prethodno kreirani upit na način ukoliko je jednom --kompanijom istovremeno
--isporučen najveći broj narudžbi i najveća ukupna količina proizvoda upitom -prikazati- poruku „Jedna
--kompanija“, u suprotnom „Više kompanija“ (AdventureWorks2017)
SELECT 
	IIF(COUNT(sq.Name)<2,'jedna', 'vise')
FROM
(
	SELECT * FROM
	(
	SELECT TOP 1 sm.Name, COUNT(*) BrojNarudzbi
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	GROUP BY sm.Name
	ORDER BY 2 DESC
	)AS sq1
UNION
	SELECT * FROM
	(
	SELECT TOP 1 sm.Name, SUM(sod.OrderQty) UkupnaKolicinaProizvoda
	FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
	INNER JOIN AdventureWorks2017.Purchasing.ShipMethod AS sm
	ON soh.ShipMethodID=sm.ShipMethodID
	INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID=sod.SalesOrderID
	GROUP BY sm.Name
	ORDER BY 2 DESC
	)AS sq2
)AS sq
--c) (4 boda) Kreirati indeks IX_Naslovi_Naslov kojim će se ubrzati pretraga prema --naslovu. OBAVEZNO
--kreirati testni slučaj. (NovokreiranaBaza)
CREATE INDEX IX_Naslovi_Naslov ON Naslovi(Naslov)

SELECT * 
FROM Naslovi
WHERE Naslov LIKE 'B%'
--25 bodova
--6. Dokument teorijski_ispit 22SEP23, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder -Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55
