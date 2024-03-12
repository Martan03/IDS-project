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
    id INT,
    ISBN VARCHAR(13) PRIMARY KEY,
    author VARCHAR(255),
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE magazine (
    id INT,
    ISSN VARCHAR(13) PRIMARY KEY,
    part INT,
    publisher VARCHAR(255),
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE receipt (
    users INT,
    id INT PRIMARY KEY AUTO_INCREMENT,
    price NUMERIC(18, 2),
    note VARCHAR(1024),
    paid NUMERIC(18, 2),
    issue_date DATE,
    due_date DATE,
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE borrowing (
    item INT,
    users INT,
    id INT PRIMARY KEY AUTO_INCREMENT,
    borrow_start DATE,
    borrow_end DATE,
    FOREIGN KEY (item) REFERENCES item(id),
    FOREIGN KEY (users) REFERENCES users(id)
);

CREATE TABLE reservation (
    item INT,
    users INT,
    id INT PRIMARY KEY AUTO_INCREMENT,
    q_number INT,
    FOREIGN KEY(users) REFERENCES users(id),
    FOREIGN KEY(item) REFERENCES item(id)
);
