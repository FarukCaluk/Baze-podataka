--2. 										max: 12 bodova
--Baza: AdventureWorks2017
use AdventureWorks2017
go
--a)	(6 bodova) Prikazati ukupnu vrijednost narudžbi za svakog kupca pojedinačno. Upitom prikazati ime i prezime kupca te ukupnu vrijednost narudžbi sa i bez popusta.
--Zaglavlje (kolone): Ime i prezime, Vrijednost bez popusta (količina * cijena), Vrijednost sa popustom.

select
	CONCAT(p.FirstName, ' ' ,p.LastName) as 'Ime i prezime',
	SUM(sd.OrderQty * sd.UnitPrice) as 'Bez popusta',
	SUM(sd.OrderQty * sd.UnitPrice*(1 - sd.UnitPriceDiscount)) as 'Sa popustom'
from Sales.SalesOrderHeader as sh
	inner join Sales.SalesOrderDetail as sd on sh.SalesOrderID = sd.SalesOrderID
	inner join Sales.Customer as c on sh.CustomerID = c.CustomerID
	inner join Person.Person as p on c.PersonID = p.BusinessEntityID
group by CONCAT(p.FirstName, ' ' ,p.LastName)
--b)	(6 bodova) Prikazati 5 proizvoda od kojih je ostvaren najveći profit (zarada) i 5 s najmanjim profitom. Zaglavlje: Ime proizvoda, Zarada.
select * 
from
(
	select top 5
		p.Name,
		sum(s.OrderQty * s.UnitPrice*(1- s.UnitPriceDiscount)) as 'Profit'
	from Production.Product as p 
		inner join Sales.SalesOrderDetail as s on p.ProductID = s.ProductID
	group by p.Name
	order by 2 asc
)sbqMIn
union
select * 
from
(
	select top 5
		p.Name,
		sum(s.OrderQty * s.UnitPrice*(1- s.UnitPriceDiscount)) as 'Profit'
	from Production.Product as p 
		inner join Sales.SalesOrderDetail as s on p.ProductID = s.ProductID
	group by p.Name
	order by 2 desc
)bqMAX
-- 3. 										max: 23 boda
--Baza: Northwind
go
use Northwind
go
--a)	(7 bodova) Prikazati kupce koji su u sklopu jedne narudžbe naručili proizvode iz tačno tri kategorije. (Northwind)
--Zaglavlje: ContactName.

select distinct
	c.ContactName
from Customers as c 
	inner join Orders as o on c.CustomerID = o.CustomerID
	inner join [Order Details] as od on o.OrderID = od.OrderID
	inner join Products as p on od.ProductID = p.ProductID
group by c.ContactName,o.OrderID
having count(distinct p.CategoryID) = 3

--b)	(7 bodova) Prikazati zaposlenike koji su obradili više narudžbi od zaposlenika koji ima najmanje narudžbi u njihovoj regiji (kolona Region u tabeli Employees). (Northwind) 
--Zaglavlje: Ime i prezime.

select
	CONCAT(e.FirstName,' ',e.LastName) as 'Zaposlenik'
from Employees as e 
	inner join Orders as o on e.EmployeeID = o.EmployeeID
group by CONCAT(e.FirstName,' ',e.LastName),e.Region
having count(*)>
(
	select top 1 COUNT(*) as 'Broj narudzbi'
	from Employees as emp 
		inner join Orders as o on emp.EmployeeID = o.EmployeeID
	where(emp.Region = e.Region) or (emp.Region is null and e.Region is null)
	group by o.EmployeeID
	order by 1 asc
)


--c)	(9 bodova) Prikazati proizvode koje naručuju kupci iz zemlje iz koje se najmanje kupuje. (Northwind)
--Zaglavlje: ProductName.

select p.ProductName
from Orders as o 
	inner join [Order Details] as od on o.OrderID = od.OrderID
	inner join Customers as c on o.CustomerID = c.CustomerID
	inner join Products as p on od.ProductID = p.ProductID
where c.Country =
(
	select top 1 c2.Country
	from Customers as c2 
		inner join Orders as o on c2.CustomerID = o.CustomerID
	group by c2.Country
	order by COUNT(*) asc
)
--4. 										max: 20 bodova
--Baza: Pubs	
go
use pubs
--a)	(10 bodova) Prikazati trgovine u kojima se mogu naći naslovi prodani manje puta nego što je prosječna prodaja naslova iz godine kad je prodano najmanje naslova (Pubs).
--Zaglavlje: stor_name

