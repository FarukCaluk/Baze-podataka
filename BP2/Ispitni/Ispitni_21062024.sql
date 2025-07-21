--1. Kroz SQL kod kreirati bazu podataka sa imenom vaseg broja indeksa
go
create database IB454545
go
use IB454545
--2. U kreiranoj bazi podataka kreirati tabele sa sljedecom strukturom:
--a)	Uposlenici
--•	UposlenikID, cjelobrojni tip i primarni kljuc, autoinkrement,
--•	Ime 10 UNICODE karaktera obavezan unos,
--•	Prezime 20 UNICODE karaktera obavezan unos
--•	DatumRodjenja polje za unos datuma i vremena obavezan unos
--•	UkupanBrojTeritorija, cjelobrojni tip

create table Uposlenici
(
	UposlenikID int primary key identity(1,1),
	Ime nvarchar(10) not null,
	Prezime nvarchar(20) not null,
	DatumRodjenja datetime not null,
	UkupanBrojTeritorija int
)

--b)	Narudzbe
--•	NarudzbaID, cjelobrojni tip i primarni kljuc, autoinkrement
--•	UposlenikID, cjelobrojni tip, strani kljuc,
--•	DatumNarudzbe, polje za unos datuma i vremena,
--•	ImeKompanijeKupca, 40 UNICODE karaktera,
--•	AdresaKupca, 60 UNICODE karaktera
create table Narudzbe
(
	NarudzbaID int primary key identity(1,1),
	UposlenikID int foreign key references Uposlenici(UposlenikID),
	DatumNarudzbe datetime ,
	ImeKompanijeKupca nvarchar(40),
	AdresaKupca nvarchar(60)
)

--c) Proizvodi
--•	ProizvodID, cjelobrojni tip i primarni ključ, autoinkrement
--•	NazivProizvoda, 40 UNICODE karaktera (obavezan unos)
--•	NazivKompanijeDobavljaca, 40 UNICODE karaktera
--•	NazivKategorije, 15 UNICODE karaktera
create table Proizvodi
(
	ProizvodID int primary key identity(1,1),
	NazivProizvoda nvarchar(40) not null,
	NazivKompanijeDobavljaca nvarchar(40) ,
	NazivKategorije nvarchar(15)
)

--d) StavkeNarudzbe
--•	NarudzbalD, cjelobrojni tip strani i primarni ključ
--•	ProizvodlD, cjelobrojni tip strani i primarni ključ
--•	Cijena, novčani tip (obavezan unos)
--•	Kolicina, kratki cjelobrojni tip (obavezan unos)
--•	Popust, real tip podatka (obavezan unos)

create table StavkeNarudzbe
(
	NarudzbalD int,
	ProizvodID int,
	Cijena money not null,
	Kolicina smallint not null,
	Popust real not null,

	constraint PK_StavkeNarudzbe primary key (NarudzbalD,ProizvodID),
	constraint FK_StavkeNarudzbe_Narudzbe foreign key (NarudzbalD) references Narudzbe(NarudzbaID),
	constraint FK_StavkeNarudzbe_Proizvodi foreign key (ProizvodID) references Proizvodi(ProizvodID)
)
--4 boda

--3. Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--•	EmployeelD -> UposlenikID
--•	FirstName -> Ime
--•	LastName -> Prezime
--•	BirthDate -> DatumRodjenja
--•	lzračunata vrijednost za svakog uposlenika na osnovu EmployeeTerritories-:----UkupanBrojTeritorija
set identity_insert Uposlenici on
insert into Uposlenici
(
	UposlenikID,
	Ime,
	Prezime,
	DatumRodjenja,
	UkupanBrojTeritorija
)
select
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	e.BirthDate,
	count(*)
from Northwind.dbo.Employees as e
	inner join Northwind.dbo.EmployeeTerritories as et on e.EmployeeID = et.EmployeeID
group by e.EmployeeID,e.FirstName,e.LastName,e.BirthDate
set identity_insert Uposlenici off

select * from Uposlenici
--b) U tabelu Narudzbe dodati sve narudzbe
--•	OrderlD -> NarudzbalD
--•	EmployeelD -> UposlenikID
--•	OrderDate -> DatumNarudzbe
--•	CompanyName -> ImeKompanijeKupca
--•	Address -> AdresaKupca
set identity_insert Narudzbe on
insert into Narudzbe
(
	NarudzbaID,
	UposlenikID,
	DatumNarudzbe,
	ImeKompanijeKupca,
	AdresaKupca
)
select
	 o.OrderID,
	 o.EmployeeID,
	 o.OrderDate,
	 c.CompanyName,
	 c.Address
from Northwind.dbo.Orders as o
	inner join Northwind.dbo.Customers as c on o.CustomerID = c.CustomerID
