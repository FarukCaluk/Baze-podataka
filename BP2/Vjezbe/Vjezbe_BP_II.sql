--1. Kreirati bazu podataka pod nazivom ZadaciZaVjezbu.
--2. U pomenutoj bazi kreirati tabelu Aplikanti koja će sadržavati sljedeće
--kolone: Ime, Prezime i Mjesto_rođenja. Sva navedena polja trebaju da
--budu tekstualnog tipa, te prilikom kreiranja istih paziti da se ne zauzimaju
--bespotrebno memorijski resursi.
create table Aplikanti
(
	Ime nvarchar(50),
	Prezime nvarchar(50),
	Mjesto_rođenja nvarchar(50)
)
--3. U tabelu Aplikanti dodati kolonu AplikantID, te je proglasiti primarnim
--ključem tabele (kolona mora biti autoinkrement)
alter table Aplikanti
add AplicantiId int NOT NULL constraint PK_Aplikanti primary key identity(1, 1)
--4. U bazi ZadaciZaVjezbu kreirati tabelu Projekti koji će sadržavati sljedeće
--kolone: Naziv projekta, Akronim projekta, Svrha projekta i Cilj projekta.
--Sva polja u tabeli su tekstualnog tipa, te prilikom kreiranja istih paziti da
--se ne zauzimaju bespotrebno memorijski resursi. Sva navedena polja
--osim cilja projekta moraju imati vrijednost.
create table Projekti
(
	Naziv nvarchar(100) NOT NULL,
	Akronim nvarchar(10) NOT NULL,
	Svrha nvarchar(150) NOT NULL,
	Cilj nvarchar(100)
)
--5. U tabelu Projekti dodati kolonu Sifra projekta, te je proglasiti primarnim
--ključem tabele.
alter table Projekti 
add Sifra nvarchar(15) constraint PK_Projekti primary key
--6. U tabelu Aplikanti dodati kolonu projekatID koje će biti spoljni ključ na
--tabelu projekat.
alter table Aplikanti
add ProjekatID nvarchar(15) CONSTRAINT FK_Aplikanti_Projekti foreign key references Projekti(Sifra)

--7. U bazi podataka ZadaciZaVjezbu kreirati tabelu TematskeOblasti koja će
--sadržavati sljedeća polja tematskaOblastID, naziv i opseg.
--TematskaOblastID predstavlja primarni ključ tabele,te se automatski
--uvećava. Sva definisana polja moraju imati vrijednost. Prilikom
--definisanja dužine polja potrebno je obratiti pažnju da se ne zauzimaju
--bespotrebno memorijski resursi. Projekti pripadaju jednoj tematskoj
--oblasti.
create table TematskeOblasti
(
	tematskaOblastID int NOT NULL constraint PK_tematskaOblastID primary key identity(1, 1),
	Naziv nvarchar(100) NOT NULL,
	opseg nvarchar(100)NOT NULL
)
alter table Projekti
add tematskaOblastID int constraint FK_Projekti_TematskeOblasti foreign key references TematskeOblasti(tematskaOblastID)
--8. U tabeli Aplikanti dodati polje email koje je tekstualnog tipa i može ostati
--prazno, a u tabeli Projekti dodati polje cijena koja će biti decimalnog tipa
--sa dvije cifre preciznosti iza decimalnog zareza.
alter table Aplikanti
add Email nvarchar(50)

alter table Projekti
add Cijena decimal(18, 2)
--9. U tabele TematskeOblasti i Projekti dodati sljedeće zapise.
--Tematske oblasti [Naziv, Opseg]
--• ('Klimatske promjene i zaštita okoliša', 'Uzroci i posljedice
--globalnog zatopljenja'),
--• ('Umjetna inteligencija i tehnologija', 'Razvoj algoritama za
--strojno učenje'),
--marko.dogan@edu.fit.ba
--esmir.hero@edu.fit.ba
--Fakultet informacijskih tehnologija
--elda@edu.fit.ba
--Baze Podataka II :: Vježbe
--2
--• ('Globalna ekonomija i trgovina', 'Trgovinski sporovi i carine')
--Projekti [Naziv, Akronim, Svrha, Cilj, Sifra, TematskaOblastID, Cijena]
--• ('Sunce', 'S', 'Zaštita od UV zračenja', 'Zaštititi planetu', 'ABHC12',
--2, 1500.99),
--• ('Mjesec', 'M', 'Apollo-12', 'Sletiti na mjesecc', 'MJSC911', 1,
--15000050.99)
insert into TematskeOblasti(Naziv, opseg)
values ('Klimatske promjene i zaštita okoliša', 'Uzroci i posljedice
--globalnog zatopljenja'),
('Umjetna inteligencija i tehnologija', 'Razvoj algoritama za
--strojno učenje'),
('Globalna ekonomija i trgovina', 'Trgovinski sporovi i carine')

insert into Projekti(Naziv, Akronim, Svrha, Cilj, Sifra, tematskaOblastID, Cijena)
values ('Sunce', 'S', 'Zaštita od UV zračenja', 'Zaštititi planetu', 'ABHC12', 2, 1500.99),
('Mjesec', 'M', 'Apollo-12', 'Sletiti na mjesecc', 'MJSC911', 1, 15000050.99)

--10. Promjeniti tip podatka kolone Cijena iz tablice Projekti u tekstualni tip
--podatka.
alter table Projekti 
alter column Cijena nvarchar(40)
--11. Prethodno promijenjeni tip podatka kolone Cijena pokušati pretvoriti
--u cjelobrojni tip podatka.

alter table Projekti
alter column Cijena int

--12. DDL izrazom izbrisati sve redove tablice TematskeOblasti.
alter table Projekti 
drop constraint FK_Projekti_TematskeOblasti

truncate table TematskeOblasti
--13. DML izrazom izbirsati sve redove tablice Projketi.
alter table Aplikanti
drop constraint FK_Aplikanti_Projekti

delete from Projekti
where Projekti.Sifra = 'ABHC12'
--14. U tabeli Aplikanti obrisati mjesto rođenja i dodati polja telefon i
--matični broj. Oba novokreirana polja su tekstualnog tipa i moraju
--sadržavati vrijednost.
alter table Aplikanti
drop column Mjesto_rođenja

alter table Aplikanti
add Telefon nvarchar(15) NOT NULL,
MaticniBroj nvarchar(15) NOT NULL

--15. Obrisati tabele kreirane u prethodnim zadacima.
drop table Aplikanti, Projekti, TematskeOblasti
--16. Obrisati kreiranu bazu.
use master
go
drop database ZadaciZaVjezbu

create database ProdukcijskaKuca
go
use ProdukcijskaKuca

create table Producent 
(
	ID int NOT NULL constraint PK_Producent primary key identity(1, 1),
	Ime nvarchar(50),
	Prezime nvarchar(50),
	BrojLicne real
)

create table Filmovi
(
	ID int NOT NULL constraint PK_Filmovi primary key identity(1, 1),
	Naziv nvarchar(50),
	Godina date,
	Sadrzaj nvarchar(100)
)
create table FilmoviProducenti
(
	FilmID int NOT NULL constraint FK_FilmoviProducenti_Filmovi foreign key references Filmovi(ID),
	ProdudentID int NOT NULL constraint FK_FilmoviProducenti_Producent foreign key references Producent(ID),
	constraint PK_FilmoviProducenti primary key(FilmID, ProdudentID)
)
create table Glumci
(
	ID int NOT NULL constraint PK_Glumci primary key identity(1, 1),

)