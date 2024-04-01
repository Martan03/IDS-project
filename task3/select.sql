-- Number of not payed receipts of each user
SELECT u.id, u.name, COUNT(*) AS not_payed
FROM receipt r, users u
WHERE r.price <> r.paid AND u.id = r.users
GROUP BY u.id, u.name
ORDER BY not_payed;

-- Books that have reservation
SELECT DISTINCT b.*
FROM reservation r, item i
JOIN book b ON b.item_id = i.id
WHERE r.item = i.id;

-- Users that are first in reservation queue and have not paid all receipts
SELECT u.*, res.*, r.*
FROM users u
JOIN reservation res ON res.users = u.id
JOIN receipt r ON r.users = u.id
WHERE r.price <> r.paid AND res.q_number = 1