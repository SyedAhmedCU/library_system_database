----Syed Tasnim Ahmed-Aman Kumar, Anmolbir Singh 
----------
CREATE TRIGGER safety
ON
DATABASE FOR DROP_TABLE, ALTER_TABLE
AS
PRINT
'You must disable Trigger "safety" to drop or alter!'
ROLLBACK
-----

CREATE TRIGGER trgmember ON member AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END

update member
set last_name = 'Bali'
where id = 10000;

CREATE TRIGGER trgbook ON book AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END
--------
CREATE TRIGGER trgpayment ON payment AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END

CREATE TRIGGER trgpenalty ON penalty AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END
-------
CREATE TRIGGER trgrecord ON issuing_record AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END

CREATE TRIGGER trgauthor ON author AFTER UPDATE AS
BEGIN
SELECT * FROM deleted SELECT * FROM inserted
END


---------------
---Functions---

---number of times a book is borrowed (count on issue date)
create function borrowBookTotal (@bookid int)
Returns int
As
Begin
declare @total int;
select @total = COUNT(id)
from issuing_record
where book_id = @bookid
Return @total;
End;

-----Example
select book_id, dbo.borrowBookTotal(book_id) as
'Borrowed Books Count'
from issuing_record
group by book_id
order by 'Borrowed Books Count' DESC


--number of members depending on activity status (count on member id)
create function memberCountByStatus (@StatusType nvarchar(30))
Returns int
As
BEGIN
	DECLARE @MemberCount int;
	SELECT @MemberCount = COUNT(member.id) 
	FROM member
		INNER JOIN activity_status ON member.status_id = activity_status.id
			WHERE activity_status.status_type = @StatusType;
	RETURN @MemberCount;
END

-----Example
SELECT id, status_type, dbo.memberCountByStatus(status_type) AS
'Member Count'
FROM activity_status
ORDER BY 'Member Count' DESC

--number of books per catagory
create function bookCountByCategory (@CategoryType nvarchar(30))
Returns int
AS
BEGIN
	DECLARE @BookCount int;
	SELECT @BookCount = COUNT(book.id) 
	FROM book
		INNER JOIN catagory ON book.catagory_id = catagory.id
			WHERE catagory.category_type = @CategoryType;
	RETURN @BookCount;
END

-----Example
SELECT id, category_type, dbo.bookCountByCategory(category_type) AS
'Book Count'
FROM catagory
ORDER BY 'Book Count' DESC

-- total payment amount for a certain member 
create function paymentByMember (@MemberID int)
Returns MONEY
AS
BEGIN
	DECLARE @totalAmount MONEY;
	SELECT @totalAmount = SUM(payment_amount)
	FROM payment
		WHERE member_id = @MemberID;
	RETURN @totalAmount;
END

-----Example
SELECT member_id, dbo.paymentByMember(member_id) AS
'Total Payment'
FROM payment
GROUP BY member_id
ORDER BY 'Total Payment' DESC


-- total penalty amount library received from from penalty payment

create function totalPenaltyAmount ()
Returns MONEY
AS
BEGIN
	DECLARE @totalAmount MONEY;
	SELECT @totalAmount = SUM(penalty_amount)
	FROM penalty
	RETURN @totalAmount;
END

-----Example
SELECT dbo.totalPenaltyAmount() AS
'Total Penalty Payment'
FROM penalty
GROUP BY penalty_amount


--- Membership validaty date]

create function membershipValidity(@MemberID INT)
Returns Varchar(30)
AS
BEGIN
	DECLARE @NumberOfDays INT
	SELECT @NumberOfDays = DATEDIFF(DAY, GETDATE(), end_date) 
	FROM member
		WHERE DATEDIFF(DAY, GETDATE(), end_date) > 0 
			AND member.id = @MemberID ;
	RETURN @NumberOfDays;
END

-----Example
SELECT id, first_name, last_name,
case 
When dbo.membershipValidity(id) IS NULL THEN 'Expired' ELSE dbo.membershipValidity(id)
END
AS 'Days Till Expiry'
FROM member


-----views
--book with publication year
CREATE VIEW bookPublicationYear AS
SELECT book_title, publication_year
FROM book

Select * FROM bookPublicationYear

--book with author name
CREATE VIEW bookAuthor AS
SELECT book_title AS 'Book Title', author.first_name AS 'Author First Name', author.last_name AS 'Author Last Name'
FROM book
	INNER JOIN book_author ON  book.id = book_author.book_id
	INNER JOIN author ON author.id = book_author.author_id

SELECT * FROM bookAuthor

-- book by category
CREATE VIEW bookCategory AS
SELECT book_title AS 'Book Title', category_type AS 'Category'
FROM book
	INNER JOIN catagory ON book.catagory_id = catagory.id

SELECT * FROM bookCategory

-- Membership join and expiry
CREATE VIEW membership AS
SELECT id AS 'Member ID', first_name AS 'First Name', last_name AS 'Last Name'
	, join_date AS 'Join Date', end_date AS 'Membership Expiry Date'
FROM member

SELECT * FROM membership


-- Member Status
CREATE VIEW MemberStatus AS
SELECT member.id AS 'Member ID', first_name AS 'First Name', last_name AS 'Last Name'
	, activity_status.status_type AS 'Status Type'
FROM member
	INNER JOIN activity_status ON member.status_id = activity_status.id

SELECT * FROM MemberStatus

--- member with penalty
CREATE VIEW MemberPenalty AS
SELECT member.id AS 'Member ID', first_name AS 'First Name', last_name AS 'Last Name'
	, penalty.penalty_date, penalty.penalty_amount
FROM member
	INNER JOIN penalty ON penalty.member_id = member.id

SELECT * FROM MemberPenalty