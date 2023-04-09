CREATE OR REPLACE PROCEDURE PROD_CREATE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter    NUMBER(10);
    ddl_script VARCHAR2(3000);
BEGIN
    FOR diff IN (Select DISTINCT table_name
                 from all_tab_columns
                 where owner = dev_schema_name
                   and (table_name, column_name) not in
                       (select table_name, column_name from all_tab_columns where owner = prod_schema_name))
        LOOP
            counter := 0;

            SELECT COUNT(*)
            INTO counter
            FROM all_tables
            where owner = prod_schema_name
              and table_name = diff.table_name;

            IF counter > 0 THEN
                FOR res2 IN (Select DISTINCT column_name, data_type
                             from all_tab_columns
                             where owner = dev_schema_name
                               and table_name = diff.table_name
                               and (table_name, column_name) not in
                                   (select table_name, column_name from all_tab_columns where owner = prod_schema_name))
                    LOOP
                        ddl_script := 'ALTER TABLE ' || prod_schema_name || '.' || diff.table_name || ' ADD ' ||
                                      res2.column_name || ' ' || res2.data_type || ';';
                        INSERT INTO DDL_TABLE (TABLE_NAME, DDL_SCRIPT, "TYPE")
                        VALUES (diff.TABLE_NAME, ddl_script, 'TABLE');
                        DBMS_OUTPUT.PUT_LINE(ddl_script);
                    END LOOP;
            ELSE
                    ddl_script :=
                    'CREATE TABLE ' || prod_schema_name || '.' || diff.table_name || ' AS (SELECT * FROM ' ||
                    dev_schema_name || '.' || diff.table_name || ');';
                INSERT INTO DDL_TABLE (TABLE_NAME, DDL_SCRIPT, "TYPE")
                VALUES (diff.TABLE_NAME, ddl_script, 'TABLE');
                DBMS_OUTPUT.PUT_LINE(ddl_script);
            END IF;
        END LOOP;
END;


CREATE OR REPLACE PROCEDURE PROD_DELETE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter    NUMBER(10);
    counter2   NUMBER(10);
    ddl_script VARCHAR2(3000);
BEGIN
    FOR diff IN (Select DISTINCT table_name
                 from all_tab_columns
                 where owner = prod_schema_name
                   and (table_name, column_name) not in
                       (select table_name, column_name from all_tab_columns where owner = dev_schema_name))
        LOOP
            counter := 0;
            counter2 := 0;

            SELECT COUNT(column_name)
            INTO counter
            FROM all_tab_columns
            where owner = prod_schema_name
              and table_name = diff.table_name;

            SELECT COUNT(column_name)
            INTO counter2
            FROM all_tab_columns
            where owner = dev_schema_name
              and table_name = diff.table_name;

            IF counter2 = 0 AND counter != 0 THEN
                ddl_script := 'DROP TABLE ' || prod_schema_name || '.' || diff.table_name ||
                              ' CASCADE CONSTRAINTS;';
                INSERT INTO DDL_TABLE (TABLE_NAME, DDL_SCRIPT, "TYPE")
                VALUES (diff.TABLE_NAME, ddl_script, 'TABLE');
                DBMS_OUTPUT.PUT_LINE(ddl_script);
            ELSE
                FOR res2 IN (SELECT column_name
                             FROM all_tab_columns
                             WHERE OWNER = prod_schema_name
                               AND table_name = diff.table_name
                               AND column_name NOT IN (SELECT column_name
                                                       FROM all_tab_columns
                                                       WHERE OWNER = dev_schema_name
                                                         AND table_name = diff.table_name))
                    LOOP
                        ddl_script := 'ALTER TABLE ' || prod_schema_name || '.' || diff.table_name ||
                                      ' DROP COLUMN ' || res2.column_name || ';';
                        INSERT INTO DDL_TABLE (TABLE_NAME, DDL_SCRIPT, "TYPE")
                        VALUES (diff.TABLE_NAME, ddl_script, 'TABLE');
                        DBMS_OUTPUT.PUT_LINE(ddl_script);
                    END LOOP;
            END IF;
        END LOOP;
END;

CALL PROD_CREATE_LIST('DEV', 'PROD');
CALL PROD_DELETE_LIST('DEV', 'PROD');

