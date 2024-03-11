DELETE TABLE IF EXISTS user;
DELETE TABLE IF EXISTS item;
DELETE TABLE IF EXISTS book;
DELETE TABLE IF EXISTS magazine;
DELETE TABLE IF EXISTS receipt;
DELETE TABLE IF EXISTS borrowing;
DELETE TABLE IF EXISTS reservation;

CREATE TABLE user (
    id INT PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(255),
    phone VARCHAR(255),
    name VARCHAR(255),
    role VARCHAR(255)
);

CREATE TABLE item (
    id INT PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(255),
    release_date DATE,
    pages INT,
    count INT,
    available_count INT
);

CREATE TABLE book (
    ISBN VARCHAR(13) PRIMARY KEY,
    author VARCHAR(255),
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE magazine (
    ISSN VARCHAR(13), PRIMARY KEY,
    part INT,
    publisher VARCHAR(255),
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE receipt (
    id INT PRIMARY KEY AUTOINCREMENT,
    price NUMERIC(18, 2),
    note CHARACTER VARYING(1024),
    paid NUMERIC(18, 2),
    issue_date DATE,
    due_data DATA,
    FOREIGN KEY (user) REFERENCES user(id)
);

CREATE TABLE borrowing (
    id INT PRIMARY KEY AUTOINCREMENT,
    borrow_start DATE,
    borrow_end DATE,
    FOREIGN KEY (item) REFERENCES item(id),
    FOREIGN KEY (user) REFERENCES user(id)
);

CREATE TABLE reservation (
    id INT PRIMARY KEY AUTOINCREMENT,
    order INT,
    FOREIGN KEY(user) REFERENCES user(id),
    FOREIGN KEY(item) REFERENCES item(id)
);
