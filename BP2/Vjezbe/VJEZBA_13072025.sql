-- BP2 :: Priprema 
USE AdventureWorks2017
GO
-- 2a)
-- a)	(6 bodova) Prikazati ukupnu vrijednost narud�bi za svakog kupca pojedina?no. Upitom prikazati ime i prezime kupca te ukupnu vrijednost narud�bi sa i bez popusta.
-- Zaglavlje (kolone): Ime i prezime, Vrijednost bez popusta (koli?ina * cijena), Vrijednost sa popustom.
SELECT	
	P.FirstName,
	P.LastName,
	SUM(OD.OrderQty*OD.UnitPrice*(1-OD.UnitPriceDiscount)) AS 'VRIJEDNOST SA POTPUSTOM',
	SUM(OD.OrderQty*OD.UnitPrice) AS 'VRIJEDNOST BEZ POPUSTA'
FROM Sales.SalesOrderDetail AS OD
	INNER JOIN Sales.SalesOrderHeader AS SOH ON OD.SalesOrderID = SOH.SalesOrderID
	INNER JOIN Sales.Customer AS C ON SOH.CustomerID = C.CustomerID
	INNER JOIN Person.Person AS P ON C.PersonID = P.BusinessEntityID
GROUP BY 	P.FirstName,P.LastName
-- 2b)
-- b)	(6 bodova) Prikazati 5 proizvoda od kojih je ostvaren najve?i profit (zarada) i 5 s najmanjim profitom. Zaglavlje: Ime proizvoda, Zarada.
SELECT * FROM
(
	SELECT TOP 5
		P.Name AS PROIZVOD,
		CAST(SUM(OD.LineTotal)AS decimal(18,2)) AS ZARADA
	FROM Production.Product AS P
		INNER JOIN Sales.SalesOrderDetail AS OD ON P.ProductID = OD.ProductID
	GROUP BY P.Name
	ORDER BY 2 ASC
)AS SQ1
UNION ALL
SELECT * FROM
(
	SELECT TOP 5
		P.Name AS PROIZVOD,
		CAST(SUM(OD.LineTotal)AS decimal(18,2)) AS ZARADA
	FROM Production.Product AS P
		INNER JOIN Sales.SalesOrderDetail AS OD ON P.ProductID = OD.ProductID
	GROUP BY P.Name
	ORDER BY 2 DESC
)AS SQ2
-- 3a)
-- a)	(7 bodova) Prikazati kupce koji su u sklopu jedne narud�be naru?ili proizvode iz ta?no tri kategorije. (Northwind)
USE Northwind
GO
--Zaglavlje: ContactName.
SELECT DISTINCT C.ContactName
FROM Customers AS C
	INNER JOIN Orders AS O ON O.CustomerID = C.CustomerID
	INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
	INNER JOIN Products AS P ON OD.ProductID = P.ProductID
GROUP BY C.ContactName,O.OrderID
HAVING COUNT(DISTINCT P.CategoryID) = 3

-- 3b)
-- b)	(7 bodova) Prikazati zaposlenike koji su obradili vi�e narud�bi od zaposlenika koji ima najmanje narud�bi u njihovoj regiji (kolona Region). (Northwind) 
-- Zaglavlje: Ime i prezime.
SELECT	CONCAT(E.FirstName,' ',E.LastName) AS 'IME I PREZIME'
FROM Employees AS E
	INNER JOIN Orders AS O ON E.EmployeeID = O.EmployeeID
