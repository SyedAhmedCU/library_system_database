CREATE DATABASE library_system;

USE library_system;

CREATE TABLE author (
	id INT IDENTITY(1000,1) NOT NULL PRIMARY KEY,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
);

CREATE TABLE catagory (
	id INT IDENTITY(10,1) NOT NULL PRIMARY KEY,
	category_type NVARCHAR(50) NOT NULL,
);

CREATE TABLE book (
	id INT IDENTITY(100000,1) NOT NULL PRIMARY KEY,
	book_title NVARCHAR(100) NOT NULL,
	publisher NVARCHAR(100),
	publication_year INT,
	copies_available INT NOT NULL,
	book_status_id INT DEFAULT 1 FOREIGN KEY REFERENCES book_status(id) NOT NULL,
	catagory_id INT FOREIGN KEY REFERENCES catagory(id) NOT NULL
); 

CREATE TABLE book_status (
	id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
	book_status NVARCHAR(50) NOT NULL,
	);

CREATE TABLE book_author (
	book_id INT FOREIGN KEY REFERENCES book(id) NOT NULL,
	author_id INT FOREIGN KEY REFERENCES author(id) NOT NULL,
	PRIMARY KEY (book_id, author_id) 
);

CREATE TABLE activity_status(
	id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	status_type NVARCHAR(50) NOT NULL,
);


CREATE TABLE member (
	id INT IDENTITY(10000, 1) NOT NULL PRIMARY KEY,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	phone NVARCHAR(30) NOT NULL,
	email NVARCHAR(50) NOT NULL,
	join_date DATE NOT NULL,
	end_date NVARCHAR NOT NULL,
	status_id INT FOREIGN KEY REFERENCES activity_status(id) NOT NULL
);

CREATE TABLE issuing_record(
	id INT IDENTITY(1000000, 1) NOT NULL PRIMARY KEY,
	book_id INT FOREIGN KEY REFERENCES book(id) NOT NULL,
	member_id INT FOREIGN KEY REFERENCES member(id) NOT NULL,
	issue_date DATE NOT NULL,
	returned_date DATE,
);

CREATE TABLE penalty(
	id INT IDENTITY(5000000,1) NOT NULL PRIMARY KEY,
	issue_id INT FOREIGN KEY REFERENCES issuing_record(id) NOT NULL,
	member_id INT FOREIGN KEY REFERENCES member(id) NOT NULL,
	penalty_date DATE NOT NULL,
	penalty_amount MONEY NOT NULL,
);

CREATE TABLE payment(
	id INT IDENTITY(3000000, 1) NOT NULL PRIMARY KEY,
	penalty_id INT FOREIGN KEY REFERENCES penalty(id) NOT NULL,
	member_id INT FOREIGN KEY REFERENCES member(id) NOT NULL,
	payment_date DATE NOT NULL,
	payment_amount MONEY NOT NULL,
);

--- dummy data entry

INSERT INTO author (first_name,last_name)
VALUES ('Kirbee','Tolussi'), ('Jeramie','Camelin'), ('Nicol','Caveill'), 
	('Ruthie','Lindblom'),('Bernardine','Atrill'),('Conrado','Bowland') ;  

SELECT * FROM author;

INSERT INTO activity_status(status_type)
VALUES ('active'), ('inactive'), ('suspended');

SELECT * FROM activity_status;

INSERT INTO catagory(category_type)
VALUES ('Fiction'), ('Non Fiction'), ('Kids'), ('Education');

SELECT * FROM catagory;

INSERT INTO book(book_title, publisher, publication_year, copies_available, catagory_id, book_status_id)
VALUES ('Don Quixote','Windy Gillimgham',1981,9,10, 1),('One Hundred Years of Solitude','Troy Gales',1988,25,10, 1),
('The Great Gatsby', 'Elnar Berkelay',1997,17,13, 1), ('Moby Dick','Mureil Cypler',1980,53,12, 1), 
('War and Peace','Barbette Filipychev',1982,72,11, 1), ('The Odyssey','Armin Fish',1993,60,11, 2),
('The Divine Comedy','Harv Carabine',1998,30,12, 1);

SELECT * FROM book;

INSERT INTO book_status(status_type)
VALUES ('available'), ('unavailable');

SELECT * FROM book_status;

INSERT INTO book_author(book_id, author_id)
VALUES (100000, 1003),(100001, 1002),(100002, 1003),
(100003,1000),(100004,1001),(100005,1005),(100006,1004);

SELECT * FROM  book_author;

INSERT INTO member (first_name,last_name,phone,email, join_date, end_date, status_id)
VALUES ('Leela','Hamilton','6842735640', 'leela@yahoo.com','2021-04-11','2023-04-11',1),
	('Orran','Hurdle','1947905740', 'orran@gmail.com','2021-05-11','2023-05-11', 1),
	('Sarina','Jouhning','3984134418', 'sarina123@gmail.com','2021-02-13','2022-02-13', 2),
	('Gloria','Perkinson','3506735622', 'gloria.perk@gmail.com','2021-04-08','2023-04-08',3),
	('Anabelle','Izhakov','4268215977','izhakov.anabelle@hotmail.com','2022-01-19','2023-01-19',1),
	('Tammy','Duffer', '8743340047','tammy.duffer@yahoo.com','2021-07-02','2022-07-02',3),
	('Cathleen','Pichmann','7404843126','pichmann@yahoo.com','2021-01-02','2022-01-02', 2)
	
SELECT * FROM  member;

-- null for 
INSERT INTO issuing_record (book_id, member_id, issue_date)
VALUES (100002,10005,'2022-06-20'), (100004,10003,'2022-06-25');

INSERT INTO issuing_record (book_id, member_id, issue_date)
VALUES (100004,10002,'2021-06-10'),(100001,10006,'2021-10-09');

-- not null
INSERT INTO issuing_record (book_id, member_id, issue_date, returned_date)
VALUES (100003,10001,'2022-07-10','2022-07-30'),(100005,10006,'2022-07-09','2022-07-29'); 

SELECT * FROM issuing_record;

--penalty suspended
INSERT INTO penalty(issue_id, member_id, penalty_date, penalty_amount)
VALUES(1000009,10005,'2022-07-21',20), (1000010,10003,'2022-07-25',20);

--penalty paid active
INSERT INTO penalty(issue_id, member_id, penalty_date, penalty_amount)
VALUES(1000006,10006,'2022-07-20',20), (1000011,10002,'2021-06-11',20), (1000012,10006,'2021-10-10',20);

SELECT * FROM penalty;


INSERT INTO payment(penalty_id, member_id, payment_date, payment_amount)
VALUES(5000005, 10006, '2021-10-20', 20), (5000004, 10002, '2021-06-19', 20), (5000003, 10006, '2022-07-29', 20);

SELECT * FROM payment;



--DELETE FROM  book_status WHERE id = 4;

--UPDATE member SET end_date = '2022-10-04';

--UPDATE book SET book_status_id = 2 WHERE id = 100005;


