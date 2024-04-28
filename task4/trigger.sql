-- Two triggers

-- When borrowing start and end date isn't set, it is automatically assigned.
-- borrow_start is set to current date and borrow_end to that + 14 days
-- item's available_count is descreased by one
-- If item isn't available, exception is raised
CREATE OR REPLACE TRIGGER borrowing_inc_cnt
BEFORE INSERT ON borrowing
FOR EACH ROW
WHEN (NEW.borrow_start IS NULL AND NEW.borrow_end IS NULL)
DECLARE
    item_id borrowing.item%TYPE;
    cnt item.available_count%TYPE;
    user_id reservation.users%TYPE;
    user_cnt INT;
    unavailable_item EXCEPTION;
BEGIN
    SELECT id, available_count
    INTO item_id, cnt
    FROM item
    WHERE id = :NEW.item;

    IF cnt <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Item is unavailable');
    END IF;

    SELECT users, COUNT(*)
    INTO user_id, user_cnt
    FROM reservation
    WHERE item = item_id AND q_number = (
        SELECT MIN(q_number)
        FROM reservation
        WHERE item = item_id
    )
    GROUP BY users;

    IF user_cnt != 0 AND user_id != :NEW.users THEN
        RAISE_APPLICATION_ERROR(-20002, 'Other user has this reserved');
    END IF;

    IF user_cnt != 0 THEN
        DELETE FROM reservation
        WHERE item = item_id AND q_number = (
            SELECT MIN(q_number)
            FROM reservation
            WHERE item = item_id
        );

        UPDATE reservation
        SET q_number = q_number - 1
        WHERE item = item_id;
    END IF;

    :NEW.borrow_start := SYSDATE;
    :NEW.borrow_end := SYSDATE + 14;

    UPDATE item
    SET available_count = available_count - 1
    WHERE id = item_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        :NEW.borrow_start := SYSDATE;
        :NEW.borrow_end := SYSDATE + 14;

        UPDATE item
        SET available_count = available_count - 1
        WHERE id = item_id;
END;
/

-- Increases available count of the returned item
-- Creates new receipt when the item was returned late and charges 5 Kč per day
CREATE OR REPLACE TRIGGER borrowing_return
AFTER DELETE ON borrowing
FOR EACH ROW
DECLARE
    item_name item.title%TYPE;
BEGIN
    UPDATE item
    SET available_count = available_count + 1
    WHERE id = :OLD.item;

    IF :OLD.borrow_end < SYSDATE THEN
        SELECT title
        INTO item_name
        FROM item
        WHERE id = :OLD.item;

        INSERT INTO receipt (price, note, paid, issue_date, due_date, users)
        VALUES (
            FLOOR(SYSDATE - :OLD.borrow_end) * 5,
            'Pozdní vrácení: ' || item_name,
            0,
            SYSDATE,
            SYSDATE + 28,
            :OLD.users
        );
    END IF;
END;
/

-- Two procedures where cursor is used, exception handling and variable usage
-- with date type referencing row or column of the table
-- Note: we created 3 procedures

-- Gets information about all users with given role
CREATE OR REPLACE PROCEDURE get_users_by_role(
    p_role IN users.role%TYPE
)
AS
    CURSOR user_cursor IS
        SELECT *
        FROM users
        WHERE role = p_role;
    v_user users%ROWTYPE;
BEGIN
    OPEN user_cursor;

    LOOP
        FETCH user_cursor INTO v_user;
        EXIT WHEN user_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || v_user.id);
        DBMS_OUTPUT.PUT_LINE('Name: ' || v_user.name);
        DBMS_OUTPUT.PUT_LINE('Email: ' || v_user.email);
        DBMS_OUTPUT.PUT_LINE('Phone: ' || v_user.phone);
    END LOOP;

    CLOSE user_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occured while getting users.');
END;
/

-- Inserts book to the database
-- If book already exists, count is increased by cnt, same for available_count
CREATE OR REPLACE PROCEDURE insert_book(
    qisbn IN book.isbn%TYPE,
    author IN book.author%TYPE,
    title IN item.title%TYPE,
    release_date IN item.release_date%TYPE,
    pages IN item.pages%TYPE,
    cnt IN item.count%TYPE
)
IS
    item_id item.id%TYPE;
BEGIN
    SELECT item_id
    INTO item_id
    FROM book
    WHERE isbn = qisbn;

    UPDATE item
    SET available_count = available_count + cnt, count = count + cnt
    WHERE id = item_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO item (title, release_date, pages, count, available_count)
        VALUES (
            title,
            release_date,
            pages,
            cnt,
            cnt
        )
        RETURNING id INTO item_id;

        INSERT INTO book (isbn, author, item_id)
        VALUES (
            qisbn,
            author,
            item_id
        );
