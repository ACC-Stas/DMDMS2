CREATE OR REPLACE PROCEDURE roll_back(time TIMESTAMP, offset NUMBER := 0)
    IS
    CURSOR c_logs IS
        SELECT *
        FROM STUDENTS_LOGS
        ORDER BY TIME DESC;
BEGIN
    FOR curr IN c_logs
        LOOP
            IF curr.TIME > time - offset * 1/(24 * 60 * 60) THEN
                IF curr.OPERATION_TYPE = 'INSERT' THEN
                    DELETE
                    FROM STUDENTS
                    WHERE ID = curr.NEW_ID;
                ELSIF curr.OPERATION_TYPE = 'UPDATE' THEN
                    IF curr.OLD_ID = curr.NEW_ID THEN
                        UPDATE STUDENTS
                        SET NAME     = curr.OLD_NAME,
                            GROUP_ID = curr.OLD_GROUP_ID
                        WHERE ID = curr.NEW_ID;
                    ELSE
                        UPDATE STUDENTS
                        SET ID       = curr.OLD_ID,
                            NAME     = curr.OLD_NAME,
                            GROUP_ID = curr.OLD_GROUP_ID
                        WHERE ID = curr.NEW_ID;
                    END IF;
                ELSIF curr.OPERATION_TYPE = 'DELETE' THEN
                    INSERT INTO STUDENTS
                    VALUES (curr.OLD_ID, curr.OLD_NAME, curr.OLD_GROUP_ID);
                ELSE
                    RAISE_APPLICATION_ERROR(-20999, 'WRONG OPERATION');
                END IF;
            ELSE
                EXIT;
            END IF;
        END LOOP;
END;
