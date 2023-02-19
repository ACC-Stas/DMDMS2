BEGIN
    FOR idx in 1 .. 10000 LOOP
        INSERT INTO MYTABLE values (idx, ROUND(DBMS_RANDOM.VALUE(1, 100000)));
        end loop;
end;
