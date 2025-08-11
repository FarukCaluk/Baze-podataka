--3.
--	Baza: Northwind 
GO
USE Northwind
-- a) (5 bodova) Prikazati zaposlenike koji su obradili manje narudžbi od zaposlenika koji ima najviše narudžbi u njihovoj regiji. 

select 
	concat(e.FirstName,' ',e.LastName) as Employee
from Employees as e
	inner join Orders as o on e.EmployeeID = o.EmployeeID
group by concat(e.FirstName,' ',e.LastName),e.Region
having COUNT(*)<
(
	select top 1 count(*) as 'Broj narudzbi'
	from Employees as emp
		inner join Orders as o on emp.EmployeeID = o.EmployeeID
	where(emp.Region = e.Region) or (emp.Region is null and e.Region is null)
	group by o.EmployeeID
	order by 1 desc
)

-- b) (5 bodova) Prikazati proizvode koje naručuju kupci iz zemlje iz koje se najmanje kupuje. 

select distinct
	p.ProductName
from Products as p
	inner join [Order Details] as od on p.ProductID = od.ProductID
	inner join Orders as o on od.OrderID = o.OrderID
	inner join Customers as c on o.CustomerID = c.CustomerID
where c.Country = 
(
	select top 1 c2.Country
	from Orders as o2
		inner join Customers as c2 on o2.CustomerID = c2.CustomerID
		inner join [Order Details] as od2 on o2.OrderID = od2.OrderID
	group by c2.Country
	order by sum(od2.Quantity) asc
)
--4. 
--Baza: Pubs
go 
use pubs
-- a) (5 bodova) Prikazati prosječnu starost knjiga/naslova prodanih u trgovinama u kojima se prodaju naslovi duži od 35 znakova.

 select
	AVG(DATEDIFF(YEAR,t.pubdate,GETDATE())) as 'Prosjecna starost knjiga'
 from titles as t
	inner join sales as s on t.title_id = s.title_id
where s.stor_id in 
(
	select
		st.stor_id
	from stores as st
		inner join sales as s on st.stor_id = s.stor_id
	where s.title_id in
	(
		select
			t.title_id
		from titles as t
		where len(t.title) > 35
	)
)

-- b) (10 bodova) Prikazati trgovine u kojima se mogu naći knjige/naslovi čiji autori žive u istom gradu kao i izdavač, a prodani su više puta nego što je prosječna prodaja naslova iz tri godine s najmanjom prodajom. 

SELECT ST.stor_name
FROM stores AS ST
	INNER JOIN sales AS S ON  ST.stor_id = S.stor_id
WHERE S.title_id IN
(
	SELECT T.title_id
	FROM titles AS T
		INNER JOIN titleauthor AS TA ON T.title_id = TA.title_id
		INNER JOIN authors AS A ON TA.au_id = A.au_id
		INNER JOIN publishers AS P ON T.pub_id = P.pub_id
		INNER JOIN sales AS S ON T.title_id = S.title_id
	WHERE P.city = A.city 
	GROUP BY T.title_id
	HAVING SUM(S.qty)>
	(
		SELECT AVG(s1.qty)
		FROM sales as s1
		WHERE YEAR(S1.ord_date) IN
		(
			SELECT TOP 2 YEAR(S2.ord_date)
			FROM sales AS S2
			GROUP BY YEAR(S2.ord_date)
			ORDER BY SUM(S2.qty) ASC
		)
	)
)

-- c) (10 bodova) Prikazati autore čije se knjige/naslovi prodaju u trgovinama koje se nalaze u istim gradovima u kojima su smješteni izdavači koji su objavili više od prosječnog broja objavljenih knjiga/naslova po izdavaču. 
-- Napomena: Zadatke obavezno riješiti kao podupite (na where, having, ...) ugniježdeni upiti 

select a.au_fname,a.au_lname
from authors as a 
	inner join titleauthor as ta on a.au_id =ta.au_id