GROUP BY CONCAT(E.FirstName,' ',E.LastName),E.Region
HAVING COUNT(*) >
(
	SELECT TOP 1 COUNT(*) AS 'BROJ NARUDZBI'
	FROM Employees AS EMP
		INNER JOIN Orders AS O ON EMP.EmployeeID = O.EmployeeID
	WHERE (EMP.Region = E.Region) OR (EMP.Region IS NULL AND E.Region IS NULL)
	GROUP BY O.EmployeeID
	ORDER BY 1 ASC
)
-- 3c)
-- c)	(9 bodova) Prikazati proizvode koje naru?uju kupci iz zemlje iz koje se najmanje kupuje. (Northwind)
-- Zaglavlje: ProductName.
SELECT DISTINCT P.ProductName
FROM Products AS P
	INNER JOIN [Order Details] AS OD ON P.ProductID = OD.ProductID
	INNER JOIN Orders AS O ON OD.OrderID = O.OrderID
	INNER JOIN Customers AS C ON O.CustomerID = C.CustomerID
WHERE C.Country =
(
	SELECT TOP 1 C2.Country
	FROM Orders AS O2
		INNER JOIN Customers AS C2 ON O2.CustomerID = C2.CustomerID
	GROUP BY C2.Country
	ORDER BY COUNT(*) ASC
)
-- 4a)
--a)	(10 bodova) Prikazati trgovine u kojima se mogu na?i naslovi prodani manje puta nego �to je prosje?na prodaja naslova iz godine kad je prodano najmanje naslova (Pubs).
USE pubs
GO
-- Zaglavlje: stor_name
SELECT DISTINCT S.stor_name
FROM stores AS S
	INNER JOIN sales AS SL ON S.stor_id = SL.stor_id
WHERE  SL.title_id IN
(
	SELECT T.title_id
	FROM titles AS T
		INNER JOIN sales AS S ON T.title_id =S.title_id
	GROUP BY T.title_id
	HAVING SUM(S.qty) <
	(
		SELECT AVG(S.qty) 
		FROM SALES AS S
		WHERE YEAR(S.ord_date) =
		(
			SELECT TOP 1 YEAR(S.ord_date)
			FROM sales AS S
			GROUP BY YEAR(S.ord_date)
			ORDER BY SUM(S.qty) ASC
		)
	)
)
-- 4b)
-- b)	(10 bodova) Prikazati naslove starije od najbolje  prodavanog naslova kojeg je izdao izdava? iz savezne dr�ave koja sadr�i slog 'CA'.  (Pubs).
-- Zaglavlje: title(naslov knjige)
SELECT T.title
FROM titles AS T
WHERE DATEDIFF(YEAR,T.pubdate,GETDATE())>
(
	SELECT DATEDIFF(YEAR,T2.pubdate,GETDATE())
	FROM titles AS T2
	WHERE T2.title_id =
	(
		SELECT TOP 1 T3.title_id
		FROM titles AS T3 
			INNER JOIN sales AS S ON T3.title_id = S.title_id
		WHERE T3.pub_id IN 
		(
			SELECT P.pub_id
			FROM publishers AS P
			WHERE P.state LIKE '%CA%'
		)
		GROUP BY T3.title_id
		ORDER BY SUM(S.qty) DESC
	)
)

CREATE DATABASE VJEZBA1307
GO
USE VJEZBA1307
GO
--5.1. 										max: 5 bodova
--U kreiranoj bazi podataka kreirati tabele sa sljede�om strukturom: 			
--5.1. a) Izdavaci 
--�	IzdavacID, 4 karaktera fiksne du�ine i primarni klju�, 
--�	NazivIzdavaca, 40 karaktera, (zadana vrijednost �nepoznat izdavac�) 
--�	Drzava, 30 karaktera, 
--�	Logo, fotografija  
CREATE TABLE Izdavaci
(
	IzdavacID CHAR(4) CONSTRAINT PK_Izdavaci PRIMARY KEY, 
	NazivIzdavaca VARCHAR(40) DEFAULT('NEPOZNATA VRIJEDNOST'), 
	Drzava VARCHAR(30), 
	Logo IMAGE  	
)

