DROP TABLE IF EXISTS magazine;
DROP TABLE IF EXISTS book;
DROP TABLE IF EXISTS receipt;
DROP TABLE IF EXISTS borrowing;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS item;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255),
    phone VARCHAR(255),
    name VARCHAR(255),
    role VARCHAR(255)
);

CREATE TABLE item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    release_date DATE,
    pages INT,
    count INT,
    available_count INT
);

CREATE TABLE book (
    isbn VARCHAR(13) PRIMARY KEY,
    author VARCHAR(255),
    id INT,
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE magazine (
    issn VARCHAR(13) PRIMARY KEY,
    part INT,
    publisher VARCHAR(255),
    id INT,
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE receipt (
    id INT PRIMARY KEY AUTO_INCREMENT,
    price NUMERIC(18, 2),
    note VARCHAR(1024),
    paid NUMERIC(18, 2),
    issue_date DATE,
    due_date DATE,
    users INT,
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE borrowing (
    id INT PRIMARY KEY AUTO_INCREMENT,
    borrow_start DATE,
    borrow_end DATE,
    item INT,
    users INT,
    FOREIGN KEY (item) REFERENCES item(id),
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE reservation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    q_number INT,
    item INT,
    users INT,
    FOREIGN KEY(users) REFERENCES users(id),
    FOREIGN KEY(item) REFERENCES item(id)
);

INSERT INTO item (title, release_date, pages, count, available_count) VALUES (
    'Pán prstenů: Společenstvo Prstenu',
    '1990-01-01',
    473,
    12,
    12
), (
    'Pán prstenů: Dvě věže',
    '1991-01-01',
    315,
    1,
    0
);

INSERT INTO book (author, isbn, id) VALUES (
    'J. R. R. Tolkien',
    '9788020409256',
    1
), (
    'J. R. R. Tolkien',
    '9788020409355',
    2
);

INSERT INTO users (email, phone, name, role) VALUES (
    'jan.novak@gmail.com',
    '123654789',
    'Jan Novák',
    'CLIENT'
), (
    'pavel.koci@gmail.com',
    '321456987',
    'Pavel Kočí',
    'CLIENT'
), (
    'ferdinand.ingerle@gmail.com',
    '123789654',
    'Ferndinand Ingerle',
    'WORKER'
);

INSERT INTO borrowing (borrow_start, borrow_end, item, users) VALUES (
    '2024-03-10',
    '2024-03-25',
    2,
    1
), (
    '2024-02-20',
    '2024-03-01',
    1,
    2
);

INSERT INTO receipt (price, note, paid, issue_date, due_date, users) VALUES (
    50,
    'Pozdní vrácení',
    50,
    '2024-03-02',
    '2024-03-09',
    2
);

INSERT INTO reservation (q_number, item, users) VALUES (
    1,
    2,
    3
);
