USE assignment5;  
-- Easy-Level Queries

-- Q1 Fetch all student names and their class.
SELECT name, class FROM students; 

-- Q2 List all books with their titles and authors.
SELECT title, author FROM books; 

-- Q3: Display all records from the issued_books table
SELECT * FROM issued_books;

-- Q4: Fetch student details where age is greater than 15
SELECT * FROM students WHERE age > 15;

-- Q5: Count the number of books in the library
SELECT COUNT(*) AS total_books FROM books;

-- Q6: Find books published after 2015
SELECT * FROM books WHERE publication_year > 2015;

-- Q7: List students whose name starts with 'A'
SELECT * FROM students WHERE name LIKE 'A%';

-- Q8: Get all unique genres from books table
SELECT DISTINCT genre FROM books;

-- Q9: List book titles with 5 or more copies
SELECT title FROM books WHERE copies_available >= 5;

-- Q10: Show issued_books after 2023-01-01
SELECT * FROM issued_books WHERE issue_date > '2023-01-01';

-- Q11: Count how many books have been issued
SELECT COUNT(*) AS total_issued_books FROM issued_books;

-- Q12: Get students in class '10' or Sophmore
SELECT * FROM students WHERE class = 'Sophmore';

-- Q13: Get email of students aged 18 and above
SELECT email FROM students WHERE age >= 18;

-- Q14: List book titles and authors ordered by pub_year
SELECT title, author FROM books ORDER BY publication_year;

-- Q15: List all distinct classes
SELECT DISTINCT class FROM students;

-- Q16: Show issue and return date for sid = 101
SELECT issue_date, return_date FROM issued_books WHERE student_id = 1;

-- Q17: Get the oldest book by pub_year
SELECT * FROM books ORDER BY publication_year ASC LIMIT 1;

-- Q18: Count students per class
SELECT class, COUNT(*) AS student_count FROM students GROUP BY class;

-- Q19: Show all books with genre 'Fiction'
SELECT * FROM books WHERE genre = 'Fiction';

-- Q20: Get students aged between 14 and 18
SELECT * FROM students WHERE age BETWEEN 14 AND 18;

-- Moderate-Level Queries
-- Q1: Fetch book details for all books issued in the last 30 days
SELECT b.*
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
WHERE ib.issue_date >= CURDATE() - INTERVAL 30 DAY;

-- Q2: List students who have never issued a book
SELECT *
FROM students
WHERE student_id NOT IN (SELECT student_id FROM issued_books);

-- Q3: Count the number of books issued per student
SELECT student_id, COUNT(*) AS issued_count
FROM issued_books
GROUP BY student_id;

-- Q4: Fetch the name and email of students who issued the book with book_id = 2
SELECT s.name, s.email
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
WHERE ib.book_id = 2;


-- Q5: Find the most popular book (most issued)
SELECT b.title, COUNT(*) AS issue_count
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
GROUP BY b.book_id, b.title
ORDER BY issue_count DESC
LIMIT 1;

-- Q6: Fetch books that have never been issued
SELECT *
FROM books
WHERE book_id NOT IN (SELECT book_id FROM issued_books);

-- Q7: Display students along with the titles of books they have issued
SELECT s.name, b.title
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
JOIN books b ON b.book_id = ib.book_id;

-- Q8: Find books that have been issued but not yet returned
SELECT b.*
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
WHERE ib.return_date IS NULL;

-- Q9: Retrieve the latest book issued by each student
SELECT s.student_id, s.name, b.title, MAX(ib.issue_date) AS latest_issue
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
JOIN books b ON b.book_id = ib.book_id
GROUP BY s.student_id, s.name, b.title;

-- Q10: Get the total number of copies available for each genre
SELECT genre, SUM(copies_available) AS total_copies
FROM books
GROUP BY genre;

-- Q11: List students who have issued more than two books
SELECT s.*
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
GROUP BY s.student_id
HAVING COUNT(ib.issue_id) > 2;

-- Q12: Fetch the details of the most recent book issued
SELECT b.*
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
ORDER BY ib.issue_date DESC
LIMIT 1;

-- Q13: Find books authored by more than one author (assumes comma-separated author field)
SELECT *
FROM books
WHERE author LIKE '%,%';