where ta.title_id in
(
	select s.title_id
	from sales as s
		inner join stores as st on s.stor_id = s.stor_id
	where st.stor_id in
	(
		select s.stor_id
		from stores as s
		where s.city in
		(
			select a.city
			from authors as a
				inner join titleauthor as ta on a.au_id = ta.au_id
			group by a.city
			having count(*)>
			(
				select avg(cast(sqProsjek.Broj as decimal(18,2))) as Prosjek
				from
				(
					select
						p.pub_id,
						count(*) as Broj
					from publishers as p
						inner join titles as t on p.pub_id = t.pub_id
					group by p.pub_id
				) as sqProsjek
			)
		)
	)
)

--ili ovako

SELECT DISTINCT a.au_fname, a.au_lname
FROM authors a
	INNER JOIN titleauthor ta ON a.au_id = ta.au_id
WHERE ta.title_id IN (
	SELECT t.title_id
	FROM titles t
		INNER JOIN publishers p ON t.pub_id = p.pub_id
	WHERE p.city IN (
		SELECT s.city
		FROM stores s
	)
	AND t.pub_id IN (
		SELECT pub_id
		FROM (
			SELECT pub_id, COUNT(*) AS brojNaslova
			FROM titles
			GROUP BY pub_id
		) AS brojPoIzdavacu
		WHERE brojNaslova > (
			SELECT AVG(brojNaslova * 1.0)
			FROM (
				SELECT COUNT(*) AS brojNaslova
				FROM titles
				GROUP BY pub_id
			) AS prosjek
		)
	)
)

--5. Kreirati bazu podataka koju ćete imenovati svojim brojem indeksa.

create database IB232323
go
use IB232323

--5.1. 										max: 5 bodova
--U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 

--a) Izdavaci 
--•	IzdavacID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivIzdavaca, 40 karaktera, (zadana vrijednost „nepoznat izdavac“) 
--•	Drzava, 30 karaktera, 
--•	Logo, fotografija  

create table Izdavaci
(
	IzdavacID char(4) constraint PK_Izdavaci primary key, 
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
	NaslovID varchar (6) constraint PK_Naslovi primary key, 
	Naslov varchar(80) not null, 
	Tip char(12) not null, 
	Cijena money,   
	IzdavacID char(4) constraint FK_Naslovi_Izdavaci foreign key references Izdavaci(IzdavacID)
)

--d)	Prodavnice 
--•	ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivProdavnice, 40 karaktera, 
--•	Grad, 40 karaktera 
CREATE TABLE Prodavnice
(
	ProdavnicaID CHAR(4) CONSTRAINT PK_Prodavnice PRIMARY KEY,
	NazivProdavnice VARCHAR(40),
	Grad VARCHAR(40)
)
--c) Prodaja  
--•	ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ, 
--•	BrojNarudzbe, 20 karaktera, primarni ključ, 
--•	NaslovID, 6 karaktera, strani i primarni ključ, 
--•	DatumNarudzbe, polje za unos datuma i vremena (obavezan unos), 
--•	Kolicina, skraćeni cjelobrojni tip (obavezan unos, dozvoljen unos brojeva većih od 0

create table Prodaja
(
	ProdavnicaID char (4) constraint FK_Prodaja_Prodavnice foreign key references Prodavnice(ProdavnicaID), 
	BrojNarudzbe varchar(20), 
	NaslovID varchar(6) constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID), 
	DatumNarudzbe datetime not null, 
	Kolicina smallint  not null constraint CK_Kolicina check(Kolicina> 0)

	constraint PK_Prodaja primary key(ProdavnicaID,BrojNarudzbe,NaslovID)
)


-- 5.2.
--U kreiranu bazu kopirati podatke iz baze Pubs: 

-- a) U tabelu Izdavaci dodati sve izdavače
--• pub_id → IzdavacID; 
--• pub_name → NazivIzdavaca; 
--• country → Drzava; 
--• Logo → Logo

insert into Izdavaci
(
	IzdavacID,
	NazivIzdavaca,
	Drzava,
	Logo
)
select p.pub_id,p.pub_name,p.country,pi.logo
from pubs.dbo.publishers as p 
	inner join pubs.dbo.pub_info as pi on p.pub_id = pi.pub_id

