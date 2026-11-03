-- Практика 15. Створення індексів та аналіз ефективності запитів (варіант "Бібліотека")
-- Таблиця loans (факт): id, book_id, reader_id, loan_date, return_date. Версія SQLite: 3.45.1
-- Перед початком у базі є лише службовий індекс sqlite_autoindex_readers_1 (від UNIQUE на readers.email).
-- На loans жодного індексу немає.

-- ===== Завдання 1. План до індексу =====
EXPLAIN QUERY PLAN
SELECT * FROM loans WHERE reader_id = 6;
-- план: SCAN loans

-- ===== Завдання 2. Індекс на зовнішньому ключі reader_id =====
CREATE INDEX idx_loans_reader ON loans(reader_id);

EXPLAIN QUERY PLAN
SELECT * FROM loans WHERE reader_id = 6;
-- план: SEARCH loans USING INDEX idx_loans_reader (reader_id=?)

-- ===== Завдання 3. Композитний індекс =====
-- запит з двома умовами: неповернуті книги читача 6
-- план ДО композитного (є лише індекс на reader_id):
EXPLAIN QUERY PLAN
SELECT * FROM loans WHERE reader_id = 6 AND return_date IS NULL;
-- план: SEARCH loans USING INDEX idx_loans_reader (reader_id=?)

CREATE INDEX idx_loans_reader_returned ON loans(reader_id, return_date);

-- план ПІСЛЯ композитного:
EXPLAIN QUERY PLAN
SELECT * FROM loans WHERE reader_id = 6 AND return_date IS NULL;
-- план: SEARCH loans USING INDEX idx_loans_reader_returned (reader_id=? AND return_date=?)

-- ===== Завдання 4. Індекс і ORDER BY =====
-- план ДО індексу на даті:
EXPLAIN QUERY PLAN
SELECT * FROM loans ORDER BY loan_date;
-- план: SCAN loans
--       USE TEMP B-TREE FOR ORDER BY

CREATE INDEX idx_loans_date ON loans(loan_date);

-- план ПІСЛЯ:
EXPLAIN QUERY PLAN
SELECT * FROM loans ORDER BY loan_date;
-- план: SCAN loans USING INDEX idx_loans_date

-- ===== Завдання 5. DROP INDEX і повторна перевірка =====
DROP INDEX idx_loans_reader;

EXPLAIN QUERY PLAN
SELECT * FROM loans WHERE reader_id = 6;
-- план: SEARCH loans USING INDEX idx_loans_reader_returned (reader_id=?)
-- (SCAN не повернувся: композитний індекс починається з reader_id, тому підходить і для цього запиту)

-- перевірка списку індексів:
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index';
-- результат: sqlite_autoindex_readers_1 | readers
--            idx_loans_reader_returned  | loans
--            idx_loans_date             | loans
SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_loans_reader';
-- результат: 0 рядків (індекс видалено)
