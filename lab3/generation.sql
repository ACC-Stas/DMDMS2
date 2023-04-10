CREATE OR REPLACE PROCEDURE GENERATE_DEPLOY_SCRIPT(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    AUTHID CURRENT_USER
    IS
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE DDL_TABLE';
    PROD_CREATE_LIST(dev_schema_name, prod_schema_name);
    PROD_DELETE_LIST(dev_schema_name, prod_schema_name);
    GET_TABLES_ORDER(dev_schema_name);

    FOR script IN (SELECT DDL_SCRIPT
                   FROM DDL_TABLE
                   ORDER BY PRIORITY)
        LOOP
        DBMS_OUTPUT.PUT_LINE(script.DDL_SCRIPT);
        END LOOP;

    PROD_PROCEDURE_CREATE(dev_schema_name, prod_schema_name);
    PROD_PROCEDURE_DELETE(dev_schema_name, prod_schema_name);
    PROD_PROCEDURE_DELETE_CREATE(dev_schema_name, prod_schema_name);
    PROD_FUNCTION_CREATE(dev_schema_name, prod_schema_name);
    PROD_FUNCTION_DELETE(dev_schema_name, prod_schema_name);
    PROD_FUNCTION_DELETE_CREATE(dev_schema_name, prod_schema_name);
    PROD_INDEX_CREATE(dev_schema_name, prod_schema_name);
    PROD_INDEX_DELETE(dev_schema_name, prod_schema_name);
END;


CALL GENERATE_DEPLOY_SCRIPT('DEV', 'PROD');
