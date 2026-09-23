-- Практика 5. Варіант 1 — Бібліотека
-- Обмеження цілісності: NOT NULL, UNIQUE, CHECK, DEFAULT
-- Продовження lab_work_4.db (таблиці books, readers, loans уже існують і заповнені)

PRAGMA foreign_keys = ON;

-- ВАЖЛИВО: за замовчуванням SQLite при RENAME TABLE автоматично переписує
-- FOREIGN KEY-посилання в інших таблицях (тут - у "loans") на нову назву.
-- Оскільки нижче books/readers перейменовуються тимчасово в *_old, це зламало б
-- зв'язки в "loans". PRAGMA legacy_alter_table = ON; вимикає цю автопідстановку.
PRAGMA legacy_alter_table = ON;

-- ==========================================================
-- Завдання 1. NOT NULL на books.author
-- ==========================================================
PRAGMA foreign_keys = OFF;

ALTER TABLE books RENAME TO books_old;

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,                 -- нове обмеження: Завдання 1
    publication_year INTEGER,
    genre TEXT,
    copies_count INTEGER NOT NULL DEFAULT 1
);

INSERT INTO books SELECT * FROM books_old;
DROP TABLE books_old;

PRAGMA foreign_keys = ON;

-- Перевірка Завдання 1: пропущено author -> очікується помилка
-- (розкоментуй і виконай окремо; результат зафіксовано в lab_work_5.md)
-- INSERT INTO books (title, publication_year, genre, copies_count)
-- VALUES ('Тестова книга без автора', 2020, 'проза', 1);


-- ==========================================================
-- Завдання 2. UNIQUE на readers.email
-- ==========================================================
PRAGMA foreign_keys = OFF;

ALTER TABLE readers RENAME TO readers_old;

CREATE TABLE readers (
    id                 INTEGER PRIMARY KEY,
    full_name          TEXT NOT NULL,
    phone              TEXT,
    email              TEXT UNIQUE,        -- нове обмеження: Завдання 2
    registration_date  TEXT
);

INSERT INTO readers SELECT * FROM readers_old;
DROP TABLE readers_old;

PRAGMA foreign_keys = ON;

-- Перевірка Завдання 2: email, що вже є в таблиці -> очікується помилка
-- (розкоментуй і виконай окремо; результат зафіксовано в lab_work_5.md)
-- INSERT INTO readers (full_name, phone, email, registration_date)
-- VALUES ('Тестовий Читач', '+380990000000', 'olena.k@example.com', '2026-06-01');


-- ==========================================================
-- Завдання 3. CHECK на books.copies_count
-- ==========================================================
PRAGMA foreign_keys = OFF;

ALTER TABLE books RENAME TO books_old;

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    publication_year INTEGER,
    genre TEXT,
    copies_count INTEGER NOT NULL DEFAULT 1 CHECK (copies_count >= 0)   -- нове обмеження: Завдання 3
);

INSERT INTO books SELECT * FROM books_old;
DROP TABLE books_old;

PRAGMA foreign_keys = ON;

-- Перевірка Завдання 3 (порушення): від'ємна кількість -> очікується помилка
-- INSERT INTO books (title, author, publication_year, genre, copies_count)
-- VALUES ('Тестова книга', 'Тест Автор', 2020, 'проза', -1);

-- Перевірка Завдання 3 (без порушення): коректна кількість -> виконується без помилок
-- INSERT INTO books (title, author, publication_year, genre, copies_count)
-- VALUES ('Українська мова. Практикум', 'Автор Тестовий', 2019, 'посібник', 2);


-- ==========================================================
-- Завдання 4. DEFAULT на readers.registration_date
-- ==========================================================
PRAGMA foreign_keys = OFF;

ALTER TABLE readers RENAME TO readers_old;

CREATE TABLE readers (
    id                 INTEGER PRIMARY KEY,
    full_name          TEXT NOT NULL,
    phone              TEXT,
    email              TEXT UNIQUE,
    registration_date  TEXT NOT NULL DEFAULT (date('now'))   -- нове обмеження: Завдання 4
);

INSERT INTO readers SELECT * FROM readers_old;
DROP TABLE readers_old;

PRAGMA foreign_keys = ON;

-- Перевірка Завдання 4: не вказуємо registration_date -> має підставитися сьогоднішня дата
-- INSERT INTO readers (full_name, phone, email)
-- VALUES ('Тестовий Читач Дефолт', '+380991112233', 'test.default@example.com');
-- SELECT full_name, registration_date FROM readers WHERE email = 'test.default@example.com';


-- ==========================================================
-- Завдання 4 (перевірка). Insert без registration_date + підтвердження SELECT
-- ==========================================================
INSERT INTO readers (full_name, phone, email)
VALUES ('Тестовий Читач Дефолт', '+380991112233', 'test.default@example.com');

SELECT full_name, registration_date
FROM readers
WHERE email = 'test.default@example.com';
-- Очікуваний результат: registration_date = сьогоднішня дата (підставлена DEFAULT)


-- ==========================================================
-- Завдання 3 (перевірка, коректний рядок - без порушення)
-- ==========================================================
INSERT INTO books (title, author, publication_year, genre, copies_count)
VALUES ('Українська мова. Практикум', 'Автор Тестовий', 2019, 'посібник', 2);


-- ==========================================================
-- Завдання 5. Порушення обмеження через UPDATE, а не INSERT
-- (беремо CHECK із Завдання 3: copies_count >= 0)
-- ==========================================================
UPDATE books SET copies_count = -5 WHERE id = 1;
-- Очікується: Runtime error: CHECK constraint failed: copies_count >= 0
-- Текст ідентичний тому, що виникає при порушенні через INSERT (Завдання 3) -
-- обмеження CHECK перевіряється при будь-якій зміні рядка, не лише при вставці.
