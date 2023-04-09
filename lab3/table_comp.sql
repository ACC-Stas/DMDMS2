CREATE OR REPLACE PROCEDURE PROD_CREATE_LIST(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
IS
BEGIN
    FOR diff IN (Select  DISTINCT table_name from all_tab_columns where owner = dev_schema_name  and (table_name, column_name) not in
        (select table_name, column_name from all_tab_columns where owner = prod_schema_name))
    LOOP
        DBMS_OUTPUT.PUT_LINE(diff.TABLE_NAME);
    END LOOP;
END;


CALL PROD_CREATE_LIST('DEV', 'PROD');
