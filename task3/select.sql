-- Combining two tables:
-- Gets all books
SELECT i.*, b.isbn, b.author
FROM item i, book b
WHERE i.id = b.item_id;

-- Gets all magazines
SELECT i.*, m.issn, m.part, m.publisher
FROM item i, magazine m
WHERE i.id = m.item_id;

-- Combining three tables:
-- Users that are first in reservation queue for all relevant items
SELECT u.*, r.*, i.*
FROM users u, reservation r, item i
WHERE r.users = u.id AND i.id = r.item AND r.q_number = 1;

-- Select containing GROUP BY and aggregation function
-- Gets average price payed by each user
SELECT u.id, u.email, COALESCE(AVG(r.price), 0) avg_payment
FROM users u
LEFT JOIN receipt r ON r.users = u.id
GROUP BY u.id, u.email;

-- Number of waiting users for each item in each reservation
SELECT i.id, i.title, COUNT(r.id) reservations
FROM item i
LEFT JOIN reservation r ON r.item = i.id
GROUP BY i.id, i.title;

-- Users that haven't paid receipt(s) and how many
SELECT u.id, u.name, COUNT(*) AS not_payed
FROM users u, receipt r
WHERE r.price <> r.paid AND r.users = u.id
GROUP BY u.id, u.name
ORDER BY not_payed;

-- Select containing EXISTS
-- Items that are borrowed on 1st of April 2024
SELECT i.*
FROM item i
WHERE EXISTS (
    SELECT *
    FROM borrowing b
    WHERE i.id = b.item AND
        TO_DATE('2024-04-01', 'yyyy-mm-dd') BETWEEN
            b.borrow_start AND b.borrow_end
);

-- Select containing IN
-- Users that have reservation
SELECT u.*
FROM users u
WHERE u.id IN (
    SELECT users
    FROM reservation
);

