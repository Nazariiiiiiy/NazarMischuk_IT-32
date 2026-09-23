-- Практика 4. Варіант 1 — Бібліотека
-- Увімкнення перевірки зовнішніх ключів (обов'язково на кожному новому з'єднанні)
PRAGMA foreign_keys = ON;

-- ========== Таблиця-вимір 1 (стан з Практики 1 / v1_prerequisites.sql) ==========
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT,
    publication_year INTEGER,
    genre TEXT,
    copies_count INTEGER NOT NULL DEFAULT 1
);

INSERT INTO books (title, author, publication_year, genre, copies_count) VALUES
    ('Кобзар', 'Тарас Шевченко', 1840, 'поезія', 3),
    ('Тигролови', 'Іван Багряний', 1944, 'пригоди', 2),
    ('Захар Беркут', 'Іван Франко', 1883, 'історична проза', 4),
    ('Земля', 'Ольга Кобилянська', 1902, 'проза', 2),
    ('Місто', 'Валер''ян Підмогильний', 1928, 'роман', 2),
    ('Собор', 'Олесь Гончар', 1968, 'роман', 3);

-- ========== Завдання 1. Таблиця-вимір 2 ==========
DROP TABLE IF EXISTS readers;
CREATE TABLE readers (
    id                 INTEGER PRIMARY KEY,
    full_name          TEXT NOT NULL,
    phone              TEXT,
    email              TEXT,
    registration_date  TEXT
);

-- ========== Завдання 2. Фактова таблиця з двома FOREIGN KEY ==========
DROP TABLE IF EXISTS loans;
CREATE TABLE loans (
    id         INTEGER PRIMARY KEY,
    book_id    INTEGER NOT NULL,
    reader_id  INTEGER NOT NULL,
    loan_date  TEXT NOT NULL,
    return_date TEXT,
    FOREIGN KEY (book_id)   REFERENCES books (id)   ON DELETE RESTRICT,
    FOREIGN KEY (reader_id) REFERENCES readers (id) ON DELETE CASCADE
);

-- ========== Завдання 3. Заповнення пов'язаними даними ==========
INSERT INTO readers (full_name, phone, email, registration_date) VALUES
    ('Олена Ковальчук', '+380501112233', 'olena.k@example.com', '2025-01-10'),
    ('Максим Бондар',   '+380672223344', 'maksym.b@example.com', '2025-02-15'),
    ('Ірина Ткаченко',  '+380933334455', 'iryna.t@example.com', '2025-03-02'),
    ('Андрій Мельник',  '+380964445566', 'andriy.m@example.com', '2025-03-20'),
    ('Софія Гнатюк',    '+380445556677', 'sofia.h@example.com', '2025-04-05'),
    ('Павло Крамар',    '+380976667788', 'pavlo.k@example.com', '2025-05-11');

INSERT INTO loans (book_id, reader_id, loan_date, return_date) VALUES
    (1, 1, '2026-01-05', '2026-01-20'),
    (2, 1, '2026-02-01', NULL),
    (3, 2, '2026-02-10', '2026-02-25'),
    (1, 3, '2026-03-01', NULL),
    (4, 3, '2026-03-15', '2026-03-30'),
    (5, 4, '2026-04-02', NULL),
    (6, 5, '2026-04-20', '2026-05-05'),
    (2, 6, '2026-05-01', NULL),
    (3, 6, '2026-05-10', '2026-05-25'),
    (4, 2, '2026-06-01', NULL);

-- ========== Завдання 4. Навмисна помилка зовнішнього ключа ==========
-- Розкоментуй і виконай окремо, щоб побачити помилку (нижче вона вже виконана і зафіксована в lab_work_4.md):
-- INSERT INTO loans (book_id, reader_id, loan_date) VALUES (9999, 1, '2026-06-15');
