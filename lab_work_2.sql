-- Практика 2. Формування запитів вибірки у SQLite
-- Варіант 1: таблиця-вимір books
-- Схема таблиці не змінюється, працюємо з тими самими даними, що й у Практиці 1.
--
-- Реальна структура таблиці (перевірено за DB Browser):
-- books(id INTEGER, title TEXT, author TEXT, publication_year INTEGER,
--       genre TEXT, copies_count INTEGER)


-- =========================================================
-- Завдання 1. SELECT з явним переліком стовпців
-- =========================================================
SELECT title, author, publication_year
FROM books;


-- =========================================================
-- Завдання 2. WHERE за умовою свого варіанта
-- Для books природна умова — publication_year або copies_count.
-- Тут: книги, видані після 2010 року.
-- =========================================================
SELECT title, publication_year
FROM books
WHERE publication_year > 2010;


-- =========================================================
-- Завдання 3. LIMIT
-- Перші 5 записів таблиці
-- =========================================================
SELECT title, author, publication_year
FROM books
LIMIT 5;


-- =========================================================
-- Завдання 4. IS NULL / IS NOT NULL
-- Стовпець genre реалістично може бути невідомим
-- (наприклад, книгу ще не встигли класифікувати за жанром).
-- =========================================================

-- Крок 1: додаємо новий рядок, де genre = NULL
INSERT INTO books (title, author, publication_year, genre, copies_count)
VALUES ('Невідома назва', 'Невідомий автор', 2023, NULL, 2);

-- Крок 2: запит з IS NULL
SELECT title, genre
FROM books
WHERE genre IS NULL;

-- Крок 3: запит з IS NOT NULL
SELECT title, genre
FROM books
WHERE genre IS NOT NULL;

-- Пояснення (детальніше в lab_work_2.md):
-- WHERE genre = NULL ніколи не спрацює, бо порівняння з NULL завжди
-- повертає NULL (невідомо), а не TRUE. Тому потрібен спеціальний
-- оператор IS NULL / IS NOT NULL, який перевіряє саме відсутність значення.


-- =========================================================
-- Завдання 5. Складена умова (AND)
-- Книги, видані після 2010 року, з кількістю примірників більше 1
-- =========================================================
SELECT title, publication_year, copies_count
FROM books
WHERE publication_year > 2010 AND copies_count > 1;
