CREATE OR REPLACE FUNCTION get_annual_reward(salary NUMBER, prem_percent NUMBER)
RETURN REAL
IS
    result REAL;
    wrong_percent EXCEPTION;
    wrong_salary EXCEPTION;
BEGIN
    IF prem_percent < 0 THEN
        RAISE wrong_percent;
    END IF;

    IF prem_percent != TRUNC(prem_percent) THEN
        RAISE wrong_percent;
    END IF;

    IF salary < 0 THEN
        RAISE wrong_salary;
    END IF;

    result := (1 + (1 / 100) * prem_percent) * 12 * salary;
    RETURN result;

    EXCEPTION
        WHEN wrong_salary THEN
            DBMS_OUTPUT.PUT_LINE(utl_lms.FORMAT_MESSAGE('Invalid salary %d', TO_CHAR(salary)));
            RETURN -2;
        WHEN wrong_percent THEN
            DBMS_OUTPUT.PUT_LINE(utl_lms.FORMAT_MESSAGE('Invalid prem %d', TO_CHAR(prem_percent)));
            RETURN -1;
END;
