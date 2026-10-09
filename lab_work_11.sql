-- Практика 11. Комбіновані завдання з групуванням та відбором даних (варіант "Бібліотека")
-- Питання: які книги мають найбільшу чергу активних бронювань і їх варто дозамовити?
PRAGMA foreign_keys = ON;

-- ===== Завдання 1: нова таблиця зв'язку "багато-до-багатьох" books <-> readers =====
CREATE TABLE reservations (
    id               INTEGER PRIMARY KEY,
    book_id          INTEGER NOT NULL,
    reader_id        INTEGER NOT NULL,
    reservation_date TEXT NOT NULL DEFAULT (date('now')),
    status           TEXT NOT NULL DEFAULT 'active'
                     CHECK (status IN ('active', 'fulfilled', 'cancelled')),
    expiry_date      TEXT,
    UNIQUE (book_id, reader_id, reservation_date),
    FOREIGN KEY (book_id)   REFERENCES books (id)   ON DELETE CASCADE,
    FOREIGN KEY (reader_id) REFERENCES readers (id) ON DELETE CASCADE
);

INSERT INTO reservations (book_id, reader_id, reservation_date, status, expiry_date) VALUES
 (1, 2, '2026-05-20', 'fulfilled', '2026-06-20'),
 (1, 5, '2026-09-10', 'active',    '2026-10-10'),
 (2, 1, '2026-08-01', 'active',    '2026-09-01'),
 (2, 3, '2026-09-05', 'active',    '2026-10-05'),
 (2, 4, '2026-09-12', 'active',    '2026-10-12'),
 (2, 6, '2026-04-15', 'cancelled', NULL),
 (3, 2, '2026-09-18', 'active',    '2026-10-18'),
 (3, 4, '2026-09-20', 'active',    '2026-10-20'),
 (3, 6, '2026-09-25', 'active',    '2026-10-25'),
 (5, 7, '2026-09-28', 'active',    '2026-10-28');
-- групи за book_id: книга 2 - 4 рядки, книга 3 - 3, книга 1 - 2, книга 5 - 1
-- книги 4, 6, 7 не мають жодного бронювання (знадобляться в Завданні 5б)

-- ===== Завдання 2: JOIN + GROUP BY (кількість бронювань на книгу, групуємо за books.id) =====
SELECT books.title AS книга, COUNT(reservations.id) AS бронювань
FROM books
JOIN reservations ON reservations.book_id = books.id
GROUP BY books.id;
-- результат: Кобзар 2; Тигролови 4; Захар Беркут 3; Місто 1

-- ===== Завдання 3: HAVING (черга щонайменше з 3 бронювань) =====
SELECT books.title AS книга, COUNT(reservations.id) AS бронювань
FROM books
JOIN reservations ON reservations.book_id = books.id
GROUP BY books.id
HAVING COUNT(reservations.id) >= 3;
-- результат: Тигролови 4; Захар Беркут 3 (Кобзар 2 і Місто 1 відсіяні)

-- ===== Завдання 4: WHERE + JOIN + GROUP BY + HAVING =====
-- WHERE: лише активні бронювання, зроблені з 2026-09-01
SELECT books.title AS книга, COUNT(reservations.id) AS активних_бронювань
FROM books
JOIN reservations ON reservations.book_id = books.id
WHERE reservations.status = 'active'
  AND reservations.reservation_date >= '2026-09-01'
GROUP BY books.id
HAVING COUNT(reservations.id) >= 3;
-- результат: Захар Беркут 3 (Тигролови випав: 4 бронювання, але лише 2 активні вересневі)

-- ===== Завдання 5а: пастка групування (двійник книги з назвою "Кобзар") =====
INSERT INTO books (title, author, publication_year, genre, copies_count)
VALUES ('Кобзар', 'Інше видавництво', 2015, 'поезія', 1);   -- отримує id 8
INSERT INTO reservations (book_id, reader_id, reservation_date, status, expiry_date) VALUES
 (8, 1, '2026-09-15', 'active', '2026-10-15'),
 (8, 3, '2026-09-22', 'active', '2026-10-22');

-- запит Завдання 3, групування за id:
SELECT books.title AS книга, COUNT(reservations.id) AS бронювань
FROM books JOIN reservations ON reservations.book_id = books.id
GROUP BY books.id HAVING COUNT(reservations.id) >= 3;
-- результат: Тигролови 4; Захар Беркут 3

-- той самий запит, групування за назвою:
SELECT books.title AS книга, COUNT(reservations.id) AS бронювань
FROM books JOIN reservations ON reservations.book_id = books.id
GROUP BY books.title HAVING COUNT(reservations.id) >= 3;
-- результат: Захар Беркут 3; Кобзар 4 (!); Тигролови 4

-- ===== Завдання 5б: LEFT JOIN замість JOIN у запиті Завдання 4 =====
SELECT books.title AS книга, COUNT(reservations.id) AS активних_бронювань
FROM books
LEFT JOIN reservations ON reservations.book_id = books.id
WHERE reservations.status = 'active'
  AND reservations.reservation_date >= '2026-09-01'
GROUP BY books.id
HAVING COUNT(reservations.id) >= 3;
-- результат: Захар Беркут 3 (без змін)

-- допоміжний запит: LEFT JOIN без WHERE показує книги без жодного бронювання
SELECT books.title AS книга, COUNT(reservations.id) AS бронювань
FROM books
LEFT JOIN reservations ON reservations.book_id = books.id
GROUP BY books.id;
-- Земля 0; Собор 0; Українська мова. Практикум 0 (серед інших рядків)
