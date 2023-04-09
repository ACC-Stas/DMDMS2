CREATE OR REPLACE PROCEDURE PROD_INDEX_CREATE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
    text VARCHAR2(100);
BEGIN
    FOR diff IN (select index_name, index_type, table_name
                 from all_indexes
                 where table_owner = dev_schema_name
                   and index_name not like '%_PK'
                   and index_name not in
                       (select index_name
                        from all_indexes
                        where table_owner = prod_schema_name
                          and index_name not like '%_PK'))
        LOOP
            select column_name
            INTO text
            from ALL_IND_COLUMNS
            where index_name = diff.index_name
              and table_owner = dev_schema_name;
            DBMS_OUTPUT.PUT_LINE('CREATE ' || diff.index_type || ' INDEX ' || diff.index_name || ' ON ' ||
                                 prod_schema_name || '.' || diff.table_name || '(' || text || ');');
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE PROD_INDEX_DELETE(dev_schema_name VARCHAR2, prod_schema_name VARCHAR2)
    IS
BEGIN
    FOR diff IN (select index_name
                 from all_indexes
                 where table_owner = prod_schema_name
                   and index_name not like '%_PK'
                   and index_name not in
                       (select index_name
                        from all_indexes
                        where table_owner = dev_schema_name
                          and index_name not like '%_PK'))
        LOOP
            DBMS_OUTPUT.PUT_LINE('DROP INDEX ' || diff.index_name || ';');
        END LOOP;
END;
