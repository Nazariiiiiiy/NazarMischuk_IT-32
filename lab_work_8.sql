-- Завдання 1
SELECT COUNT(*) AS усього_рядків, COUNT(return_date) AS з_датою_повернення, COUNT(id) AS за_id FROM loans;

-- Завдання 2
SELECT SUM(copies_count) AS всього_примірників, AVG(copies_count) AS середнє_на_книгу FROM books;


-- Завдання 3
SELECT MIN(loan_date) AS перша_видача, MAX(loan_date) AS остання_видача FROM loans;

SELECT MIN(title) AS перша_за_алфавітом, MAX(title) AS остання_за_алфавітом FROM books;


-- Завдання 4
SELECT COUNT(*) AS усього_видач, COUNT(return_date) AS повернуто,
       COUNT(*) - COUNT(return_date) AS на_руках,
       MIN(loan_date) AS перша_видача, MAX(loan_date) AS остання_видача
FROM loans;


-- Завдання 5
SELECT COUNT(*) AS усього_видач, COUNT(loans.return_date) AS повернуто
FROM loans INNER JOIN books ON loans.book_id = books.id
WHERE books.genre = 'роман';


-- Контрольне питання 3: усі значення NULL
SELECT SUM(return_date) AS сума, AVG(return_date) AS середнє, COUNT(return_date) AS кількість
FROM loans WHERE return_date IS NULL;
