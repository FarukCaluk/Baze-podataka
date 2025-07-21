--1.Kreirati bazu podataka sa imenom vaseg broja indeksa
create database IB220086
go 
use IB220086
--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip
create table Uposlenici
(
	UposlenikID int constraint PK_Uposlenici primary key identity(1,1),
    Ime nvarchar(10) not null,
    Prezime nvarchar(20) not null,
	DatumRodjenja datetime not null,
	UkupanBrojTeritorija int,
)
--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip
create table Narudzbe
(
	NarudzbaID int constraint PK_Narudzbe primary key identity(1,1),
	UposlenikID int constraint FK_Narudzbe_Uposlenici foreign key references Uposlenici(UposlenikID),
	DatumNarudzbe datetime,
    ImeKompanijeKupca nvarchar(40),
    AdresaKupca nvarchar(60),
	UkupanBrojStavkiNarudzbe int
)
--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera
create table Proizvodi
(
	ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
	NazivProizvoda nvarchar(40) not null,
	NazivKompanijeDobavljaca nvarchar(40),
	NazivKategorije nvarchar(15)
)
--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)
create table StavkeNarudzbe
(
	NarudzbaID int constraint FK_StavkeNarudzbe_Narudzbe foreign key references Narudzbe(NarudzbaID),
	ProizvodID int constraint FK_StavkeNarudzbe_Proizvodi foreign key references Proizvodi(ProizvodID),
	Cijena money not null,
	Kolicina smallint not null,
	Popust real not null,
	constraint PK_StavkeNarudzbe primary key(NarudzbaID,ProizvodID)
)
--(4 boda)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika
-- na osnovnu EmployeeTerritories -> UkupanBrojTeritorija
set identity_insert Uposlenici on 
insert into Uposlenici(UposlenikID,Ime,Prezime,DatumRodjenja,UkupanBrojTeritorija)
select
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	e.BirthDate,
	count(et.TerritoryID)
from Northwind.dbo.Employees as e
	inner join Northwind.dbo.EmployeeTerritories as et on e.EmployeeID = et.EmployeeID
group by e.EmployeeID,e.FirstName,e.LastName,e.BirthDate
set identity_insert Uposlenici off 
--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe
set identity_insert Narudzbe on 
insert into Narudzbe(NarudzbaID,UposlenikID,DatumNarudzbe,ImeKompanijeKupca,AdresaKupca)
select
	o.OrderID,
	o.EmployeeID,
	o.OrderDate,
	c.CompanyName,
	c.Address,
	COUNT(*) as 'UkupanBrojStavkiNarudzbe'
from Northwind.dbo.Orders as o
	inner join Northwind.dbo.Customers as c on o.CustomerID = c.CustomerID
set identity_insert Narudzbe off 

update Narudzbe
set UkupanBrojStavkiNarudzbe = (
	select count(*)
	from Northwind.dbo.[Order Details] as od
	where od.OrderID = Narudzbe.NarudzbaID
)
--c) U tabelu proizvodi sve proizvode
set identity_insert Proizvodi on 
insert into Proizvodi(ProizvodID,NazivProizvoda,NazivKompanijeDobavljaca,NazivKategorije)
select
	p.ProductID,
	p.ProductName,
	s.CompanyName,
	c.CategoryName
from Northwind.dbo.Products as p
	inner join Northwind.dbo.Suppliers as s on p.SupplierID = s.SupplierID
	inner join Northwind.dbo.Categories as c on p.CategoryID = c.CategoryID
set identity_insert Proizvodi off 
--d) U tabelu StavkeNrudzbe sve narudzbe
insert into StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
select
	od.OrderID,
	od.ProductID,
	od.UnitPrice,
	od.Quantity,
	od.Discount
from Northwind.dbo.[Order Details] as od
--(5 bodova)


--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)
create index ix_pretraga_naziva on Proizvodi(NazivProizvoda)

select *
from Proizvodi
where NazivProizvoda like 'A%'
--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o prpoizvodima u tabeli. Korisnici mogu poslati jedan ili vise parametara te voditi raucna da ne dodje do gubitka podataka.(Nova baza)
go
create procedure sp_update_proizvoda
(
	@ProizvodID int ,
	@NazivProizvoda nvarchar(40) = null,
	@NazivKompanijeDobavljaca nvarchar(40) = null,
	@NazivKategorije nvarchar(15) = null
)
as
begin 
update Proizvodi
set
	NazivProizvoda = iif(@NazivProizvoda is null,@NazivProizvoda,@NazivProizvoda),
	NazivKompanijeDobavljaca = iif(@NazivKompanijeDobavljaca is null,@NazivKompanijeDobavljaca,@NazivKompanijeDobavljaca),
	NazivKategorije = iif(@NazivKategorije is null,@NazivKategorije,@NazivKategorije)
