CREATE OR REPLACE PROCEDURE insert_op(table_name VARCHAR2, id IN NUMBER, val in NUMBER)
IS
    message VARCHAR2(32767);
BEGIN
    message:=utl_lms.FORMAT_MESSAGE('INSERT INTO %s (id, val) VALUES (%d, %d)', table_name, TO_CHAR(id), TO_CHAR(val));
    EXECUTE IMMEDIATE message;
end;

CREATE OR REPLACE PROCEDURE update_op(table_name VARCHAR2, id IN NUMBER, val in NUMBER)
IS
    message VARCHAR2(32767);
BEGIN
    message:=utl_lms.FORMAT_MESSAGE('UPDATE %s SET val=%d WHERE id=%d', table_name, TO_CHAR(val), TO_CHAR(id));
    EXECUTE IMMEDIATE message;
end;

CREATE OR REPLACE PROCEDURE delete_op(table_name VARCHAR2, id IN NUMBER)
IS
    message VARCHAR2(32767);
BEGIN
    message:=utl_lms.FORMAT_MESSAGE('DELETE FROM %s WHERE id=%d', table_name, TO_CHAR(id));
    EXECUTE IMMEDIATE message;
end;
