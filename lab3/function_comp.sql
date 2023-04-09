CREATE OR REPLACE PROCEDURE PROD_FUNCTION_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter NUMBER(10);
BEGIN
    FOR diff IN (select DISTINCT object_name
                 from all_objects
                 where object_type = 'FUNCTION'
                   and owner = dev_schema_name
                   and object_name not in
                       (select object_name from all_objects where owner = prod_schema_name and object_type = 'FUNCTION'))
        LOOP
            counter := 0;
            DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
            FOR res2 IN (select text
                         from all_source
                         where "TYPE" = 'FUNCTION'
                           and name = diff.object_name
                           and owner = dev_schema_name)
                LOOP
                    IF COUNTER != 0 THEN
                        DBMS_OUTPUT.PUT_LINE(rtrim(res2.text, chr(10) || chr(13)));
                    ELSE
                        DBMS_OUTPUT.PUT_LINE(rtrim(prod_schema_name || '.' || res2.text, chr(10) || chr(13)));
                        counter := 1;
                    END IF;
                END LOOP;
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_FUNCTION_DELETE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
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