select
	st.stor_name
from stores as st
	inner join sales as s on st.stor_id = s.stor_id
where s.title_id in 
(
	select t.title_id
	from titles as t
		inner join sales as s on s.title_id = t.title_id 
	group by t.title_id
	having sum(s.qty) <
	(
		select AVG(s.qty)
		from sales as s
			inner join titles as t on s.title_id = t.title_id
		where year(s.ord_date) =
		(
			select top 1 YEAR(s.ord_date)
			from sales as s
			GROUP BY YEAR(s.ord_date)
			order by count(*) asc
		)
	)
)
group by st.stor_name




--b)	(10 bodova) Prikazati naslove starije od najbolje prodavanog naslova kojeg je izdao izdavač iz savezne države koja sadrži slog 'CA'.  (Pubs).
--Zaglavlje: title(naslov knjige)
--Napomena: zadatke obavezno rješavati kao podupite (na where, having, ...) – ugnježđeni upiti
 
 select t.title
 from titles as t
 where t.pubdate <
 (
	select top 1 s.ord_date
	from sales as s
		inner join titles as t on s.title_id = T.title_id
		inner join titleauthor as ta on t.title_id = ta.title_id
		inner join authors as a on ta.au_id = a.au_id
	where lower(a.state) like '%ca%'
	group by t.title_id,s.ord_date
	order by sum(qty) desc
 )

--5. 										
--Kreirati bazu podataka koju ćete imenovati svojim brojem indeksa. 

create database IB343434
go
use IB343434

--5.1. 										max: 5 bodova
--U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 

--a) Izdavaci 
--•	IzdavacID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivIzdavaca, 40 karaktera, (zadana vrijednost „nepoznat izdavac“) 
--•	Drzava, 30 karaktera, 
--•	Logo, fotografija  
create table Izdavaci
(
	IzdavacID char(4)constraint PK_Izdavaci primary key, 
	NazivIzdavaca varchar(40) default('nepoznat izdavac'),
	Drzava varchar(30), 
	Logo image
)

--b) Naslovi 
--•	NaslovID, 6 karaktera i primarni ključ, 
--•	Naslov, 80 karaktera (obavezan unos), 
--•	Tip, 12 karaktera fiksne dužine (obavezan unos), 
--•	Cijena, novčani tip podataka,   
--•	IzdavacID, 4 karaktera fiksne dužine, strani ključ 

create table Naslovi
(
	NaslovID varchar(6)constraint PK_Naslovi primary key, 
	Naslov varchar(80) not null, 
	Tip char(12) not null, 
	Cijena money,   
	IzdavacID char(4)constraint FK_Naslovi_Izdavaci foreign key references Izdavaci(IzdavacID) 
)
--d)	Prodavnice 
--•	ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivProdavnice, 40 karaktera, 
--•	Grad, 40 karaktera 

create table Prodavnice
(
	ProdavnicaID char(4)constraint PK_Prodavnice primary key, 
	NazivProdavnice varchar(40), 
	Grad varchar(40)
)

--c) Prodaja  
--•	ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ, 
--•	BrojNarudzbe, 20 karaktera, primarni ključ, 
--•	NaslovID, 6 karaktera, strani i primarni ključ, 
--•	DatumNarudzbe, polje za unos datuma i vremena (obavezan unos), 
--•	Kolicina, skraćeni cjelobrojni tip (obavezan unos, dozvoljen unos brojeva većih od 0

create table Prodaja
(
	ProdavnicaID char(4)constraint FK_Prodaja_Prodavnice foreign key references Prodavnice(ProdavnicaID), 
	BrojNarudzbe varchar(20), 
	NaslovID varchar(6)constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID), 
	DatumNarudzbe datetime not null, 
	Kolicina smallint not null constraint CK_KolicinaVecaOd check(Kolicina >= 0)

	constraint PK_Prodaja primary key(ProdavnicaID,BrojNarudzbe,NaslovID)
)




--5.2. 										max: 5 bodova
--U kreiranu bazu kopirati podatke iz baze Pubs: 		
--a)	U tabelu Izdavaci dodati sve izdavače 
--•	pub_id -> IzdavacID; 
--•	pub_name -> NazivIzdavaca; 
--•	country -> Drzava; 
--•	Logo -> Logo
insert into Izdavaci
(
	IzdavacID,
	NazivIzdavaca,
	Drzava,
	Logo
)
select
	p.pub_id,
	p.pub_name,
	p.country,
	pi.logo