set identity_insert Narudzbe off

select * from Narudzbe

--c) U tabelu Proizvodi dodati sve proizvode
--•	ProductID -> ProizvodlD
--•	ProductName -> NazivProizvoda
--•	CompanyName -> NazivKompanijeDobavljaca
--•	CategoryName -> NazivKategorije

set identity_insert Proizvodi on
insert into Proizvodi
(
	ProizvodID,
	NazivProizvoda,
	NazivKompanijeDobavljaca,
	NazivKategorije
)
select
	p.ProductID,
	p.ProductName,
	s.CompanyName,
	c.CategoryName
from Northwind.dbo.Products as p
	inner join Northwind.dbo.Suppliers as s on p.SupplierID = s.SupplierID
	inner join Northwind.dbo.Categories as c on p.CategoryID = c.CategoryID
set identity_insert Proizvodi off

select * from Proizvodi
--d) U tabelu StavkeNarudzbe dodati sve stavke narudzbe
--•	OrderlD -> NarudzbalD
--•	ProductID -> ProizvodlD
--•	UnitPrice -> Cijena
--•	Quantity -> Kolicina
--•	Discount -> Popust

insert into StavkeNarudzbe
(
	NarudzbalD,
	ProizvodID,
	Cijena,
	Kolicina,
	Popust
)
select
	od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
from Northwind.dbo.[Order Details] as od

select * from StavkeNarudzbe

--5 bodova

--4. 
--a) (4 boda) U tabelu StavkeNarudzbe dodati 2 nove izračunate kolone: vrijednostNarudzbeSaPopustom i vrijednostNarudzbeBezPopusta. Izračunate kolone već čuvaju podatke na osnovu podataka iz kolona! 
alter table StavkeNarudzbe
add vrijednostNarudzbeSaPopustom as Cijena * Kolicina * (1-Popust)

alter table StavkeNarudzbe
add vrijednostNarudzbeBezPopusta as Cijena * Kolicina

select * from StavkeNarudzbe
--b) (5 bodova) Kreirati pogled v_select_orders kojim će se prikazati ukupna zarada po uposlenicima od narudzbi kreiranih u zadnjem kvartalu 1996. godine. Pogledom je potrebno prikazati spojeno ime i prezime uposlenika, ukupna zarada sa popustom zaokruzena na dvije decimale i ukupna zarada bez popusta. Za prikaz ukupnih zarada koristiti OBAVEZNO koristiti izračunate kolone iz zadatka 4a. (Novokreirana baza)
go
create view v_select_orders
as
	select
		concat(u.Ime, ' ',u.Prezime) as 'Ime i prezime',
		cast(sum(sn.vrijednostNarudzbeSaPopustom) as decimal(18,2)) as 'Ukupna zarada sa popustom',
		cast(sum(sn.vrijednostNarudzbeBezPopusta) as decimal(18,2)) as 'Ukupna zarada bez popusta'
	from Uposlenici as u 
		inner join Narudzbe as n on u.UposlenikID = n.UposlenikID
		inner join StavkeNarudzbe as sn on n.NarudzbaID = sn.NarudzbalD
	where YEAR(n.DatumNarudzbe) = 1996 and DATEPART(QUARTER,n.DatumNarudzbe)=4
	group by u.UposlenikID,u.Ime,u.Prezime
go

select * from v_select_orders
--c) (5 boda) Kreirati funkciju f_stariji_uposlenici koja će vraćati podatke u formi tabele na osnovu proslijedjenog parametra godineStarosti, cjelobrojni tip. Funkcija će vraćati one zapise u kojima su godine starosti kod uposlenika veće od unesene vrijednosti parametra. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama starosti. Provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 
go
create function f_stariji_uposlenici
(
	 @godineStarosti int
)
returns table
as 
return
	select *,
			DATEDIFF(YEAR,u.DatumRodjenja,GETDATE()) as Starost
	from Uposlenici as u
	where DATEDIFF(YEAR,u.DatumRodjenja,GETDATE())>@godineStarosti
go

select * from f_stariji_uposlenici(30)
select * from f_stariji_uposlenici(65)
select * from f_stariji_uposlenici(75)

--d) (7 bodova) Pronaći najprodavaniji proizvod u 2011 godini. Ulogu najprodavanijeg nosi onaj kojeg je najveći broj komada prodat. (AdventureWorks2017)
use AdventureWorks2017
go

select top 1
	p.ProductID,
	p.Name,
	sum(od.OrderQty) as 'Prodana kolicina'
from Sales.SalesOrderHeader as sh
	inner join Sales.SalesOrderDetail as od on sh.SalesOrderID=od.SalesOrderID
	inner join Production.Product as p on od.ProductID = p.ProductID
where YEAR(sh.OrderDate) = 2011
group by p.ProductID,p.Name
order by 3 desc

