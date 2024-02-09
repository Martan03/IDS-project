CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(255),
    phone VARCHAR(255),
    name VARCHAR(255),
    role VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS item (
    id INT PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(255),
    release_date DATE,
    pages INT,
    count INT,
    available_count INT
);

CREATE TABLE IF NOT EXISTS book (
    id INT PRIMARY KEY,
    author VARCHAR(255),
    ISBN VARCHAR(13),
    FOREIGN KEY (id) REFERENCES item(id)
);

CREATE TABLE IF NOT EXISTS magazine (
    id INT PRIMARY KEY,
    publisher VARCHAR(255),
    part INT,
    ISSN VARCHAR(13),
    FOREIGN KEY (id) REFERENCES item(id)
);