-- Q14: List students along with the count of books issued by them
SELECT s.name, COUNT(ib.book_id) AS books_issued
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
GROUP BY s.student_id, s.name;

-- Q15: Find the student who issued the most books
SELECT s.name, COUNT(ib.issue_id) AS total_issued
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
GROUP BY s.student_id, s.name
ORDER BY total_issued DESC
LIMIT 1;

-- Q16: Retrieve books where publication_year is between 2000 and 2020
SELECT *
FROM books
WHERE publication_year BETWEEN 2000 AND 2020;

-- Q17: Get the issue count for books by genre
SELECT b.genre, COUNT(ib.issue_id) AS issue_count
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
GROUP BY b.genre;

-- Q18: Find all students who have issued books in the 'Science Fiction' genre
SELECT DISTINCT s.*
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
JOIN books b ON b.book_id = ib.book_id
WHERE b.genre = 'Science Fiction';

-- Q19: Find the book that was last issued
SELECT b.*
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
ORDER BY ib.issue_date DESC
LIMIT 1;

-- Q20: Fetch students who returned books late (assuming 14-day return policy)
SELECT s.*
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
WHERE DATEDIFF(ib.return_date, ib.issue_date) > 14;


-- Q1: List the top 3 most popular genres based on book issue_id
SELECT b.genre, COUNT(ib.issue_id) AS issue_count
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
GROUP BY b.genre
ORDER BY issue_count DESC
LIMIT 3;

-- Q2: Fetch student details along with the titles of books issued and returned late (assuming 14-day policy)
SELECT s.*, b.title, ib.issue_date, ib.return_date
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
JOIN books b ON b.book_id = ib.book_id
WHERE DATEDIFF(ib.return_date, ib.issue_date) > 14;

-- Q3: Find students who issued all available books from a specific genre (e.g., 'History')
SELECT s.student_id, s.name
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id -- Common colum in student and issued_books
JOIN books b ON b.book_id = ib.book_id
WHERE b.genre = 'Fiction'
GROUP BY s.student_id, s.name
HAVING COUNT(DISTINCT b.book_id) = (
    SELECT COUNT(*) FROM books WHERE genre = 'Fiction'
);

-- Q4: Calculate the average issue duration for all returned books
SELECT AVG(DATEDIFF(return_date, issue_date)) AS avg_duration_days
FROM issued_books
WHERE return_date IS NOT NULL;

-- Q5: Find the student who issued books for the longest total duration
SELECT s.name, SUM(DATEDIFF(ib.return_date, ib.issue_date)) AS total_days
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
WHERE ib.return_date IS NOT NULL
GROUP BY s.student_id, s.name
ORDER BY total_days DESC
LIMIT 1;

-- Q6: Identify books that have been issued exactly three times
SELECT b.title, COUNT(ib.issue_id) AS times_issued
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
GROUP BY b.book_id, b.title
HAVING times_issued = 3;

-- Q7: List students who issued books across all available genres
SELECT s.student_id, s.name
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
JOIN books b ON b.book_id = ib.book_id
GROUP BY s.student_id, s.name
HAVING COUNT(DISTINCT b.genre) = (SELECT COUNT(DISTINCT genre) FROM books);

-- Q8: Fetch the top 5 books with the longest average issue duration
SELECT b.title, AVG(DATEDIFF(ib.return_date, ib.issue_date)) AS avg_duration
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
WHERE ib.return_date IS NOT NULL
GROUP BY  b.book_id,b.title
ORDER BY avg_duration DESC
LIMIT 5;

-- Q9: Find students who have issued more than one book and returned all of them late
SELECT s.student_id, s.name
FROM students s
JOIN issued_books ib ON s.student_id = ib.student_id
WHERE ib.return_date IS NOT NULL
GROUP BY s.student_id, s.name -- connected things 
HAVING COUNT(ib.issue_id) > 1 AND -- count only if they have issued for more than 1 Book
       SUM(DATEDIFF(ib.return_date, ib.issue_date) > 14) = COUNT(ib.issue_id);

-- Q10: Identify the book with the highest number of unique student issues
SELECT b.title, COUNT(DISTINCT ib.student_id) AS unique_students
FROM books b
JOIN issued_books ib ON b.book_id = ib.book_id
GROUP BY b.book_id, b.title
ORDER BY unique_students DESC
LIMIT 1;
















