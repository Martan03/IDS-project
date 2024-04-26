DROP MATERIALIZED VIEW book_item;

CREATE MATERIALIZED VIEW book_item AS
    SELECT i.*, b.*
    FROM xsleza26.item i, xsleza26.book b
    WHERE i.id = b.item_id;
