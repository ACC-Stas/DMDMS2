CREATE OR REPLACE TYPE STRING_ARRAY IS VARRAY(3) OF VARCHAR2(10);

CREATE OR REPLACE FUNCTION GET_DEPENDENT_TABLES(IN_TABLE_NAME IN VARCHAR2)
    RETURN STRING_ARRAY
    IS
    DEPENDENT_TABLES STRING_ARRAY := STRING_ARRAY();
    INDX             NUMBER       := 0;

BEGIN
    FOR RELATION IN (
        SELECT P.TABLE_NAME,
               CH.TABLE_NAME CHILD
        FROM ALL_CONS_COLUMNS P
                 JOIN ALL_CONSTRAINTS CH
                      ON P.CONSTRAINT_NAME = CH.R_CONSTRAINT_NAME
        WHERE P.TABLE_NAME = IN_TABLE_NAME)
        LOOP
            DEPENDENT_TABLES.EXTEND;
            INDX := INDX + 1;
            DEPENDENT_TABLES(INDX) := RELATION.CHILD;
        END LOOP;
    RETURN DEPENDENT_TABLES;
END;


CREATE OR REPLACE PROCEDURE RESTORE_TABLE1(RESTORE_UNTIL TIMESTAMP) IS
BEGIN
    FOR action IN (SELECT *
                   FROM TABLE1_LOGGING_ACTIONS
                   WHERE RESTORE_UNTIL <= DATE_EXEC
                     AND IS_REVERTED = 0
                   ORDER BY ID DESC)
        LOOP
            IF action.operation = 'INSERT' THEN
                DELETE TABLE1 WHERE id = action.new_id;
            END IF;

            IF action.operation = 'UPDATE' THEN
                UPDATE TABLE1
                SET TABLE1.id         = action.old_id,
                    TABLE1.TESTCOLUMN = action.OLD_TESTCOLUMN
                WHERE TABLE1.id = action.new_id;
            END IF;

            IF action.operation = 'DELETE' THEN
                INSERT INTO TABLE1 VALUES (action.old_id, action.OLD_TESTCOLUMN);
            END IF;
        END LOOP;
    UPDATE TABLE1_LOGGING_ACTIONS
    SET IS_REVERTED = 1
    WHERE DATE_EXEC > RESTORE_UNTIL;
END;

CREATE OR REPLACE PROCEDURE RESTORE_TABLE2(RESTORE_UNTIL TIMESTAMP) IS
BEGIN
    RESTORE_CHILD('TABLE2', RESTORE_UNTIL);
    FOR action IN (SELECT *
                   FROM TABLE2_LOGGING_ACTIONS
                   WHERE RESTORE_UNTIL <= DATE_EXEC
                     AND IS_REVERTED = 0
                   ORDER BY ID DESC)
        LOOP
            IF action.operation = 'INSERT' THEN
                DELETE TABLE2 WHERE id = action.new_id;
            END IF;

            IF action.operation = 'UPDATE' THEN
                UPDATE TABLE2
                SET id         = action.old_id,
                    TESTCOLUMN = action.OLD_TESTCOLUMN
                WHERE id = action.new_id;
            END IF;

            IF action.operation = 'DELETE' THEN
                INSERT INTO TABLE2 VALUES (action.old_id, action.OLD_TESTCOLUMN);
            END IF;
        END LOOP;
    UPDATE TABLE2_LOGGING_ACTIONS
    SET IS_REVERTED = 1
    WHERE DATE_EXEC > RESTORE_UNTIL;
END;

CREATE OR REPLACE PROCEDURE RESTORE_TABLE3(RESTORE_UNTIL TIMESTAMP) IS
BEGIN
    FOR action IN (SELECT *
                   FROM TABLE3_LOGGING_ACTIONS
                   WHERE RESTORE_UNTIL <= DATE_EXEC
                     AND IS_REVERTED = 0
                   ORDER BY ID DESC)
        LOOP
            IF action.operation = 'INSERT' THEN
                DELETE TABLE3 WHERE id = action.new_id;
            END IF;

            IF action.operation = 'UPDATE' THEN
                UPDATE TABLE3
                SET id         = action.old_id,
                    TESTCOLUMN = action.OLD_TESTCOLUMN,
                    TABLE2_ID  = action.OLD_FK_ID
                WHERE id = action.new_id;
            END IF;

            IF action.operation = 'DELETE' THEN
                INSERT INTO TABLE3 VALUES (action.old_id, action.OLD_TESTCOLUMN, ACTION.OLD_FK_ID);
            END IF;
        END LOOP;
    UPDATE TABLE3_LOGGING_ACTIONS
    SET IS_REVERTED = 1
    WHERE DATE_EXEC > RESTORE_UNTIL;
END;



CREATE OR REPLACE PROCEDURE RESTORE_DATA(INPUT_TABLES IN STRING_ARRAY, INPUT_TS IN TIMESTAMP) IS
BEGIN
    FOR I IN 1..INPUT_TABLES.COUNT
        LOOP
            EXECUTE IMMEDIATE '
        BEGIN
            RESTORE_'
                || INPUT_TABLES(I)
                || '(TO_TIMESTAMP('''
                || TO_CHAR(INPUT_TS, 'DD-MM-YYYY HH:MI:SS')
                || ''', ''DD-MM-YYYYHH:MI:SS''));
        END;
        ';
        END LOOP;
END;


CREATE OR REPLACE PROCEDURE RESTORE_DATA1(INPUT_TABLES IN STRING_ARRAY, INPUT_TS IN NUMBER) IS
    TS VARCHAR2(1000);
BEGIN
    FOR I IN 1..INPUT_TABLES.COUNT
        LOOP
            EXECUTE IMMEDIATE '
        BEGIN
            RESTORE_'
                || INPUT_TABLES(I)
                || '(TO_TIMESTAMP('''
                || TO_CHAR(CURRENT_TIMESTAMP - INPUT_TS, 'DD-MM-YYYY HH:MI:SS')
                || ''', ''DD-MM-YYYYHH:MI:SS''));
        END;
        ';
        END LOOP;

END;


CREATE OR REPLACE PROCEDURE RESTORE_CHILD(TABLE_NAME IN VARCHAR2, RESTORE_UNTIL TIMESTAMP) IS
    CHILD_ARRAY STRING_ARRAY;
BEGIN
    CHILD_ARRAY := GET_DEPENDENT_TABLES(TABLE_NAME);
    RESTORE_DATA(CHILD_ARRAY, RESTORE_UNTIL);
END;

