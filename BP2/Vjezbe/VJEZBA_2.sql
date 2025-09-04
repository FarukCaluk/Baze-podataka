--1.	Kreirati bazu Function_ i aktivirati je.
CREATE DATABASE Function_
GO
USE Function_
--2.	Kreirati tabelu Zaposlenici, te prilikom kreiranja uraditi insert podataka iz tabele Employee baze Pubs.
SELECT *
INTO Zaposlenici
FROM pubs.dbo.employee
--3.	U tabeli Zaposlenici dodati izračunatu (stalno pohranjenu) kolonu Godina kojom će se iz kolone hire_date izdvajati godina uposlenja.
ALTER TABLE Zaposlenici
ADD Godina AS YEAR(hire_date)

SELECT * FROM Zaposlenici
--4.	Kreirati funkciju f_ocjena sa parametrom brojBodova, cjelobrojni tip koja će vraćati poruke po sljedećem pravilu:
--	- brojBodova < 55		nedovoljan broj bodova
--	- brojBodova 55 - 65		šest (6)
--	- broj Bodova 65 - 75		sedam (7)
--	- brojBodova 75 - 85		osam (8)
--	- broj Bodova 85 - 95		devet (9)
--	- brojBodova 95-100		deset (10)
--	- brojBodova >100		fatal error
--Kreirati testne slučajeve.
GO
CREATE FUNCTION f_ocjena
(
	@brojBodova INT
)
RETURNS VARCHAR(30)
AS
BEGIN 
	DECLARE @PORUKA VARCHAR(30)
	SET @PORUKA = 'NEDOVOLJAN BROJ BODOVA'
	IF @brojBodova BETWEEN 55 AND 64 SET @PORUKA = 'ŠEST (6)'
	IF @brojBodova BETWEEN 65 AND 74 SET @PORUKA = 'SEDAM (7)'
	IF @brojBodova BETWEEN 75 AND 84 SET @PORUKA = 'OSAM (8)'
	IF @brojBodova BETWEEN 85 AND 94 SET @PORUKA = 'DEVET (9)'
	IF @brojBodova BETWEEN 95 AND 100 SET @PORUKA = 'DESET (10)'
	RETURN @PORUKA
END 
GO

SELECT DBO.f_ocjena(80)
--5.	Kreirati funkciju f_godina koja vraća podatke u formi tabele sa parametrom godina, cjelobrojni tip. Parametar se referira na kolonu godina tabele uposlenici, pri čemu se trebaju vraćati samo oni zapisi u kojima je godina veća od unijete vrijednosti parametra. Potrebno je da se prilikom pokretanja funkcije u rezultatu nalaze sve kolone tabele zaposlenici. Provjeriti funkcioniranje funkcije unošenjem kontrolnih vrijednosti.
GO
CREATE FUNCTION f_godina
(
	@GODINA INT 
)
RETURNS TABLE
RETURN
SELECT *
FROM Zaposlenici AS Z
WHERE YEAR(Z.hire_date)>@GODINA

SELECT *
FROM dbo.f_godina(1994)
--6.	Kreirati funkciju f_pub_id koja vraća podatke u formi tabele sa parametrima:
--	- prva_cifra, kratki cjelobrojni tip
--	- job_id, kratki cjelobrojni tip
--Parametar prva_cifra se referira na prvu cifru kolone pub_id tabele uposlenici, pri čemu je njegova zadana vrijednost 0. Parametar job_id se referira na kolonu job_id tabele uposlenici. Potrebno je da se prilikom pokretanja funkcije u rezultatu nalaze sve kolone tabele uposlenici. Provjeriti funkcioniranje funkcije unošenjem vrijednosti za parametar job_id = 5
GO
CREATE FUNCTION F_pub_i
(
	@prva_cifra TINYINT = 0,
	@job_id TINYINT
)
RETURNS TABLE
RETURN 
SELECT*
FROM Zaposlenici AS Z
WHERE @prva_cifra = LEFT(Z.pub_id,1) AND @job_id = Z.job_id
GO

SELECT *
FROM dbo.F_pub_i(DEFAULT,5)
--7.	Kreirati tabelu Detalji, te prilikom kreiranja uraditi isert podataka iz tabele Order Details baze Northwind. 
SELECT *
INTO Detalji
FROM Northwind.dbo.[Order Details]
--8.	Kreirati funkciju f_ukupno sa parametrima
--	- UnitPrice	novčani tip,
--	- Quantity	kratki cjelobrojni tip
--	- Discount	realni broj
--Funkcija će vraćati rezultat tip decimal (10,2) koji će računati po pravilu:
--	UnitPrice * Quantity * (1 - Discount)
GO 
CREATE FUNCTION f_ukupno
(
@UnitPrice MONEY,
@Quantity TINYINT,
@DISCOUNT REAL
)
RETURNS DECIMAL(10,2) --Definisemo povratnu vrijednost
AS
BEGIN 
	 DECLARE @vrati DECIMAL(10,2) --Deklarisemo  lokalnu varijablu
	 SET @vrati=@UnitPrice*@Quantity*(1-@DISCOUNT) --Postavimo joj vrijednost
	 RETURN @vrati  --Vratimo je
END
GO

--9.Koristeæi funkciju f_ukupno u tabeli detalji prikazati ukupnu vrijednost prometa po ID proizvoda.
SELECT D.ProductID,SUM(dbo.f_ukupno(D.UnitPrice,D.Quantity,D.Discount)) AS 'Ukupno sa popustom' --Posaljemo funkciji potrebne parametre.
FROM Detalji AS D
GROUP BY D.ProductID
--10.Koristeæi funkciju f_ukupno u tabeli detalji kreirati pogled v_f_ukupno u kojem æe biti prijazan ukupan promet po ID narudžbe.
GO
CREATE VIEW v_f_ukupno
AS
SELECT D.OrderID,SUM(dbo.f_ukupno(D.UnitPrice,D.Quantity,D.Discount)) AS 'Ukupno sa popustom' --Posaljemo funkciji potrebne parametre.
FROM Detalji AS D
GROUP BY D.OrderID
GO