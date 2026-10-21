-- Практика 13. Форматування таблиць за допомогою printf і дат (варіант "Бібліотека")
-- Схема: books (вимір 1), readers (вимір 2), loans (факт). Структура не змінювалась.
-- Числова колонка для printf: books.copies_count (ціла), дата: loans.loan_date

-- Завдання 1: printf() для числової колонки
SELECT title AS книга,
       copies_count AS сире_значення,
       printf('%d прим.', copies_count) AS відформатоване
FROM books;
-- результат (7 рядків): Кобзар 3 | 3 прим.; Тигролови 2 | 2 прим.; Захар Беркут 4 | 4 прим.;
-- Земля 2 | 2 прим.; Місто 2 | 2 прим.; Собор 3 | 3 прим.; Українська мова. Практикум 2 | 2 прим.

-- додатково: шаблон '%.2f' для дробового значення (середнє число примірників)
SELECT AVG(copies_count) AS сире, printf('%.2f прим.', AVG(copies_count)) AS відформатоване FROM books;
-- результат: 2.5714285714285716 | 2.57 прим.

-- перевірка типів: printf повертає текст, а не число
SELECT typeof(copies_count) AS тип_колонки, typeof(printf('%d прим.', copies_count)) AS тип_результату
FROM books LIMIT 1;
-- результат: integer | text

-- Завдання 2: printf() з мінімальною шириною поля
SELECT title AS книга,
       printf('%3d', copies_count) AS ширина_3,
       printf('%05d', id) AS код_з_нулями
FROM books;
-- результат: Кобзар |   3 | 00001; Тигролови |   2 | 00002; Захар Беркут |   4 | 00003; ...
-- додатково: ширина для дробового та для тексту (дужки показують межі поля)
SELECT '[' || printf('%8.2f', AVG(copies_count)) || ']' AS дробове_8,
       '[' || printf('%-10s', 'abc') || ']' AS вліво_10,
       '[' || printf('%10s', 'abc') || ']' AS вправо_10
FROM books;
-- результат: [    2.57] | [abc       ] | [       abc]

-- Завдання 3: зсув дати
SELECT id,
       loan_date AS дата_видачі,
       date(loan_date, '+14 days') AS повернути_до,
       date(loan_date, '+1 month') AS через_місяць
FROM loans;
-- результат (10 рядків), приклад: 1 | 2026-01-05 | 2026-01-19 | 2026-02-05
--                                 10 | 2026-06-01 | 2026-06-15 | 2026-07-01
-- зсув від return_date для неповернутих книг дає NULL (NULL + 30 днів = NULL):
SELECT id, return_date, date(return_date, '+30 days') FROM loans WHERE return_date IS NULL LIMIT 2;
-- результат: 2 | NULL | NULL;  4 | NULL | NULL

-- Завдання 4: strftime() + GROUP BY (за місяцем видачі)
SELECT strftime('%m', loan_date) AS місяць, COUNT(*) AS видач
FROM loans
GROUP BY strftime('%m', loan_date);
-- результат: 01|1; 02|2; 03|2; 04|2; 05|2; 06|1
-- те саме за роком (усі видачі в одному році):
SELECT strftime('%Y', loan_date) AS рік, COUNT(*) AS видач
FROM loans
GROUP BY strftime('%Y', loan_date);
-- результат: 2026|10
-- для порівняння: групування за повною датою дає 10 груп по 1 видачі
SELECT loan_date, COUNT(*) FROM loans GROUP BY loan_date;

-- Завдання 5: некоректна дата
SELECT strftime('%Y', 'not-a-date') AS a,
       date('not-a-date') AS b,
       strftime('%Y', '2026-13-45') AS c,
       strftime('%Y', '') AS d;
-- результат: NULL | NULL | NULL | NULL  (помилки немає)
SELECT title, strftime('%Y', title) FROM books LIMIT 2;
-- результат: Кобзар | NULL;  Тигролови | NULL
-- пастка: неіснуюча дата, яка "виглядає" правильно, НЕ дає NULL, а зсувається
SELECT date('2026-02-30') AS a, date('2026-02-31') AS b, date('2026-02-32') AS c, date('2026-04-31') AS d;
-- результат: 2026-03-02 | 2026-03-03 | NULL | 2026-05-01

-- Контрольне питання 2: strftime повертає текст
SELECT strftime('%Y', '2026-01-05') = 2026 AS з_числом,
       strftime('%Y', '2026-01-05') = '2026' AS з_текстом,
       CAST(strftime('%Y', '2026-01-05') AS INTEGER) = 2026 AS після_CAST,
       typeof(strftime('%Y', '2026-01-05')) AS тип;
-- результат: 0 | 1 | 1 | text