--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka o cijeni zamijeniti vrijednost sa 0
--• title_id → NaslovID; 
--• title → Naslov; 
--• type → Tip;
--• price → Cijena; 
--• pub_id → IzdavacID

insert into Naslovi
(
	NaslovID,
	Naslov,
	Tip,
	Cijena,
	IzdavacID
)
select t.title_id,t.title,t.type,t.price,t.pub_id
from pubs.dbo.titles as t

--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id → ProdavnicalD; 
--• order_num → BrojNarudzbe; 
--• title_id → NaslovID; 
--• ord_date → DatumNarudzbe; 
--• qty → Kolicina

insert into Prodaja
(
	ProdavnicaID,
	BrojNarudzbe,
	NaslovID,
	DatumNarudzbe,
	Kolicina
)
select s.stor_id,s.ord_num,s.title_id,s.ord_date,s.qty
from pubs.dbo.sales as s
	
--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id → ProdavnicaID;
--• store_name → NazivProdavnice;
--• city → Grad

insert into Prodavnice
(
	ProdavnicaID,
	NazivProdavnice,
	Grad
)
select  s.stor_id,s.stor_name,s.city
from pubs.dbo.stores as s

-- 5.3.
--a) (5 bodova) Kreirati pogled PRODAJA_PO_IZDAVACIMA kojim će dati pregled prodaje knjiga po izdavačima. Prikazati naziv te državu iz koje izdavači dolaze, ukupan broj napisanih naslova, te ukupnu prodanu količinu. Rezultate sortirati opadajući po ukupnoj prodanoj količini. (Novokreirana baza)
go
create or alter view PRODAJA_PO_IZDAVACIMA
as
	select top 100 percent
		i.NazivIzdavaca,
		i.Drzava,
		COUNT(distinct n.NaslovID) as 'Ukupan broj napisani naslova',
		sum(p.Kolicina) as 'Ukupna prodana kolicina'
	from Izdavaci as i 
		inner join Naslovi as n on i.IzdavacID = n.IzdavacID
		inner join Prodaja as p on n.NaslovID = p.NaslovID
	group by i.NazivIzdavaca,i.Drzava
	order by 4 desc
go

select * from PRODAJA_PO_IZDAVACIMA
order by 4 desc
--b) (2 boda) U novokreiranu bazu iz baze Northwind dodati tabelu Employees. Prilikom kreiranja izvršiti automatsko instertovanje podataka. Tabelu i njene kolone imenovati domaćim jezikom

select *
into Zaposlenici
from Northwind.dbo.Employees 

select * from Zaposlenici

--c) (5 boda) Kreirati funkciju fun_53c koja će vraćati podatke u formi tabele na osnovu proslijedjenih parametra od i do, cjelobrojni tip. Funkcija će vraćati one zapise u kojima se godine radnog staža nalaze u intervalu od-do. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama radnog staža. OBAVEZNO provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza)
go
create or alter function fun_53c
(
	@od int,
	@do int
)
returns table 
as 
return 
	select *,
			DATEDIFF(YEAR,z.HireDate,GETDATE()) as Staz
	from Zaposlenici as z
	where DATEDIFF(YEAR,z.HireDate,GETDATE()) between @od and @do
go

select * from fun_53c(15,45)

--d) (3 bodova) Kreirati proceduru sp_Prodavnice_insert kojom će se izvršiti insertovanje podataka unutar tabele prodavnice. OBAVEZNO kreirati testni slučaj. (Novokreirana baza)
go
create or alter procedure sp_Prodavnice_insert
(
	@ProdavnicaID char(4),
	@NazivProdavnice varchar(40) = null,
	@Grad varchar(40) = null
)
as
begin
	insert into Prodavnice
	(
		ProdavnicaID,
		NazivProdavnice,
		Grad
	)
	values
	(
		@ProdavnicaID,
		@NazivProdavnice,
		@Grad
	)
end
go

select *
from Prodavnice

exec sp_Prodavnice_insert 'SASA','NIje virus nikakav BGM','Wuhan Kina'