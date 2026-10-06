PRAGMA foreign_keys = ON;

-- Завдання 1. UPDATE у фактовій таблиці (заповнюємо return_date, що був NULL)
UPDATE loans SET return_date = '2026-02-15' WHERE id = 2;

-- Завдання 2. UPDATE у таблиці-вимірі (змінюємо кількість примірників)
UPDATE books SET copies_count = copies_count - 1 WHERE id = 2;

-- Завдання 3. DELETE одного рядка з фактової таблиці
SELECT COUNT(*) FROM loans;
DELETE FROM loans WHERE id = 9;
SELECT COUNT(*) FROM loans;

-- Завдання 4. Перевірка ON DELETE (reader_id -> CASCADE)
DELETE FROM readers WHERE id = 1;