where ProizvodID = @ProizvodID
end

exec sp_update_proizvoda @ProizvodID = 1,@NazivProizvoda = 'Caj'
select * from Proizvodi
--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku na osnovnu prosljedjenog parametra idNarudzbe cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe, ukupna vrijednost bez popusta. OBAVEZNO testni slucaj (Nova baza)
go
create function f_4c
(
	@NarudzbaID int
)
returns table
as 
return 
select
	sn.NarudzbaID,
	sn.Cijena*sn.Kolicina as 'VrijednostBezPopusta'
from StavkeNarudzbe as sn
where NarudzbaID = @NarudzbaID
go

select * from f_4c(10248)
select * from StavkeNarudzbe
--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe, uz id narudzbe prikazati i spojeno ime i prezime kupca te grad u koji je isporucena narudzba (AdventureWorks)
use AdventureWorks2017

select top 1
	oh.SalesOrderID,
	CONCAT(p.FirstName, ' ', p.LastName) as ImePrezime,
	a.City
from Sales.SalesOrderHeader as oh
	inner join Sales.Customer as c on oh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
	inner join Sales.SalesTerritory as st on oh.TerritoryID = st.TerritoryID
	inner join Person.Address as a on oh.ShipToAddressID = a.AddressID
where oh.CreditCardID is not null
	and st.[Group] = 'Europe'
order by oh.TotalDue asc

--e) (6 bodova) Prikazati ukupan broj porizvoda prema specijalnim ponudama.Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks)
select 
	sop.SpecialOfferID,
	COUNT(p.ProductID)BrojProizvoda
from AdventureWorks2017.Production.Product as p
	inner join AdventureWorks2017.Sales.SpecialOfferProduct as sop on p.ProductID = sop.ProductID
	inner join AdventureWorks2017.Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
	inner join AdventureWorks2017.Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where	pc.Name = 'Clothing' and p.ProductModelID is not null
group by sop.SpecialOfferID
--f) (9 bodova) Prikazatu 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)
use AdventureWorks2017

SELECT TOP 5
    sq.CustomerID,
    sq.BrojNarudzbi
FROM
(
    SELECT 
        soh.CustomerID,
        COUNT(soh.SalesOrderID) AS BrojNarudzbi
    FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
    WHERE YEAR(soh.OrderDate) IN (2011, 2012)
    GROUP BY soh.CustomerID
    HAVING soh.CustomerID IN (
		SELECT TOP 30 PERCENT 
			soh.CustomerID
		FROM AdventureWorks2017.Sales.SalesOrderHeader AS soh
		WHERE YEAR(soh.OrderDate) IN (2011, 2012)
		ORDER BY soh.OrderDate DESC
        )
) AS sq
ORDER BY sq.BrojNarudzbi DESC
--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.
select
	soh.CustomerID,
	count(distinct MONTH(soh.OrderDate))
from AdventureWorks2017.Sales.SalesOrderHeader as soh
where YEAR(soh.OrderDate) = 2012
group by soh.CustomerID
having count(distinct MONTH(soh.OrderDate)) >= 5
--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise porizvoda koji pripadaju razlicitim potkategorijama. Upitom prikazati ime i prezime kupca, id narudzbe te ukupnu vrijednost narudzbe sa popoustom zaokruzenu na 2 decimale (AdventureWorks)
select*
from
(
	select top 5
		P.FirstName AS Ime,
		P.LastName as Prezime,
		soh.SalesOrderID,
		cast(soh.TotalDue as decimal(18,2)) as 'Ukupna vrijednost narudzbe'
	from Sales.SalesOrderHeader as soh
		inner join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Person.Person as p on c.PersonID = P.BusinessEntityID
	group by p.FirstName,p.LastName,soh.SalesOrderID,soh.TotalDue
	order by count(distinct sod.ProductID) desc
) as subq1
union all
select*
from
(
	select top 5
		P.FirstName AS Ime,
		P.LastName as Prezime,
		soh.SalesOrderID,
		cast(soh.TotalDue as decimal(18,2)) as 'Ukupna vrijednost narudzbe'
	from Sales.SalesOrderHeader as soh
		inner join Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
		inner join Sales.Customer as c on soh.CustomerID = c.CustomerID
		inner join Production.Product as pp on sod.ProductID = pp.ProductID
		inner join Person.Person as p on c.PersonID = P.BusinessEntityID
	group by p.FirstName,p.LastName,soh.SalesOrderID,soh.TotalDue
	order by count(distinct pp.ProductSubcategoryID) desc
) as subq2