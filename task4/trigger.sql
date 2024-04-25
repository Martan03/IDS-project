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
    unavailable_item EXCEPTION;
BEGIN
    SELECT id, available_count
    INTO item_id, cnt
    FROM item
    WHERE id = :NEW.item;

    IF cnt <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Item is unavailable');
    END IF;

    :NEW.borrow_start := SYSDATE;
    :NEW.borrow_end := SYSDATE + 14;

    UPDATE item
    SET available_count = available_count - 1
    WHERE id = item_id;
END;
/

INSERT INTO borrowing (item, users) VALUES (
    4,
    2
);

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

SET SERVEROUTPUT ON;
BEGIN
    get_users_by_role('WORKER');
END;
