CREATE OR REPLACE TRIGGER tr_unique_student_id
    FOR INSERT OR UPDATE OF ID
    ON STUDENTS
    COMPOUND TRIGGER
    id_list SYS_REFCURSOR;
    id_curr STUDENTS.ID%TYPE;
    unique_id BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN id_list FOR
        SELECT ID FROM STUDENTS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_id := true;

        LOOP
            FETCH id_list INTO id_curr;
            EXIT WHEN id_list%NOTFOUND;
            IF id_curr = :NEW.ID THEN
                unique_id := false;
            END IF;
        END LOOP;

        CLOSE id_list;

        IF NOT unique_id THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE STUDENT ID');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_student_id;


CREATE OR REPLACE TRIGGER tr_unique_group_id
    FOR INSERT OR UPDATE OF ID
    ON GROUPS
    COMPOUND TRIGGER
    id_list SYS_REFCURSOR;
    id_curr GROUPS.ID%TYPE;
    unique_id BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN id_list FOR
        SELECT ID FROM GROUPS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_id := true;

        LOOP
            FETCH id_list INTO id_curr;
            EXIT WHEN id_list%NOTFOUND;

            IF id_curr = :NEW.ID THEN
                unique_id := false;
            END IF;
        END LOOP;

        CLOSE id_list;

        IF NOT unique_id THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE GROUP ID');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_group_id;


CREATE OR REPLACE TRIGGER tr_unique_group_name
    FOR INSERT OR UPDATE OF NAME
    ON GROUPS
    COMPOUND TRIGGER
    name_list SYS_REFCURSOR;
    name_curr GROUPS.NAME%TYPE;
    unique_name BOOLEAN;

BEFORE STATEMENT IS
BEGIN

    OPEN name_list FOR
        SELECT NAME FROM GROUPS;

END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN

        unique_name := true;

        LOOP
            FETCH name_list INTO name_curr;
            EXIT WHEN name_list%NOTFOUND;

            IF name_curr = :NEW.NAME THEN
                unique_name := false;
            END IF;
        END LOOP;

        CLOSE name_list;

        IF NOT unique_name THEN
            RAISE_APPLICATION_ERROR(-20999, 'NOT UNIQUE GROUP NAME');
        end if;

    END BEFORE EACH ROW;
    END tr_unique_group_name;


CREATE SEQUENCE student_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_student_id
    BEFORE INSERT
    ON STUDENTS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := student_id_seq.nextval;
    END IF;
END;

CREATE SEQUENCE group_id_seq
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE
    CACHE 20;

CREATE OR REPLACE TRIGGER tr_generate_group_id
    BEFORE INSERT
    ON GROUPS
    FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := group_id_seq.nextval;
    END IF;
END;