--5.1. b) Naslovi 
--�	NaslovID, 6 karaktera i primarni klju�, 
--�	Naslov, 80 karaktera (obavezan unos), 
--�	Tip, 12 karaktera fiksne du�ine (obavezan unos), 
--�	Cijena, nov�ani tip podataka,   
--�	IzdavacID, 4 karaktera fiksne du�ine, strani klju� 
CREATE TABLE Naslovi
(
	NaslovID VARCHAR(6) CONSTRAINT PK_Naslovi PRIMARY KEY, 
	Naslov VARCHAR(80) NOT NULL, 
	Tip CHAR(12) NOT NULL, 
	Cijena MONEY,   
	IzdavacID CHAR(4) CONSTRAINT FK_Naslovi_Izdavaci FOREIGN KEY REFERENCES Izdavaci(IzdavacID)
)
--5.1. d)	Prodavnice 
--�	ProdavnicaID, 4 karaktera fiksne du�ine i primarni klju�, 
--�	NazivProdavnice, 40 karaktera, 
--�	Grad, 40 karaktera 
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) CONSTRAINT PK_Prodavnice PRIMARY KEY, 
	NazivProdavnice VARCHAR(40), 
	Grad VARCHAR(40)
)
--prvo kreiramo tabelu Prodavnice jer tabela Prodaja ima strani klju� koji se referencira na PK od Prodavnice

--5.1. c) Prodaja  
--�	ProdavnicaID, 4 karaktera fiksne du�ine, strani i primarni klju�, 
--�	BrojNarudzbe, 20 karaktera, primarni klju�, 
--�	NaslovID, 6 karaktera, strani i primarni klju�, 
--�	DatumNarudzbe, polje za unos datuma i vremena (obavezan unos), 
--�	Kolicina, skra�eni cjelobrojni tip (obavezan unos, dozvoljen unos brojeva ve�ih od 0
CREATE TABLE Prodaja
(
	ProdavnicaID CHAR(4) CONSTRAINT FK_Prodaja_Prodavnice FOREIGN KEY REFERENCES Prodavnice(ProdavnicaID), 
	BrojNarudzbe VARCHAR(20), 
	NaslovID VARCHAR(6) CONSTRAINT FK_Prodaja_Naslovi FOREIGN KEY REFERENCES Naslovi(NaslovID), 
	DatumNarudzbe DATETIME NOT NULL, 
	Kolicina SMALLINT  NOT NULL CONSTRAINT CHK_Prodaja_K CHECK(Kolicina > 0),

	CONSTRAINT PK_Prodaja PRIMARY KEY(ProdavnicaID,BrojNarudzbe,NaslovID)
)
--5.2. 										max: 5 bodova
--U kreiranu bazu kopirati podatke iz baze Pubs: 		
--5.2. a)	U tabelu Izdavaci dodati sve izdava�e 
--�	pub_id -> IzdavacID; pub_name -> NazivIzdavaca; country -> Drzava; Logo -> Logo 
INSERT INTO Izdavaci
SELECT P.pub_id,P.pub_name,P.country,PI.logo
FROM pubs.DBO.publishers AS P 
	INNER JOIN pubs.dbo.pub_info AS PI ON P.pub_id = PI.pub_id

--5.2. b)	U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka o cijeni zamijeniti vrijednost sa 0 
--�	title_id -> NaslovID; title -> Naslov; type -> Tip; price -> Cijena; pub_id -> IzdavacID 
INSERT INTO Naslovi
SELECT T.title_id,T.title,T.type,ISNULL(T.price,0),T.pub_id
FROM pubs.DBO.titles AS T

--5.2. d)	U tabelu Prodavnice dodati sve prodavnice 
--�	stor_id -> ProdavnicaID; store_name -> NazivProdavnice; city -> Grad 
INSERT INTO Prodavnice 
SELECT P.stor_id,P.stor_name,P.city
FROM pubs.dbo.stores AS P
--Izvr�avamo insert u Prodavnice prije Prodaje zbog ograni�enja stranog klju�a

