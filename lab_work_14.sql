-- Практика 14. Створення та відкат транзакцій (варіант "Бібліотека")
-- Таблиці: books (copies_count - скільки примірників), readers, loans (видачі)
-- Стан бази перед початком: loans = 10 рядків; books: Кобзар 3, Тигролови 2, Захар Беркут 4,
--   Земля 2, Місто 2, Собор 3, Українська мова. Практикум 2; readers = 7 рядків
PRAGMA foreign_keys = ON;

-- ===== Завдання 1. Атомарна пара INSERT + UPDATE (видати книгу "Собор" читачці 1) =====
BEGIN;
INSERT INTO loans (book_id, reader_id, loan_date) VALUES (6, 1, '2026-11-03');
UPDATE books SET copies_count = copies_count - 1 WHERE id = 6;
COMMIT;
-- перевірка:
SELECT COUNT(*) FROM loans;                                   -- результат: 11
SELECT id, book_id, reader_id, loan_date, return_date FROM loans WHERE id = 11;
                                                              -- результат: 11 | 6 | 1 | 2026-11-03 | NULL
SELECT copies_count FROM books WHERE id = 6;                  -- результат: 2 (було 3)

-- ===== Завдання 2. Свідомий ROLLBACK (спроба видати "Кобзар" читачу 2) =====
BEGIN;
INSERT INTO loans (book_id, reader_id, loan_date) VALUES (1, 2, '2026-11-03');
UPDATE books SET copies_count = copies_count - 1 WHERE id = 1;
ROLLBACK;
-- перевірка:
SELECT COUNT(*) FROM loans;                                   -- результат: 11 (рядка не додалось, було 11)
SELECT copies_count FROM books WHERE id = 1;                  -- результат: 3 (лічильник не змінився)

-- ===== Завдання 3. Проміжний стан усередині транзакції =====
SELECT copies_count FROM books WHERE id = 2;                  -- результат до BEGIN: 2
BEGIN;
UPDATE books SET copies_count = copies_count - 1 WHERE id = 2;
SELECT copies_count FROM books WHERE id = 2;                  -- результат ВСЕРЕДИНІ транзакції: 1 (свою зміну бачу)
ROLLBACK;
SELECT copies_count FROM books WHERE id = 2;                  -- результат після ROLLBACK: 2 (повернулось)

-- ===== Завдання 4. Свідома помилка всередині транзакції =====
BEGIN;
UPDATE books SET copies_count = copies_count - 1 WHERE id = 5;              -- успішна зміна
INSERT INTO readers (full_name, email) VALUES ('Тест Дублікат', 'olena.k@example.com');
-- ПОМИЛКА: UNIQUE constraint failed: readers.email   (такий email уже є у читачки 1)
SELECT copies_count FROM books WHERE id = 5;                  -- результат: 1 (перша зміна ПРИСУТНЯ, транзакція ще відкрита)
SELECT COUNT(*) FROM readers;                                 -- результат: 7 (рядок з помилкою не додався)
ROLLBACK;
SELECT copies_count FROM books WHERE id = 5;                  -- результат після ROLLBACK: 2 (скасовано)

-- ===== Завдання 5. Забутий ROLLBACK: той самий сценарій, але COMMIT =====
BEGIN;
UPDATE books SET copies_count = copies_count - 1 WHERE id = 5;              -- успішна зміна
INSERT INTO readers (full_name, email) VALUES ('Тест Дублікат', 'olena.k@example.com');
-- ПОМИЛКА: UNIQUE constraint failed: readers.email
COMMIT;
-- перевірка:
SELECT copies_count FROM books WHERE id = 5;                  -- результат: 1 (перша зміна ЗАФІКСУВАЛАСЬ)
SELECT COUNT(*) FROM readers;                                 -- результат: 7 (другої зміни немає)

-- Фінальний стан: loans = 11 рядків; books: Кобзар 3, Тигролови 2, Захар Беркут 4, Земля 2,
--   Місто 1 (зменшено у Завданні 5), Собор 2 (Завдання 1), Українська мова. Практикум 2; readers = 7
