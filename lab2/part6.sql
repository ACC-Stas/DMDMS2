CREATE OR REPLACE TRIGGER tr_c_val_update
    FOR INSERT OR UPDATE OR DELETE
    ON STUDENTS
    COMPOUND TRIGGER
    --declare
    cnt NUMBER;
    TYPE VECTOR IS TABLE OF NUMBER;
    id_list VECTOR;

BEFORE STATEMENT IS
BEGIN
    id_list := VECTOR();
END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            UPDATE GROUPS SET C_VAL=C_VAL+1 WHERE ID=:NEW.GROUP_ID;
        ELSIF UPDATING THEN
            UPDATE GROUPS SET C_VAL=C_VAL+1 WHERE  ID=:NEW.GROUP_ID;
            UPDATE GROUPS SET C_VAL=C_VAL-1 WHERE  ID=:OLD.GROUP_ID;
            SELECT C_VAL INTO cnt FROM GROUPS WHERE ID=:OLD.GROUP_ID;
            IF cnt = 0 THEN
                id_list.extend();
                id_list(id_list.COUNT) := :OLD.GROUP_ID;
            END IF;
        ELSIF DELETING THEN
            UPDATE GROUPS SET C_VAL=C_VAL-1 WHERE  ID=:OLD.GROUP_ID;
            SELECT C_VAL INTO cnt FROM GROUPS WHERE ID=:OLD.GROUP_ID;
            IF cnt = 0 THEN
                id_list.extend();
                id_list(id_list.COUNT) := :OLD.GROUP_ID;
            END IF;
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('GROUP DOES NOT EXISTS');
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..id_list.COUNT
            LOOP
                DELETE FROM GROUPS WHERE ID = id_list(i);
            END LOOP;
    END AFTER STATEMENT;
    END tr_c_val_update;