from pubs.dbo.publishers as p
	inner join pubs.dbo.pub_info as pi on p.pub_id = pi.pub_id

--b)	U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka o cijeni zamijeniti vrijednost sa 0 
--•	title_id -> NaslovID; 
--•	title -> Naslov; 
--•	type -> Tip; 
--•	price -> Cijena; 
--•	pub_id -> IzdavacID 
insert into Naslovi
(
	NaslovID,
	Naslov,
	Tip,
	Cijena,
	IzdavacID
)
select
	t.title_id,
	t.title,
	t.type,
	isnull(t.price,0),
	t.pub_id
from pubs.dbo.titles as t


--c)	U tabelu Prodaja dodati sve stavke iz tabele prodaja 
--•	stor_id -> ProdavnicaID; 
--•order_num -> BrojNarudzbe; 
--•title_id -> NaslovID; 
--•ord_date -> DatumNarudzbe; 
--•qty -> Kolicina 


insert into Prodaja
(
	ProdavnicaID,
	BrojNarudzbe,
	NaslovID,
	DatumNarudzbe,
	Kolicina
)
select
	s.stor_id,
	s.ord_num,
	s.title_id,
	s.ord_date,
	s.qty
from pubs.dbo.sales as s

--d)	U tabelu Prodavnice dodati sve prodavnice 
--•	stor_id -> ProdavnicaID; 
--• store_name -> NazivProdavnice; 
--• city -> Grad 

insert into Prodavnice
(
	ProdavnicaID,
	NazivProdavnice,
	Grad
)
select
	s.stor_id,
	s.stor_name,
	s.city
from pubs.dbo.stores as s
 
--5.3. 										max: 15 bodova
--a)	(5 bodova) Kreirati pogled v_prodaja kojim će se prikazati statistika prodaje knjiga po izdavačima. Prikazati naziv te državu iz koje izdavači dolaze, ukupan broj napisanih naslova, te ukupnu prodanu količinu. Rezultate sortirati po ukupnoj prodanoj količini u opadajućem redoslijedu. (Novokreirana baza) 
go
create view v_prodaja
as 
select*
from(
	select
		i.NazivIzdavaca,
		i.Drzava,
		(
			select count(*) 
			from Naslovi as n2
			where n2.IzdavacID = i.IzdavacID
		) as 'Broj napisanih naslova',
		sum(p.Kolicina) as 'Ukupna prodana kolicina'
	from Izdavaci as i 
		inner join Naslovi as n on i.IzdavacID = n.IzdavacID
		inner join Prodaja as p on n.NaslovID = p.NaslovID
	group by i.NazivIzdavaca,i.Drzava,i.IzdavacID
	)as subq
go

select * from v_prodaja
order by 4 desc
--b)	(2 boda) U novokreiranu bazu iz baze Northwind dodati tabelu Employees. Prilikom kreiranja izvršiti automatsko instertovanje podataka. 
select *
into Employees 
from Northwind.dbo.Employees

select * from Employees
--c)	(5 boda) Kreirati funkciju f_4b koja će vraćati podatke u formi tabele na osnovu proslijedjenih parametra od i do, cjelobrojni tip. Funkcija će vraćati one zapise u kojima se godine radnog staža nalaze u intervalu od-do. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama radnog staža. OBAVEZNO provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 
go
create function f_4b
(
	@od int,
	@do int
)
returns table 
as return 
	select DATEDIFF(YEAR,e.HireDate,GETDATE()) as 'Radni staz',*
	from Employees as e
	where DATEDIFF(YEAR,e.HireDate,GETDATE()) between @od and @do
go

select *
from f_4b(31,32)
order by 1 asc
--d)	(3 bodova) Kreirati proceduru sp_Prodavnice_insert kojom će se izvršiti insertovanje podataka unutar tabele prodavnice. OBAVEZNO kreirati testni slučaj. (Novokreirana baza) 
go
create procedure sp_Prodavnice_insert
(
	@ProdavnicaID char(4),
	@NazivProdavnice varchar(40) = null,
	@Grad varchar(40) = null
)
as begin
	insert into Prodavnice(ProdavnicaID,NazivProdavnice,Grad)
	values(@ProdavnicaID,@NazivProdavnice,@Grad)
end
go

exec sp_Prodavnice_insert 'BINGO','Bingo market','Sarajevo'
select * from Prodavnice
