--use case 1: Search authors and get the list of their books (input author name) [book_author, book, author]
CREATE PROCEDURE spGetAuthor @Author NVARCHAR(50) 
AS 
BEGIN
	SELECT book_title, author.first_name, author.last_name
	FROM book
		INNER JOIN book_author ON  book.id = book_author.book_id
		INNER JOIN author ON author.id = book_author.author_id
			WHERE author.first_name LIKE @Author + '%' 
				OR  author.last_name LIKE @Author + '%'
END

EXECUTE spGetAuthor @Author = 'C';

--use case 2: Fetch total number of books based on catagory (Output book) [book, catagory]
CREATE PROCEDURE spGetBookCatagory @CatagoryType NVARCHAR(30), 
	@BookCount INT OUTPUT
AS
BEGIN
	SELECT @BookCount = COUNT(book.id) 
	FROM book
		INNER JOIN catagory ON catagory.id = book.catagory_id
			where catagory.category_type =@CatagoryType;
END

DECLARE @TotalBookCount INT
EXECUTE spGetBookCatagory @CatagoryType = 'fiction', @BookCount = @TotalBookCount OUTPUT
PRINT @TotalBookCount

--Use case 3: get member information by their id (input memberid) [member]
CREATE PROCEDURE spMemberInfo @MemberID INT
AS
BEGIN
	SELECT * FROM member
		WHERE member.id  = @MemberID
END

EXECUTE spMemberInfo @MemberID = '10002'

--use case 4: get total number of members by activity status (output total number of members) [activity_status, member]
CREATE PROCEDURE spGetActivityStatus @StatusType nvarchar(30), @MemberCount int OUTPUT
AS
BEGIN
	SELECT @MemberCount = COUNT(member.id) 
	FROM member
		INNER JOIN activity_status ON member.status_id = activity_status.id
			WHERE activity_status.status_type = @StatusType;
END

DECLARE @TotalMemberCount int
EXECUTE spGetActivityStatus @StatusType = 'suspended', @MemberCount = @TotalMemberCount OUTPUT
PRINT @TotalMemberCount

--use case 5: Get members list by activity status (Input activity status type) [activity_status, member]
CREATE PROCEDURE spGetMembersByActivityStatus (@StatusType nvarchar(30))
AS
BEGIN
	SELECT member.id, first_name, last_name, phone, email, 
	join_date, end_date, activity_status.status_type 
	FROM member
		INNER JOIN activity_status ON member.status_id = activity_status.id
			WHERE activity_status.status_type = @StatusType;
END

EXECUTE spGetMembersByActivityStatus @StatusType = 'suspended';

--use case 6: Find books by title (Input book title)
CREATE PROCEDURE spGetBookBYTitle @BookTitle NVARCHAR(50) 
AS 
BEGIN
	SELECT book.id AS bookID, book_title, publisher, publication_year, copies_available 
	FROM book
		INNER JOIN catagory ON catagory.id = book.catagory_id
		INNER JOIN book_status ON book_status.id = book.book_status_id
		WHERE book_title LIKE @BookTitle + '%'
END

EXECUTE spGetBookBYTitle @BookTitle = 'T';

--use case 7: Find total number of members who borrowed a certain book (output number of members) [book, member, issuing_record]
CREATE PROCEDURE spNumberOfMembersByBookBorrowed @bookID INT,
  @MemberCount INT OUTPUT
AS
BEGIN
	SELECT @MemberCount = COUNT(member.id)
	FROM member
		INNER JOIN issuing_record ON member_id = member.id
			WHERE book_id = @bookID;
END

DECLARE @TotalNumberMembers INT
EXECUTE spNumberOfMembersByBookBorrowed @bookID = 100004, @MemberCount = @TotalNumberMembers  OUTPUT
PRINT @TotalNumberMembers

--use case 8: Get list of members who borrowed a certain book (output members) [member, issuing_record]
SELECT member.first_name, member.last_name, member.id
FROM member
INNER JOIN issuing_record ON member_id = member.id
WHERE book_id = 100004;

CREATE PROCEDURE spGetMembersByBookBorrowed (@bookID INT)
AS
BEGIN
	SELECT member.first_name, member.last_name, member.id AS 'MemberID'
	FROM member
		INNER JOIN issuing_record ON member_id = member.id
		WHERE book_id = @bookID;
