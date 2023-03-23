CREATE OR REPLACE TRIGGER tr_group_delete_cascade
    FOR DELETE
    ON GROUPS
    COMPOUND TRIGGER
    --declare here
    TYPE VECTOR IS TABLE OF NUMBER;
    id_list VECTOR;

BEFORE STATEMENT IS
BEGIN
    id_list := VECTOR();
END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        IF :OLD.C_VAL > 0 THEN
            id_list.extend();
            id_list(id_list.COUNT) := :OLD.ID;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..id_list.COUNT
            LOOP
                DELETE FROM STUDENTS WHERE GROUP_ID = id_list(i);
            END LOOP;
    END AFTER STATEMENT;
    END tr_group_delete_cascade;
