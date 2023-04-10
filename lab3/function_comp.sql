CREATE OR REPLACE PROCEDURE PROD_FUNCTION_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
    counter NUMBER(10);
BEGIN
    FOR res IN (SELECT DISTINCT object_name
                FROM all_objects
                WHERE object_type = 'FUNCTION'
                  AND Owner = dev_schema_name
                  AND object_name NOT IN
                      (SELECT object_name FROM all_objects WHERE Owner = prod_schema_name AND object_type = 'FUNCTION'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR res2 IN (SELECT text
                         FROM all_source
                         WHERE type = 'FUNCTION'
                           AND name = res.object_name
                           AND Owner = dev_schema_name)
                LOOP
                    IF counter != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(RTRIM(res2.text, CHR(10) || CHR(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(RTRIM('FUNCTION ' || prod_schema_name || '.' || SUBSTR(res2.text, 14),
                                CHR(10) || CHR(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_FUNCTION_DELETE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
BEGIN
    FOR diff IN (select DISTINCT object_name
                 from all_objects
                 where object_type = 'FUNCTION'
                   and owner = prod_schema_name
                   and object_name not in
                       (select object_name from all_objects where owner = dev_schema_name and object_type = 'FUNCTION'))
        LOOP
            DBMS_OUTPUT.PUT_LINE('DROP FUNCTION ' || prod_schema_name || '.' || diff.object_name);
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_FUNCTION_DELETE_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
    counter NUMBER(10);
BEGIN
    FOR res IN (SELECT DISTINCT object_name
                FROM all_objects
                WHERE object_type = 'FUNCTION'
                  AND Owner = dev_schema_name
                  AND object_name IN
                      (SELECT object_name FROM all_objects WHERE Owner = prod_schema_name AND object_type = 'FUNCTION'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('DROP FUNCTION ' || prod_schema_name || '.' || res.object_name || ';');
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR res2 IN (SELECT text
                         FROM all_source
                         WHERE "TYPE" = 'FUNCTION'
                           AND name = res.object_name
                           AND Owner = dev_schema_name)
                LOOP
                    IF counter != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(RTRIM(res2.text, CHR(10) || CHR(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(RTRIM('FUNCTION ' || prod_schema_name || '.' || SUBSTR(res2.text, 14),
                                                   CHR(10) || CHR(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;