END

EXECUTE spGetMembersByBookBorrowed @bookID = 100004;

--use case 9: Find total amount  a member is penalized for not returning books in time (output penalty amount) [penalty]
CREATE PROCEDURE spTotalPenaltyAmount @MemberID INT,
  @TotalAmount Money OUTPUT
AS
BEGIN
	SELECT @TotalAmount = SUM(penalty_amount) 
	FROM penalty
	WHERE member_id = @MemberID;
END

DECLARE @TotalPenaltyAmount INT
EXECUTE spTotalPenaltyAmount 10006, @TotalAmount = @TotalPenaltyAmount  OUTPUT
PRINT @TotalPenaltyAmount

--use case 10: Get the list of books by year (input year range) [book]
CREATE PROCEDURE spBooksByYear(@StartYear INT, @EndYear INT )
AS
BEGIN
	SELECT book.book_title, publication_year 
	FROM book
	WHERE publication_year > @StartYear AND publication_year<@EndYear ;
END

EXECUTE spBooksByYear @StartYear = 1990, @EndYear = 2000;

--use case 11: payment history for a given member (input memberID) [member, payment]
CREATE PROCEDURE spPaymentHistoryMember(@MemberID INT)
AS
BEGIN
	SELECT payment_amount, payment_date
	FROM payment
		WHERE member_id = @MemberID;
END

EXECUTE spPaymentHistoryMember @MemberID = 10002;

--use case 12: see all the books borrowed by a user previously and currently (input memberID) [book, member, issuing_record]
CREATE PROCEDURE spBooksBorrwedByMember(@MemberID INT)
AS
BEGIN
	SELECT book_title, publisher, publication_year, 
	issuing_record.issue_date, issuing_record.returned_date 
	FROM book
		INNER JOIN issuing_record ON book.id = issuing_record.book_id
			WHERE member_id = @MemberID;
END

EXECUTE spBooksBorrwedByMember @MemberID = 10006;

--use case 13: Find total number of books by publication year range (output number of books) [book]
CREATE PROCEDURE spNumberOfBooksByYear 
	@StartYear INT, @EndYear INT,
	@NumberOfBooks INT OUTPUT

AS
BEGIN
	SELECT @NumberOfBooks = COUNT(book.id) 
	FROM book
		WHERE publication_year > @StartYear 
			AND publication_year<@EndYear ;
END

DECLARE @TotalNumberOfBooks INT
EXECUTE spNumberOfBooksByYear 1990, 2000, @NumberOfBooks = @TotalNumberOfBooks OUTPUT
PRINT @TotalNumberOfBooks


--use case 14: Find the number of copies a certain book has (input bookid) [book]
CREATE PROCEDURE spNumberOfBookCopies(@BookID INT)
AS
BEGIN
	SELECT book_title, publisher, publication_year, copies_available 
	FROM book
		WHERE book.id = @BookID;
END

EXECUTE spNumberOfBookCopies @BookID = 100005;

--use case 15: Get the remaining days for membership expiry for a member (output remaining days to expire) [member]
CREATE PROCEDURE spGetRemainingDays
@MemberID INT,
@NumberOfDays INT OUTPUT
AS
BEGIN
	SELECT @NumberOfDays = DATEDIFF(DAY, GETDATE(), end_date) 
	FROM member
		WHERE DATEDIFF(DAY, GETDATE(), end_date) > 0 
			AND member.id = @MemberID ;
END

DECLARE @RemainingDays INT
EXECUTE spGetRemainingDays @MemberID = 10000, @NumberOfDays = @RemainingDays OUTPUT
PRINT @RemainingDays;

--use case 16: Find members whose membership will expire in the upcoming months (Input month) [member]
CREATE PROCEDURE spGetMembershiExpiry (@EndMonth INT)
AS
BEGIN
	SELECT id, DATEDIFF(MONTH, GETDATE(), end_date) AS 'Remaining Months' 
	FROM member
		WHERE DATEDIFF(MONTH, GETDATE(), end_date) > 0 
			AND DATEDIFF(MONTH, GETDATE(), end_date) <= @EndMonth;
END

EXECUTE spGetMembershiExpiry @EndMonth = 10;