END;
/

-- Inserts magazine to the database
-- If magazine already exists, count is increased by cnt, same for
-- available_count
CREATE OR REPLACE PROCEDURE insert_magazine(
    qissn IN magazine.issn%TYPE,
    part IN magazine.part%TYPE,
    publisher IN magazine.publisher%TYPE,
    title IN item.title%TYPE,
    release_date IN item.release_date%TYPE,
    pages IN item.pages%TYPE,
    cnt IN item.count%TYPE
)
IS
    item_id item.id%TYPE;
BEGIN
    SELECT item_id
    INTO item_id
    FROM magazine
    WHERE issn = qissn;

    UPDATE item
    SET available_count = available_count + cnt, count = count + cnt
    WHERE id = item_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO item (title, release_date, pages, count, available_count)
        VALUES (
            title,
            release_date,
            pages,
            cnt,
            cnt
        )
        RETURNING id INTO item_id;

        INSERT INTO magazine (issn, part, publisher, item_id)
        VALUES (
            qissn,
            part,
            publisher,
            item_id
        );
END;
/

-- Tests borrowing_inc_cnt trigger
INSERT INTO borrowing (item, users) VALUES (
    2,
    3
);

-- Tests borrowing return trigger
DELETE FROM borrowing
WHERE id = 2;

-- Tests procedures
SET SERVEROUTPUT ON;
BEGIN
    get_users_by_role('WORKER');

    insert_book(
        '9788085951707',
        'Andrzei Sapkowski',
        'Zaklínač: Čas opovržení',
        TO_DATE('1996', 'yyyy'),
        342,
        3
    );

    insert_magazine(
        '12114218',
        '753',
        'Čtyřlístek s.r.o.',
        'Čtyřlístek: A zase zpátky',
        TO_DATE('2024-04', 'yyyy-mm'),
        36,
        3
    );
END;
/

-- Creation of Index and usage of EXPLAIN PLAN
-- Query has to contain join of at least two tables, aggregation function and
-- GROUP BY

-- Gets each author book page sum after year 1995
EXPLAIN PLAN FOR
    SELECT SUM(i.pages) AS total_pages, b.author
    FROM book b
    JOIN item i ON i.id = b.item_id
    WHERE i.release_date >= TO_DATE('YY', '95')
    GROUP BY b.author;

-- Prints the database plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Index creation - index is set to release_date on the item table
DROP INDEX book_author_index;

CREATE INDEX book_author_index
ON item (release_date);

-- Tries same select with the index
EXPLAIN PLAN FOR
    SELECT SUM(i.pages) AS total_pages, b.author
    FROM book b
    JOIN item i ON i.id = b.item_id
    WHERE i.release_date >= TO_DATE('YY', '95')
    GROUP BY b.author;

-- Prints the database plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Grants access rights for the second team member
GRANT SELECT, INSERT, UPDATE ON item TO xstigl00;
GRANT SELECT, INSERT, UPDATE ON book TO xstigl00;
GRANT SELECT, INSERT, UPDATE ON magazine TO xstigl00;

-- Creates materialized view
-- This should be executed from the second team member
DROP MATERIALIZED VIEW book_item;

CREATE MATERIALIZED VIEW book_item AS
    SELECT i.*, b.*
    FROM xsleza26.item i, xsleza26.book b
    WHERE i.id = b.item_id;

-- Selects book from the view
SELECT id, title, author, pages
FROM book_item;

-- Select using WITH and CASE
-- Select user id, user and status of his return history
-- Return history is set based on number of times he return borrowing later
-- and how much later he returned it
SELECT u.id, u.name, (AVG(r.price) / 5) as avg_days_late, COUNT(*) as late_cnt,
CASE
    WHEN COUNT(*) = 0 THEN 'Excelent'
    WHEN COUNT(*) <= 2 AND (AVG(r.price) / 5) <= 14 THEN 'Not bad'
    WHEN COUNT(*) <= 50 AND (AVG(r.price) / 5) <= 3 THEN 'Not so good'
    WHEN COUNT(*) <= 50 THEN 'Quite late'
    ELSE 'Horrible'
END AS reputation
FROM users u, receipt r
WHERE u.id = r.users AND r.note LIKE 'Pozdní vrácení%'
GROUP BY u.id, u.name