--5.2. c)	U tabelu Prodaja dodati sve stavke iz tabele prodaja 
--�	stor_id -> ProdavnicaID; order_num -> BrojNarudzbe; title_id -> NaslovID; ord_date -> DatumNarudzbe; qty -> Kolicina 
INSERT INTO Prodaja 
SELECT S.stor_id,S.ord_num,S.title_id,S.ord_date,S.qty
FROM pubs.dbo.sales AS S

SELECT * FROM Prodaja
-- 5.3a)
--a)	(5 bodova) Kreirati pogled v_prodaja kojim ?e se prikazati statistika prodaje knjiga po izdava?ima. Prikazati naziv te dr�avu iz koje izdava?i dolaze, ukupan broj napisanih naslova, te ukupnu prodanu koli?inu. Rezultate sortirati po ukupnoj prodanoj koli?ini u opadaju?em redoslijedu. (Novokreirana baza) 
GO
CREATE OR ALTER VIEW v_prodaja
AS
	SELECT *
	FROM
	(
		SELECT	
			I.NazivIzdavaca,
			I.Drzava,
			(
				SELECT COUNT(*)
				FROM Naslovi AS N
				WHERE N.IzdavacID = I.IzdavacID
			)AS 'BROJ NAPISANIH NASLOVA',
			SUM(P.Kolicina) AS 'UKUPNA PRODANA KOLICINA'
		FROM Izdavaci AS I
			INNER JOIN Naslovi AS N ON I.IzdavacID = N.IzdavacID
			INNER JOIN Prodaja AS P ON N.NaslovID = P.NaslovID
		GROUP BY I.NazivIzdavaca,I.Drzava,I.IzdavacID
	)AS SBQ
GO

SELECT * FROM v_prodaja
ORDER BY 4 DESC
--b)	(2 boda) U novokreiranu bazu iz baze Northwind dodati tabelu Employees. Prilikom kreiranja izvr�iti automatsko instertovanje podataka. 
SELECT *
INTO Employees
FROM Northwind.dbo.Employees
--5.3. c)	(5 boda) Kreirati funkciju f_4b koja �e vra�ati podatke u formi tabele na osnovu proslijedjenih parametra od i do, cjelobrojni tip. Funkcija �e vra�ati one zapise u kojima se godine radnog sta�a nalaze u intervalu od-do. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izra�unatim godinama radnog sta�a. OBAVEZNO provjeriti ispravnost funkcije uno�enjem kontrolnih vrijednosti. (Novokreirana baza) 
GO
CREATE OR ALTER FUNCTION F_4B
(
	@OD INT,
	@DO INT
)
RETURNS TABLE
AS RETURN
	SELECT DATEDIFF(YEAR,E.HireDate,GETDATE()) AS 'RADNI STA�',*
	FROM Employees AS E
	WHERE DATEDIFF(YEAR,E.HireDate,GETDATE()) BETWEEN @OD AND @DO
GO

SELECT * FROM F_4B(32,34)
ORDER BY 1 ASC
-- 5.3c)
--d)	(3 bodova) Kreirati proceduru sp_Prodavnice_insert kojom ?e se izvr�iti insertovanje podataka unutar tabele prodavnice. OBAVEZNO kreirati testni slu?aj. (Novokreirana baza) 
GO
CREATE OR ALTER PROCEDURE sp_Prodavnice_insert
(
	@ProdavnicaID CHAR(4),
	@NazivProdavnice VARCHAR(40) = NULL,
	@Grad VARCHAR(40) = NULL
)
AS BEGIN
	INSERT INTO Prodavnice
	(
		ProdavnicaID,
		NazivProdavnice,
		Grad
	)
	VALUES
	(
		@ProdavnicaID,
		@NazivProdavnice,
		@Grad	
	)
END
GO

EXEC sp_Prodavnice_insert 'EDED','GHOHEDWFBNJHFGBLWDFUWOGFUIGRFIU'

SELECT * FROM Prodavnice