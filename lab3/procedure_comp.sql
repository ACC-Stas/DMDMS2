CREATE OR REPLACE PROCEDURE PROD_PROCEDURE_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
    counter NUMBER(10);
BEGIN
    FOR diff IN (select DISTINCT object_name
                 from all_objects
                 where object_type = 'PROCEDURE'
                   and owner = dev_schema_name
                   and object_name not in
                       (select object_name
                        from all_objects
                        where owner = prod_schema_name
                          and object_type = 'PROCEDURE'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR res2 IN (select text
                         from all_source
                         where "TYPE" = 'PROCEDURE'
                           and name = diff.object_name
                           and owner = dev_schema_name)
                LOOP
                    IF counter != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(RTRIM(res2.text, CHR(10) || CHR(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(RTRIM(
                                REPLACE('PROCEDURE ' || prod_schema_name || '.' || SUBSTR(res2.text, 10), ' ', ''),
                                CHR(10) || CHR(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_PROCEDURE_DELETE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
BEGIN
    FOR diff IN (select DISTINCT object_name
                 from all_objects
                 where object_type = 'PROCEDURE'
                   and owner = prod_schema_name
                   and object_name not in
                       (select object_name from all_objects where owner = dev_schema_name and object_type = 'PROCEDURE'))
        LOOP
            DBMS_OUTPUT.PUT_LINE('DROP PROCEDURE ' || prod_schema_name || '.' || diff.object_name);
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_PROCEDURE_DELETE_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
    counter NUMBER(10);
BEGIN
    FOR diff IN (SELECT DISTINCT object_name
                 FROM all_objects
                 WHERE object_type = 'PROCEDURE'
                   AND OWNER = dev_schema_name
                   AND object_name IN
                       (SELECT object_name
                        FROM all_objects
                        WHERE OWNER = prod_schema_name AND object_type = 'PROCEDURE'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('DROP PROCEDURE ' || prod_schema_name || '.' || diff.object_name || ';');
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR body IN (SELECT text
                         FROM all_source
                         WHERE type = 'PROCEDURE'
                           AND name = diff.object_name
                           AND Owner = dev_schema_name)
                LOOP
                    IF counter != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(RTRIM(body.text, CHR(10) || CHR(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(RTRIM(
                                REPLACE('PROCEDURE ' || prod_schema_name || '.' || SUBSTR(body.text, 10), ' ', ''),
                                CHR(10) || CHR(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;
