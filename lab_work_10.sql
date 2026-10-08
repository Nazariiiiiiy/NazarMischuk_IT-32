-- Практика 10. Відбір груп за допомогою HAVING
-- Схема: books (вимір 1), readers (вимір 2), loans (факт)

-- Завдання 1: HAVING на COUNT (книги, які видавали більше 1 разу)
SELECT books.title AS книга, COUNT(*) AS кількість_видач
FROM books
JOIN loans ON loans.book_id = books.id
GROUP BY books.id
HAVING COUNT(*) > 1;
-- результат (4 рядки): Кобзар 2; Тигролови 2; Захар Беркут 2; Земля 2

-- Завдання 2: HAVING на MAX (читачі, чия остання видача не раніше 2026-05-01)
SELECT readers.full_name AS читач, MAX(loans.loan_date) AS остання_видача
FROM readers
JOIN loans ON loans.reader_id = readers.id
GROUP BY readers.id
HAVING MAX(loans.loan_date) >= '2026-05-01';
-- результат (2 рядки): Максим Бондар 2026-06-01; Павло Крамар 2026-05-10

-- Завдання 3: WHERE + GROUP BY + HAVING
-- WHERE відкидає видачі до лютого, HAVING залишає книги, що мають 2 і більше видач після цього
SELECT books.title AS книга, COUNT(*) AS видач_з_лютого
FROM books
JOIN loans ON loans.book_id = books.id
WHERE loans.loan_date >= '2026-02-01'
GROUP BY books.id
HAVING COUNT(*) >= 2;
-- результат (3 рядки): Тигролови 2; Захар Беркут 2; Земля 2
-- (Кобзар випав: його видача 2026-01-05 відсіяна WHERE, лишилась одна)

-- Завдання 4: свідома помилка (агрегат у WHERE) - ВИКОНАТИ ВРУЧНУ в DB Browser, у файлі закоментовано
-- SELECT book_id, COUNT(*) FROM loans WHERE COUNT(*) > 1 GROUP BY book_id;
-- текст помилки SQLite: misuse of aggregate: COUNT()

-- Завдання 5: LEFT JOIN + GROUP BY + HAVING (книги з кількістю видач менше 2, включно з 0)
SELECT books.title AS книга, COUNT(loans.id) AS кількість_видач
FROM books
LEFT JOIN loans ON loans.book_id = books.id
GROUP BY books.id
HAVING COUNT(loans.id) < 2;
-- результат (3 рядки): Місто 1; Собор 1; Українська мова. Практикум 0
