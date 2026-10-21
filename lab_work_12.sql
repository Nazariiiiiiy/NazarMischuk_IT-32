-- Практика 12. Сортування і фільтрація даних (ORDER BY, DISTINCT, BETWEEN, IN, LIKE)
-- Схема: books (вимір 1), readers (вимір 2), loans (факт). Структура не змінювалась.

-- Завдання 1: ORDER BY за однією колонкою, спадання (від найновішої видачі до найстарішої)
SELECT id, book_id, reader_id, loan_date
FROM loans
ORDER BY loan_date DESC;
-- результат: першим іде id=10 (книга 4, читач 2, 2026-06-01), останнім id=1 (2026-01-05)

-- Завдання 2: ORDER BY за двома колонками (спершу читач, у межах читача - нові видачі першими)
SELECT reader_id, loan_date, book_id
FROM loans
ORDER BY reader_id ASC, loan_date DESC;
-- результат (10 рядків):
-- 1 | 2026-02-01 | 2;  1 | 2026-01-05 | 1
-- 2 | 2026-06-01 | 4;  2 | 2026-02-10 | 3
-- 3 | 2026-03-15 | 4;  3 | 2026-03-01 | 1
-- 4 | 2026-04-02 | 5
-- 5 | 2026-04-20 | 6
-- 6 | 2026-05-10 | 3;  6 | 2026-05-01 | 2

-- Завдання 3: топ-3 найновіші видачі (ORDER BY ... DESC + LIMIT 3)
SELECT id, book_id, reader_id, loan_date
FROM loans
ORDER BY loan_date DESC
LIMIT 3;
-- результат: id=10 (2026-06-01), id=9 (2026-05-10), id=8 (2026-05-01)

-- для порівняння: LIMIT 3 без ORDER BY
SELECT id, loan_date
FROM loans
LIMIT 3;
-- результат: id=1 (2026-01-05), id=2 (2026-02-01), id=3 (2026-02-10) - це НАЙСТАРІШІ видачі, а не топ

-- Завдання 4а: DISTINCT на категорійній колонці виміру
SELECT DISTINCT genre FROM books;
-- результат: 6 унікальних жанрів: поезія, пригоди, історична проза, проза, роман, посібник
SELECT COUNT(DISTINCT genre) AS унікальних, COUNT(genre) AS усього_значень, COUNT(*) AS рядків FROM books;
-- результат: 6 | 7 | 7  (жанр "роман" повторюється двічі: Місто, Собор)

-- Завдання 4б: BETWEEN на числовій колонці (діапазон)
SELECT title, publication_year
FROM books
WHERE publication_year BETWEEN 1880 AND 1950
ORDER BY publication_year;
-- результат: Захар Беркут 1883; Земля 1902; Місто 1928; Тигролови 1944

-- Завдання 4б (додатково): IN на категорійній колонці (список значень)
SELECT title, genre
FROM books
WHERE genre IN ('роман', 'проза')
ORDER BY title;
-- результат: Земля (проза); Місто (роман); Собор (роман)

-- Завдання 5: LIKE і регістр кирилиці
SELECT full_name FROM readers WHERE full_name LIKE 'Олена%';
-- результат: 1 рядок (Олена Ковальчук)
SELECT full_name FROM readers WHERE full_name LIKE 'олена%';
-- результат: 0 рядків

SELECT title FROM books WHERE title LIKE 'З%';
-- результат: 2 рядки (Захар Беркут, Земля)
SELECT title FROM books WHERE title LIKE 'з%';
-- результат: 0 рядків

-- контроль на латиниці: LIKE регістронезалежний лише для ASCII
SELECT 'a' LIKE 'A' AS латиниця, 'о' LIKE 'О' AS кирилиця;
-- результат: 1 | 0
