CREATE TABLE STUDENTS_LOGS
(
    ID             NUMBER PRIMARY KEY,
    TIME           TIMESTAMP(2) NOT NULL,
    OPERATION_TYPE VARCHAR2(10) NOT NULL,
    OLD_ID         NUMBER       DEFAULT NULL,
    OLD_NAME       VARCHAR2(50) DEFAULT NULL,
    OLD_GROUP_ID   NUMBER       DEFAULT NULL,
    NEW_ID         NUMBER       DEFAULT NULL,
    NEW_NAME       VARCHAR2(50) DEFAULT NULL,
    NEW_GROUP_ID   NUMBER       DEFAULT NULL
);

CREATE SEQUENCE students_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_students_logs_id
    BEFORE INSERT
    ON STUDENTS_LOGS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := students_logs_id_seq.nextval;
    END IF;
END;

CREATE OR REPLACE TRIGGER tr_student_log
    AFTER INSERT OR UPDATE OR DELETE
    ON STUDENTS
    FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
                (TIME, OPERATION_TYPE, NEW_ID, NEW_NAME, NEW_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'INSERT', :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
        END;

        WHEN UPDATING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
            (TIME, OPERATION_TYPE, OLD_ID, OLD_NAME, OLD_GROUP_ID, NEW_ID, NEW_NAME, NEW_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'UPDATE', :OLD.ID, :OLD.NAME, :OLD.GROUP_ID, :NEW.ID, :NEW.NAME, :NEW.GROUP_ID);
        END;

        WHEN DELETING THEN BEGIN
            INSERT INTO STUDENTS_LOGS
                (TIME, OPERATION_TYPE, OLD_ID, OLD_NAME, OLD_GROUP_ID)
            VALUES (CURRENT_TIMESTAMP, 'DELETE', :OLD.ID, :OLD.NAME, :OLD.GROUP_ID);
        END;
        END CASE;
END;