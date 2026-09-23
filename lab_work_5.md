# Практика 5. Варіант 1 — Бібліотека

## Завдання 1. NOT NULL → `books.author`
Перестворено `books`, додано `author TEXT NOT NULL`.
Спроба вставити книгу без автора:
```sql
INSERT INTO books (title, publication_year, genre, copies_count)
VALUES ('Тестова книга без автора', 2020, 'проза', 1);
```
Точний текст помилки:
```
IntegrityError: NOT NULL constraint failed: books.author
```

## Завдання 2. UNIQUE → `readers.email`
Перестворено `readers`, додано `email TEXT UNIQUE`.
Спроба вставити читача з поштою, яка вже є (`olena.k@example.com`):
```sql
INSERT INTO readers (full_name, phone, email, registration_date)
VALUES ('Тестовий Читач', '+380990000000', 'olena.k@example.com', '2026-06-01');
```
Точний текст помилки:
```
IntegrityError: UNIQUE constraint failed: readers.email
```

## Завдання 3. CHECK → `books.copies_count`
Перестворено `books` (вдруге), додано `CHECK (copies_count >= 0)`.

**Порушення** (від'ємна кількість):
```sql
INSERT INTO books (title, author, publication_year, genre, copies_count)
VALUES ('Тестова книга', 'Тест Автор', 2020, 'проза', -1);
```
Точний текст помилки:
```
IntegrityError: CHECK constraint failed: copies_count >= 0
```

**Без порушення** (коректна кількість):
```sql
INSERT INTO books (title, author, publication_year, genre, copies_count)
VALUES ('Українська мова. Практикум', 'Автор Тестовий', 2019, 'посібник', 2);
```
Виконано без помилок, рядок додано.

## Завдання 4. DEFAULT → `readers.registration_date`
Перестворено `readers` (вдруге), додано `registration_date TEXT NOT NULL DEFAULT (date('now'))`.
Вставка без вказання дати:
```sql
INSERT INTO readers (full_name, phone, email)
VALUES ('Тестовий Читач Дефолт', '+380991112233', 'test.default@example.com');
```
Підтвердження через SELECT:
```sql
SELECT full_name, registration_date FROM readers WHERE email='test.default@example.com';
```
Результат:
```
('Тестовий Читач Дефолт', '2026-09-23')
```
Підставилося саме очікуване значення — сьогоднішня дата.

## Завдання 5. Перевірка через UPDATE
Обрано обмеження CHECK із Завдання 3. Порушення командою UPDATE над уже існуючим рядком:
```sql
UPDATE books SET copies_count = -5 WHERE id = 1;
```
Точний текст помилки:
```
IntegrityError: CHECK constraint failed: copies_count >= 0
```
Помилка ідентична тій, що виникає при порушенні через INSERT — отже, обмеження CHECK діє однаково і при вставці нового рядка, і при оновленні вже існуючого.

## Завдання 6. Письмовий висновок
- **NOT NULL (`books.author`)** — книга без зазначеного автора не має сенсу як бібліографічний запис, тому це поле не може лишатися порожнім.
- **UNIQUE (`readers.email`)** — електронна пошта використовується як ідентифікатор читача для зв'язку й входу в систему, тому два читачі з однаковою поштою в базі — це помилка даних, а не нормальна ситуація.
- **CHECK (`books.copies_count >= 0`)** — кількість фізичних примірників книги не може бути від'ємним числом, оскільки це реальна фізична величина.
- **DEFAULT (`readers.registration_date`)** — якщо дату реєстрації не вказали явно, найбільш змістовне припущення — що читача зареєстровано сьогодні, тому дефолтним значенням логічно взяти поточну дату.

## Технічна примітка (важливо для відтворення)
При перестворенні `books`/`readers` через `ALTER TABLE ... RENAME TO ..._old` SQLite за замовчуванням автоматично переписує `FOREIGN KEY`-посилання в таблиці `loans` на `..._old`, що ламає зв'язки після видалення тимчасової таблиці. Виправлено додаванням `PRAGMA legacy_alter_table = ON;` перед перейменуваннями. Після виконання всього скрипта `PRAGMA foreign_key_check;` не показує жодних порушень — усі зв'язки `loans → books` і `loans → readers` цілі.

## Контрольні питання (тези для відповіді)
1. SQLite не підтримує `ALTER TABLE ... ADD CONSTRAINT`, тому єдиний спосіб додати обмеження до вже існуючого стовпця — перестворити таблицю: перейменувати стару, створити нову з потрібним обмеженням, скопіювати дані (`INSERT ... SELECT`), видалити стару.
2. Якщо серед наявних рядків уже є `NULL` у цьому стовпці, крок `INSERT INTO new_table SELECT * FROM old_table` завершиться помилкою `NOT NULL constraint failed`, і перестворення не вдасться, поки такі рядки не виправлять або не видалять.
3. Різниці немає: CHECK, доданий через перестворення таблиці, перевіряється так само безумовно й для кожного нового рядка/оновлення, як і CHECK, оголошений одразу при `CREATE TABLE`.
4. DEFAULT не можна перевірити спробою порушення, бо він не забороняє жодного значення — він лише підставляє значення, коли колонку не вказано; тому його перевіряють протилежним способом: вставляють рядок без цієї колонки і через `SELECT` підтверджують, що підставилося саме очікуване значення.
