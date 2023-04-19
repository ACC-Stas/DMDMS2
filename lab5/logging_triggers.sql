CREATE OR replace trigger TABLE3_LOG_TRIGGER
    BEFORE INSERT OR UPDATE OR DELETE
    ON TABLE3
    FOR EACH ROW
DECLARE
BEGIN
    CASE
        WHEN INSERTING THEN INSERT INTO TABLE3_LOGGING_ACTIONS (OPERATION,
                                                                DATE_EXEC,
                                                                IS_REVERTED,
                                                                NEW_ID,
                                                                NEW_TESTCOLUMN,
                                                                OLD_ID,
                                                                OLD_TESTCOLUMN,
                                                                NEW_FK_ID,
                                                                OLD_FK_ID)
                            VALUES ('INSERT',
                                    SYSTIMESTAMP,
                                    0,
                                    :NEW.ID,
                                    :NEW.TESTCOLUMN,
                                    NULL,
                                    NULL,
                                    :NEW.TABLE2_ID,
                                    NULL);
        WHEN DELETING THEN INSERT INTO TABLE3_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN,
                                                               OLD_FK_ID,
                                                               NEW_FK_ID)
                           VALUES ('DELETE',
                                   SYSTIMESTAMP,
                                   0,
                                   NULL,
                                   NULL,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN,
                                   :OLD.TABLE2_ID,
                                   NULL);
        WHEN UPDATING THEN INSERT INTO TABLE3_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN,
                                                               NEW_FK_ID,
                                                               OLD_FK_ID)
                           VALUES ('UPDATE',
                                   SYSTIMESTAMP,
                                   0,
                                   :NEW.ID,
                                   :NEW.TESTCOLUMN,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN,
                                   :NEW.TABLE2_ID,
                                   :OLD.TABLE2_ID);
        END CASE;
END;


CREATE OR replace trigger TABLE1_LOG_TRIGGER
    BEFORE INSERT OR UPDATE OR DELETE
    ON TABLE1
    FOR EACH ROW
DECLARE
BEGIN
    CASE
        WHEN INSERTING THEN INSERT INTO TABLE1_LOGGING_ACTIONS (OPERATION,
                                                                DATE_EXEC,
                                                                IS_REVERTED,
                                                                NEW_ID,
                                                                NEW_TESTCOLUMN,
                                                                OLD_ID,
                                                                OLD_TESTCOLUMN)
                            VALUES ('INSERT',
                                    SYSTIMESTAMP,
                                    0,
                                    :NEW.ID,
                                    :NEW.TESTCOLUMN,
                                    NULL,
                                    NULL);
        WHEN DELETING THEN INSERT INTO TABLE1_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN)
                           VALUES ('DELETE',
                                   SYSTIMESTAMP,
                                   0,
                                   NULL,
                                   NULL,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN);
        WHEN UPDATING THEN INSERT INTO TABLE1_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN)
                           VALUES ('UPDATE',
                                   SYSTIMESTAMP,
                                   0,
                                   :NEW.ID,
                                   :NEW.TESTCOLUMN,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN);
        END CASE;
END;

CREATE OR replace trigger TABLE2_LOG_TRIGGER
    BEFORE INSERT OR UPDATE OR DELETE
    ON TABLE2
    FOR EACH ROW
DECLARE
BEGIN
    CASE
        WHEN INSERTING THEN INSERT INTO TABLE2_LOGGING_ACTIONS (OPERATION,
                                                                DATE_EXEC,
                                                                IS_REVERTED,
                                                                NEW_ID,
                                                                NEW_TESTCOLUMN,
                                                                OLD_ID,
                                                                OLD_TESTCOLUMN)
                            VALUES ('INSERT',
                                    SYSTIMESTAMP,
                                    0,
                                    :NEW.ID,
                                    :NEW.TESTCOLUMN,
                                    NULL,
                                    NULL);
        WHEN DELETING THEN INSERT INTO TABLE2_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN)
                           VALUES ('DELETE',
                                   SYSTIMESTAMP,
                                   0,
                                   NULL,
                                   NULL,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN);
        WHEN UPDATING THEN INSERT INTO TABLE2_LOGGING_ACTIONS (OPERATION,
                                                               DATE_EXEC,
                                                               IS_REVERTED,
                                                               NEW_ID,
                                                               NEW_TESTCOLUMN,
                                                               OLD_ID,
                                                               OLD_TESTCOLUMN)
                           VALUES ('UPDATE',
                                   SYSTIMESTAMP,
                                   0,
                                   :NEW.ID,
                                   :NEW.TESTCOLUMN,
                                   :OLD.ID,
                                   :OLD.TESTCOLUMN);
        END CASE;
END;

