CREATE FUNCTION is_even_more_my_table
RETURN VARCHAR2
IS
    even NUMBER;
    odd NUMBER;
BEGIN
    SELECT COUNT(t.VAL)
    INTO even
    from MyTable t
    WHERE MOD(t.VAL, 2) = 0;

    SELECT COUNT(t.VAL)
    INTO odd
    from MyTable t;

    odd:= odd - even;

    IF odd > even THEN
        dbms_output.put_line('TRUE');
        RETURN 'TRUE';
    ELSIF odd < even THEN
        dbms_output.put_line('FALSE');
        RETURN 'FALSE';
    END IF;

    dbms_output.put_line('EQUAL');
    RETURN 'EQUAL';

END is_even_more_my_table;
