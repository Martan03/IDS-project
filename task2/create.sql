DROP TABLE magazine;
DROP TABLE book;
DROP TABLE receipt;
DROP TABLE borrowing;
DROP TABLE reservation;
DROP TABLE users;
DROP TABLE item;

CREATE TABLE users (
    id INT GENERATED ALWAYS as IDENTITY PRIMARY KEY,
    email VARCHAR(255),
    phone VARCHAR(255),
    name VARCHAR(255),
    role VARCHAR(255),
    CONSTRAINT check_email CHECK (
        REGEXP_LIKE(
            email,
            '^[A-Za-z0-9._%+-]+@([A-Za-z0-9.-]+\.)+[A-Za-z]{2,}$'
        )
    )
);

-- The specialization of `item` into `book` and `magazine` is done by 3 tables:
--   `item` - contains the common data for `book` and `magazine`
--   `book` - contains the data specific to `book` and id of the `item`
--   `magazine` - contains the data specific to `magazine` and id of the `item`
CREATE TABLE item (
    id INT GENERATED ALWAYS as IDENTITY PRIMARY KEY,
    title VARCHAR(255),
    release_date DATE,
    pages INT CHECK (pages > 0),
    count INT CHECK (count >= 0),
    available_count INT CHECK (available_count >= 0)
);

CREATE TABLE book (
    isbn CHAR(13) PRIMARY KEY,
    author VARCHAR(255),
    item_id INT,
    CONSTRAINT check_isbn_sum CHECK (
        MOD((
            SUBSTR(ISBN, 1, 1) * 1 +
            SUBSTR(ISBN, 2, 1) * 3 +
            SUBSTR(ISBN, 3, 1) * 1 +
            SUBSTR(ISBN, 4, 1) * 3 +
            SUBSTR(ISBN, 5, 1) * 1 +
            SUBSTR(ISBN, 6, 1) * 3 +
            SUBSTR(ISBN, 7, 1) * 1 +
            SUBSTR(ISBN, 8, 1) * 3 +
            SUBSTR(ISBN, 9, 1) * 1 +
            SUBSTR(ISBN, 10, 1) * 3 +
            SUBSTR(ISBN, 11, 1) * 1 +
            SUBSTR(ISBN, 12, 1) * 3 +
            SUBSTR(ISBN, 13, 1) * 1
        ), 10) = 0
    ),
    FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE TABLE magazine (
    issn CHAR(13) PRIMARY KEY,
    part INT CHECK (part > 0),
    publisher VARCHAR(255),
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES item(id)
);

CREATE TABLE receipt (
    id INT GENERATED ALWAYS as IDENTITY PRIMARY KEY,
    price NUMERIC(18, 2) CHECK (price >= 0),
    note VARCHAR(1024),
    paid NUMERIC(18, 2),
    issue_date DATE,
    due_date DATE,
    users INT,
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE borrowing (
    id INT GENERATED ALWAYS as IDENTITY PRIMARY KEY,
    borrow_start DATE,
    borrow_end DATE,
    item INT,
    users INT,
    FOREIGN KEY (item) REFERENCES item(id),
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE reservation (
    id INT GENERATED ALWAYS as IDENTITY PRIMARY KEY,
    q_number INT CHECK (q_number > 0),
    item INT,
    users INT,
    FOREIGN KEY(users) REFERENCES users(id),
    FOREIGN KEY(item) REFERENCES item(id)
);

INSERT INTO item (title, release_date, pages, count, available_count) VALUES (
    'Pán prstenů: Společenstvo Prstenu',
    TO_DATE('1990-01-01', 'yyyy-mm-dd'),
    473,
    12,
    12
);
INSERT INTO item (title, release_date, pages, count, available_count) VALUES (
    'Pán prstenů: Dvě věže',
    TO_DATE('1991-01-01', 'yyyy-mm-dd'),
    315,
    1,
    1
);
INSERT INTO item (title, release_date, pages, count, available_count) VALUES (
    'Hraničářův učeň: Rozvaliny Gorlanu',
    TO_DATE('2004', 'yyyy'),
    267,
    5,
    4
);
INSERT INTO item (title, release_date, pages, count, available_count) VALUES (
    'Čtyřlístek: Do středu země',
    TO_DATE('2024-03', 'yyyy-mm'),
    36,
    3,
    2
);


INSERT INTO book (author, isbn, item_id) VALUES (
    'J. R. R. Tolkien',
    '9788020409256',
    1
);
INSERT INTO book (author, isbn, item_id) VALUES (
    'J. R. R. Tolkien',
    '9788020409355',
    2
);
INSERT INTO book (author, isbn, item_id) VALUES (
    'John Flanagan',
    '9788025209905',
    3
);

INSERT INTO magazine (issn, part, publisher, item_id) VALUES (
    '12114219',
    '752',
    'Čtyřlístek s.r.o.',
    4
);

INSERT INTO users (email, phone, name, role) VALUES (
    'jan.novak@gmail.com',
    '123654789',
    'Jan Novák',
    'CLIENT'
);
INSERT INTO users (email, phone, name, role) VALUES (
    'pavel.koci@gmail.com',
    '321456987',
    'Pavel Kočí',
    'CLIENT'
);
INSERT INTO users (email, phone, name, role) VALUES (
    'ferdinand.ingerle@gmail.com',
    '123789654',
    'Ferndinand Ingerle',
    'WORKER'
);

INSERT INTO borrowing (borrow_start, borrow_end, item, users) VALUES (
    TO_DATE('2024-03-10', 'yyyy-mm-dd'),
    TO_DATE('2024-03-25', 'yyyy-mm-dd'),
    2,
    1
);
INSERT INTO borrowing (borrow_start, borrow_end, item, users) VALUES (
    TO_DATE('2024-02-20', 'yyyy-mm-dd'),
    TO_DATE('2024-03-01', 'yyyy-mm-dd'),
    1,
    2
);
INSERT INTO borrowing (borrow_start, borrow_end, item, users) VALUES (
    TO_DATE('2024-03-20', 'yyyy-mm-dd'),
    TO_DATE('2024-04-03', 'yyyy-mm-dd'),
    3,
    3
);
INSERT INTO borrowing (borrow_start, borrow_end, item, users) VALUES (
    TO_DATE('2024-03-21', 'yyyy-mm-dd'),
    TO_DATE('2024-04-02', 'yyyy-mm-dd'),
    4,
    2
);

INSERT INTO receipt (price, note, paid, issue_date, due_date, users) VALUES (
    50,
    'Pozdní vrácení',
    50,
    TO_DATE('2024-03-02', 'yyyy-mm-dd'),
    TO_DATE('2024-03-09', 'yyyy-mm-dd'),
    2
);
INSERT INTO receipt (price, note, paid, issue_date, due_date, users) VALUES (
    50,
    'Pozdní vrácení',
    0,
    TO_DATE('2024-03-02', 'yyyy-mm-dd'),
    TO_DATE('2024-03-09', 'yyyy-mm-dd'),
    3
);

INSERT INTO reservation (q_number, item, users) VALUES (
    1,
    2,
    3
);
INSERT INTO reservation(q_number, item, users) VALUES (
    2,
    2,
    1
);
