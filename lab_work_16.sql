-- Практика 16. Імпорт даних із CSV у SQLite (варіант "Бібліотека", цільова таблиця books)
-- Таблиця books: id (PRIMARY KEY), title, author, publication_year, genre, copies_count
-- Файл CSV: 8 нових книг, колонки title,author,publication_year,genre,copies_count (без id)

-- ===== Завдання 1. Підрахунок до імпорту =====
SELECT COUNT(*) FROM books;
-- результат: 7

-- ===== Завдання 2. Проміжна таблиця й імпорт CSV =====
CREATE TABLE books_staging (
    title            TEXT,
    author           TEXT,
    publication_year INTEGER,
    genre            TEXT,
    copies_count     INTEGER
);

-- Імпорт CSV у проміжну таблицю (це не SQL, а окрема дія):
--   консоль sqlite3:   .mode csv
--                      .import --skip 1 new_books_standin.csv books_staging
--   DB Browser:        Файл -> Імпорт -> Таблиця з CSV-файлу, ім'я таблиці books_staging,
--                      "Назви стовпців у першому рядку" увімкнено, роздільник "кома"

-- перевірка вмісту проміжної таблиці:
SELECT * FROM books_staging;
-- результат: 8 рядків, рядка із заголовками серед них немає;
--            "Хіба ревуть воли, як ясла повні?" лишилась одним значенням у колонці title (завдяки лапкам)

-- ===== Завдання 3. Перенесення в реальну таблицю =====
INSERT INTO books (title, author, publication_year, genre, copies_count)
SELECT title, author, publication_year, genre, copies_count FROM books_staging;

DROP TABLE books_staging;

SELECT COUNT(*) FROM books;
-- результат: 15  (було 7, приріст 8 = кількості рядків у CSV)

-- ===== Завдання 4. Перевірка конкретних нових рядків =====
SELECT id, title, author
FROM books
WHERE id > 7;
-- результат: 8 рядків з id 8, 9, 10, 11, 12, 13, 14, 15 - нумерація продовжила попередню (1-7)
SELECT MIN(id), MAX(id), COUNT(*) FROM books WHERE id > 7;
-- результат: 8 | 15 | 8

-- ===== Завдання 5. Свідома помилка прямого імпорту (ТІЛЬКИ на окремій копії бази!) =====
-- У консолі sqlite3 на копії файлу бази (наприклад, test_copy.db):
--   .mode csv
--   .import --skip 1 new_books_standin.csv books
-- Очікуваний вивід (за теорією практики; впишіть свій реальний, якщо він відрізняється):
--   new_books_standin.csv:2: expected 6 columns but found 5 - filling the rest with NULL
--   new_books_standin.csv:2: INSERT failed: datatype mismatch
--   (так само для рядків 3-9)
-- Перевірка на копії: SELECT COUNT(*) FROM books;  -- лишилось 7, жоден рядок не додався
-- Причина (перевірено в SQLite): значення зсуваються на колонку вліво, назва книги потрапляє в id,
-- а id приймає лише ціле число:
--   INSERT INTO books VALUES ('Лісова пісня','Леся Українка','1911','драма','3',NULL);
--   -> Error: datatype mismatch
