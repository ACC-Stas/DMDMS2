CREATE FUNCTION get_insert_query(table_name VARCHAR2, id IN NUMBER, val IN NUMBER)
RETURN VARCHAR2
IS
    message VARCHAR2(32767);
BEGIN
    message:=utl_lms.format_message('INSERT INTO %s VALUES (%d, %d)',
        table_name, TO_CHAR(id), TO_CHAR(val));
    DBMS_OUTPUT.PUT_LINE(message);
    RETURN message;

END;
