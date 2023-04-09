CREATE OR REPLACE PROCEDURE PROD_CREATE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter NUMBER(10);
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
                        DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || prod_schema_name || '.' || diff.table_name || ' ADD ' ||
                                             res2.column_name || ' ' || res2.data_type || ';');
                    END LOOP;
            ELSE
                DBMS_OUTPUT.PUT_LINE('CREATE TABLE ' || prod_schema_name || '.' || diff.table_name ||
                                     ' AS (SELECT * FROM ' || dev_schema_name || '.' || diff.table_name || ');');
            END IF;
        END LOOP;
END;


CREATE OR REPLACE PROCEDURE PROD_DELETE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    counter  NUMBER(10);
    counter2 NUMBER(10);
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

            IF counter != counter2 THEN
                FOR res2 IN (select column_name
                             from all_tab_columns
                             where owner = prod_schema_name
                               and table_name = diff.table_name
                               and column_name not in (select column_name
                                                       from all_tab_columns
                                                       where owner = dev_schema_name
                                                         and table_name = diff.table_name))
                    LOOP
                        DBMS_OUTPUT.PUT_LINE('ALTER TABLE ' || prod_schema_name || '.' || diff.table_name ||
                                             ' DROP COLUMN ' || res2.column_name || ';');
                    END LOOP;

            ELSE
                DBMS_OUTPUT.PUT_LINE('DROP TABLE ' || prod_schema_name || '.' || diff.table_name ||
                                     ' CASCADE CONSTRAINTS;');
            END IF;
        END LOOP;
END;


CALL PROD_CREATE_LIST('DEV', 'PROD');
CALL PROD_DELETE_LIST('DEV', 'PROD');

