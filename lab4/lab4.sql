CREATE OR REPLACE PACKAGE LAB4 AS
    FUNCTION PARSE_WHERE(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION PARSE_XML(XML_STRING IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION PARSE_SELECT(XML_STRING IN VARCHAR2) RETURN SYS_REFCURSOR;
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
END LAB4;

CREATE OR REPLACE FUNCTION PARSE(XML_STRING IN VARCHAR2) RETURN VARCHAR2
    IS
BEGIN
    RETURN LAB4.PARSE_XML(XML_STRING);
END;