--e) (6 bodova) Prikazati ukupan broj proizvoda prema specijalnim ponudama. Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjeće. (AdventureWorks2017) 
select
	sop.SpecialOfferID,
	count(*) as 'Broj proizvoda'
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as c on ps.ProductCategoryID = c.ProductCategoryID
	inner join Sales.SpecialOfferProduct as sop on p.ProductID = sop.ProductID
where (c.Name) = 'Clothing'
group by sop.SpecialOfferID
--f) (8 bodova) Prikazati najskuplji proizvod (List Price) u svakoj kategoriji. (AdventureWorks2017) 
SELECT
    c.Name AS Kategorija,
    ranked.Name AS Proizvod,
    ranked.ListPrice
FROM (
    SELECT 
        p.Name,
        p.ListPrice,
        ps.ProductCategoryID,
        ROW_NUMBER() OVER (
            PARTITION BY ps.ProductCategoryID 
            ORDER BY p.ListPrice DESC
        ) AS rn
    FROM Production.Product AS p
    INNER JOIN Production.ProductSubcategory AS ps 
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
) AS ranked
INNER JOIN Production.ProductCategory AS c 
    ON ranked.ProductCategoryID = c.ProductCategoryID
WHERE ranked.rn = 1


--g) (8 bodova) Prikazati proizvode čija je maloprodajna cijena (List Price) manja od prosječne maloprodajne cijene kategorije proizvoda kojoj pripada. (AdventureWorks2017) 
select
	p.Name,
	p.ListPrice
from Production.Product as p
	inner join Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join Production.ProductCategory as c on ps.ProductCategoryID = c.ProductCategoryID
where p.ListPrice<
(
	select avg(p2.ListPrice)
	from Production.Product as p2
		inner join Production.ProductSubcategory as ps2 on p.ProductSubcategoryID = ps2.ProductSubcategoryID
	where  ps2.ProductCategoryID = ps.ProductCategoryID
)
order by 2 asc 
--###################### PROSJEK ZA PROVJERU
select avg(p.ListPrice)
from Production.Product as p
--###################### PROSJEK ZA PROVJERU
-- KAKAV PROSJEK BA KUME AJDE RADI ISPITNI VISEEEEEEEEEEEEEEEEE

--43 boda

--5. 
--a) (12 bodova) Pronaći najprodavanije proizvode, koji nisu na listi top 10 najprodavanijih proizvoda u zadnjih 11 godina. (AdventureWorks2017) 

SELECT 
	P.ProductID,
	P.Name,
	SUM(SOD.OrderQty) AS UkupnoProdano
FROM Production.Product AS P
	INNER JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID = SOD.ProductID
	INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate) > YEAR(GETDATE()) - 11
GROUP BY P.ProductID, P.Name
HAVING P.ProductID NOT IN (
	SELECT TOP 10 P2.ProductID
	FROM Production.Product AS P2
		INNER JOIN Sales.SalesOrderDetail AS SOD2 ON P2.ProductID = SOD2.ProductID
		INNER JOIN Sales.SalesOrderHeader AS SOH2 ON SOD2.SalesOrderID = SOH2.SalesOrderID
	WHERE YEAR(SOH2.OrderDate) > YEAR(GETDATE()) - 11
	GROUP BY P2.ProductID
	ORDER BY SUM(SOD2.OrderQty) DESC
)
ORDER BY UkupnoProdano DESC;



--b) (16 bodova) Prikazati ime i prezime kupca, id narudzbe, te ukupnu vrijednost narudzbe sa popustom (zaokruzenu na dvije decimale), uz uslov da su na nivou pojedine narudžbe naručeni proizvodi iz svih kategorija. (AdventureWorks2017) 
SELECT 
    p.FirstName,
    p.LastName,
    soh.SalesOrderID,
    CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS UkupnaVrijednostSaPopustom
FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    INNER JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
WHERE soh.SalesOrderID IN (
    SELECT sod.SalesOrderID
    FROM Sales.SalesOrderDetail AS sod
        INNER JOIN Production.Product AS pr ON sod.ProductID = pr.ProductID
        INNER JOIN Production.ProductSubcategory AS ps ON pr.ProductSubcategoryID = ps.ProductSubcategoryID
    GROUP BY sod.SalesOrderID
    HAVING COUNT(DISTINCT ps.ProductCategoryID) = (
        SELECT COUNT(*) FROM Production.ProductCategory
    )
)
GROUP BY p.FirstName, p.LastName, soh.SalesOrderID
ORDER BY UkupnaVrijednostSaPopustom DESC;


--28 bodova 

--6. Dokument teorijski_ispit 21 JUN24, preimcnovati vašim brojem indeksa, te u tom dokumentu izraditi pitanja.
--20 bodova 