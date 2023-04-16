CREATE OR REPLACE PACKAGE LAB4 AS
    FUNCTION PARSE_WHERE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION PARSE_XML(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION PARSE_SELECT(XML_STRING IN VARCHAR2) RETURN SYS_REFCURSOR;
    FUNCTION PARSE_INSERT(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION PARSE_UPDATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
END LAB4;

CREATE OR REPLACE PACKAGE BODY LAB4 AS
    FUNCTION parse_xml(xml_string IN VARCHAR2) RETURN VARCHAR2 IS
        tables_list     xml_record      := xml_record();
        in_columns      xml_record      := xml_record();
        join_conditions xml_record      := xml_record();
        join_types      xml_record      := xml_record();
        select_query    VARCHAR2(32767) := 'SELECT ';

    BEGIN
        IF xml_string IS NULL THEN
            RETURN NULL;
        END IF;

        tables_list := extract_values(xml_string, 'Operation/Tables/Table');
        in_columns := extract_values(xml_string, 'Operation/Columns/Column');
        join_conditions := extract_values(xml_string, 'Operation/Joins/Join/Condition');
        join_types := extract_values(xml_string, 'Operation/Joins/Join/Type');

        select_query := select_query || in_columns(1);

        FOR i IN 2..in_columns.COUNT
            LOOP
                select_query := select_query || ', ' || in_columns(i);
            END LOOP;

        select_query := select_query || ' FROM ' || tables_list(1);

        FOR i IN 2..tables_list.COUNT
            LOOP
                select_query := select_query || ' ' || join_types(i - 1) || ' ' || tables_list(i) || ' ON ' ||
                                join_conditions(i - 1);
            END LOOP;

        select_query := select_query || parse_where(xml_string);

        RETURN select_query;
    END parse_xml;

    FUNCTION PARSE_WHERE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        WHERE_CLAUSE VARCHAR2(1000) := 'WHERE ';
        CONDITIONS   XML_RECORD     := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/Where/Conditions/Condition');
    BEGIN
        FOR I IN 1..CONDITIONS.COUNT
            LOOP
                DECLARE
                    CONDITION_BODY      VARCHAR2(100)  := EXTRACTVALUE(XMLTYPE(CONDITIONS(I)), 'Condition/Body');
                    CONDITION_OPERATOR  VARCHAR2(100)  := EXTRACTVALUE(XMLTYPE(CONDITIONS(I)), 'Condition/Operator');
                    ARGUMENTS_XML       XMLTYPE        := XMLTYPE(EXTRACT(XMLTYPE(CONDITIONS(I)), 'Condition/Arguments'));
                    ARGUMENTS           VARCHAR2(1000) := NULL;
                    ARGUMENTS_START     VARCHAR2(10)   := EXTRACTVALUE(XMLTYPE(CONDITIONS(I)), 'Condition/ArgumentsStart');
                    ARGUMENTS_END       VARCHAR2(10)   := EXTRACTVALUE(XMLTYPE(CONDITIONS(I)), 'Condition/ArgumentsEnd');
                    ARGUMENTS_SEPARATOR VARCHAR2(10)   := EXTRACTVALUE(XMLTYPE(CONDITIONS(I)),
                                                                       'Condition/ArgumentsSeparator');
                    SUB_QUERY_XML       XMLTYPE        := XMLTYPE(EXTRACT(XMLTYPE(CONDITIONS(I)), 'Condition/Operation'));
                    SUB_QUERY           VARCHAR2(1000) := NULL;
                    SUB_CLAUSE          VARCHAR2(1000) := NULL;
                BEGIN
                    IF ARGUMENTS_XML IS NOT NULL THEN
                        SELECT EXTRACT_VALUES(ARGUMENTS_XML, 'Arguments/Argument') INTO ARGUMENTS FROM DUAL;
                    END IF;

                    IF SUB_QUERY_XML IS NOT NULL THEN
                        SUB_QUERY := PARSE_XML(SUB_QUERY_XML.GETCLOBVAL());
                        IF SUB_QUERY IS NOT NULL THEN
                            SUB_CLAUSE := '(' || SUB_QUERY || ')';
                        END IF;
                    END IF;

                    WHERE_CLAUSE := WHERE_CLAUSE || TRIM(CONDITION_BODY) || ' ' || TRIM(CONDITION_OPERATOR);

                    IF ARGUMENTS IS NOT NULL THEN
                        WHERE_CLAUSE :=
                                    WHERE_CLAUSE || ' ' || ARGUMENTS_START || ' ' || ARGUMENTS || ' ' || ARGUMENTS_END;
                    END IF;

                    IF SUB_CLAUSE IS NOT NULL THEN
                        WHERE_CLAUSE := WHERE_CLAUSE || ' ' || SUB_CLAUSE;
                    END IF;

                    IF I < CONDITIONS.COUNT THEN
                        WHERE_CLAUSE :=
                                    WHERE_CLAUSE || ' ' || EXTRACTVALUE(XMLTYPE(CONDITIONS(I)), 'Condition/Separator');
                    END IF;
                END;
            END LOOP;

        IF CONDITIONS.COUNT = 0 THEN
            RETURN '';
        END IF;

        RETURN WHERE_CLAUSE;
    END PARSE_WHERE;


    FUNCTION parse_select(xml_string IN VARCHAR2) RETURN SYS_REFCURSOR IS
        rf_cur SYS_REFCURSOR;
    BEGIN
        OPEN rf_cur FOR
            SELECT *
            FROM XMLTABLE('/root'
                          PASSING XMLTYPE(xml_string)
                          COLUMNS col1 VARCHAR2(100) PATH 'col1',
                              col2 VARCHAR2(100) PATH 'col2');
        RETURN rf_cur;
    END;

    FUNCTION PARSE_INSERT(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        VALUES_TO_INSERT       VARCHAR2(1000);
        SELECT_QUERY_TO_INSERT VARCHAR2(1000);
        XML_VALUES             XML_RECORD := XML_RECORD();
        INSERT_QUERY           VARCHAR2(1000);
        TABLE_NAME             VARCHAR2(100);
        XML_COLUMNS            VARCHAR2(200);
    BEGIN
        SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/Values').GETSTRINGVAL()
        INTO VALUES_TO_INSERT
        FROM DUAL;

        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;

        XML_COLUMNS := '(' || CONCAT_STRING(EXTRACT_VALUES(XML_STRING, 'Operation/Columns/Column'), ',') || ')';

        INSERT_QUERY := 'INSERT INTO ' || TABLE_NAME || XML_COLUMNS;

        IF VALUES_TO_INSERT IS NOT NULL THEN
            XML_VALUES := EXTRACT_VALUES(VALUES_TO_INSERT, 'Values/Value');
            INSERT_QUERY := INSERT_QUERY || ' VALUES (' || XML_VALUES(1) || ')';

            FOR I IN 2..XML_VALUES.COUNT
                LOOP
                    INSERT_QUERY := INSERT_QUERY || ',(' || XML_VALUES(I) || ')';
                END LOOP;
        ELSE
            SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/Operation').GETSTRINGVAL()
            INTO SELECT_QUERY_TO_INSERT
            FROM DUAL;

            INSERT_QUERY := INSERT_QUERY || PARSE_XML(SELECT_QUERY_TO_INSERT);
        END IF;

        RETURN INSERT_QUERY;
    END;

    FUNCTION PARSE_UPDATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        SET_COLLECTION     XML_RECORD     := XML_RECORD();
        WHERE_CLAUSE       VARCHAR2(1000) := ' WHERE ';
        SET_OPERATIONS     VARCHAR2(1000);
        SUB_QUERY          VARCHAR2(1000);
        CONDITION_OPERATOR VARCHAR2(1000);
        UPDATE_QUERY       VARCHAR2(1000) := 'UPDATE ';
        TABLE_NAME         VARCHAR2(100);
    BEGIN
        SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/SetOperations').GETSTRINGVAL()
        INTO SET_OPERATIONS
        FROM DUAL;

        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table')
        INTO TABLE_NAME
        FROM DUAL;

        SET_COLLECTION := EXTRACT_VALUES(SET_OPERATIONS, 'SetOperations/Set');
        UPDATE_QUERY := UPDATE_QUERY || TABLE_NAME || ' SET ' || SET_COLLECTION(1);

        FOR I IN 2..SET_COLLECTION.COUNT
            LOOP
                UPDATE_QUERY := UPDATE_QUERY || ',' || SET_COLLECTION(I);
            END LOOP;

        WHERE_CLAUSE := PARSE_WHERE(XML_STRING);

        IF WHERE_CLAUSE IS NOT NULL THEN
            UPDATE_QUERY := UPDATE_QUERY || WHERE_CLAUSE;
        END IF;

        RETURN UPDATE_QUERY;
    END;

    FUNCTION PARSE_DELETE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        TABLE_NAME   VARCHAR2(100);
        WHERE_CLAUSE VARCHAR2(1000) := ' WHERE ';
        DELETE_QUERY VARCHAR2(1000) := 'DELETE FROM ';
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table') INTO TABLE_NAME FROM DUAL;
        DELETE_QUERY := DELETE_QUERY || TABLE_NAME || WHERE_CLAUSE || PARSE_WHERE(XML_STRING);
        RETURN DELETE_QUERY;
    END;

    FUNCTION PARSE_CREATE(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        TABLE_COLUMNS         XML_RECORD     := XML_RECORD();
        TABLE_CONSTRAINTS     XML_RECORD     := XML_RECORD();
        TABLE_NAME            VARCHAR2(100);
        COL_CONSTRAINTS       XML_RECORD     := XML_RECORD();
        COL_NAME              VARCHAR2(100);
        COL_TYPE              VARCHAR2(100);
        PRIMARY_CONSTRAINT    VARCHAR2(1000);
        FOREIGN_CONSTRAINT    VARCHAR2(1000);
        AUTO_INCREMENT_SCRIPT VARCHAR2(1000);
        CREATE_QUERY          VARCHAR2(4000) := 'CREATE TABLE ';
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table') INTO TABLE_NAME FROM DUAL;

        CREATE_QUERY := CREATE_QUERY || TABLE_NAME || '(';

        TABLE_COLUMNS := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/Columns/Column');
        FOR I IN 1 .. TABLE_COLUMNS.COUNT
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_COLUMNS(I)), 'Column/Name') INTO COL_NAME FROM DUAL;
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_COLUMNS(I)), 'Column/Type') INTO COL_TYPE FROM DUAL;

                COL_CONSTRAINTS := EXTRACT_VALUES(TABLE_COLUMNS(I), 'Column/Constraints/Constraint');

                CREATE_QUERY := CREATE_QUERY || ' ' || COL_NAME || ' ' || COL_TYPE ||
                                CONCAT_STRING(COL_CONSTRAINTS, CHR(10));

                IF I != TABLE_COLUMNS.COUNT THEN
                    CREATE_QUERY := CREATE_QUERY || ' , ';
                END IF;
            END LOOP;

        SELECT EXTRACT(XMLTYPE(XML_STRING), 'Operation/TableConstraints/PrimaryKey').GETSTRINGVAL()
        INTO PRIMARY_CONSTRAINT
        FROM DUAL;
        IF PRIMARY_CONSTRAINT IS NOT NULL THEN
            CREATE_QUERY := CREATE_QUERY || 'CONSTRAINT ' || TABLE_NAME || '_pk PRIMARY KEY (' ||
                            CONCAT_STRING(EXTRACT_VALUES(PRIMARY_CONSTRAINT, 'PrimaryKey/Columns/Column'), ',') ||
                            ')' || CHR(10);
        END IF;

        TABLE_CONSTRAINTS := EXTRACT_WITH_SUBNODES(XML_STRING, 'Operation/TableConstraints/ForeignKey');
        FOR I IN 1 .. TABLE_CONSTRAINTS.COUNT
            LOOP
                SELECT EXTRACTVALUE(XMLTYPE(TABLE_CONSTRAINTS(I)), 'ForeignKey/Parent')
                INTO FOREIGN_CONSTRAINT
                FROM DUAL;
                CREATE_QUERY := CREATE_QUERY || ' , CONSTRAINT ' || TABLE_NAME || '_' || FOREIGN_CONSTRAINT ||
                                '_fk FOREIGN KEY (' || CONCAT_STRING(
                                        EXTRACT_VALUES(TABLE_CONSTRAINTS(I), 'ForeignKey/ChildColumns/Column'),
                                        ' , ') || ') REFERENCES ' || FOREIGN_CONSTRAINT || '(' || CONCAT_STRING(
                                        EXTRACT_VALUES(TABLE_CONSTRAINTS(I), 'ForeignKey/ParentColumns/Column'),
                                        ' , ') || ')' || CHR(10);
            END LOOP;

        CREATE_QUERY := CREATE_QUERY || ')' || AUTO_INCREMENT_SCRIPT;
        RETURN CREATE_QUERY;
    END;

    FUNCTION PARSE_DROP(XML_STRING IN VARCHAR2) RETURN VARCHAR2 IS
        DROP_QUERY VARCHAR2(1000) := 'DROP TABLE ';
        TABLE_NAME VARCHAR2(100);
    BEGIN
        SELECT EXTRACTVALUE(XMLTYPE(XML_STRING), 'Operation/Table') INTO TABLE_NAME FROM DUAL;
        DROP_QUERY := DROP_QUERY || TABLE_NAME;
        RETURN DROP_QUERY;
    END;

END LAB4;

CREATE OR REPLACE FUNCTION PARSE(XML_STRING IN VARCHAR2) RETURN VARCHAR2
    IS
BEGIN
    RETURN LAB4.PARSE_XML(XML_STRING);
END;

