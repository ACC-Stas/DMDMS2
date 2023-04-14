DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation>
    <Type>SELECT</Type>
    <Tables>
        <Table>TEST1</Table>
    </Tables>
    <Columns>
        <Column>TEST1.ID</Column>
        <Column>TEST1.NUMB</Column>
    </Columns>
    <Where>
        <Conditions>
            <Condition>
                <Body>TEST1.ID IN</Body>
                <Operation>
                    <Type>SELECT</Type>
                    <Tables>
                        <Table>TEST2</Table>
                    </Tables>
                    <Columns>
                        <Column>ID</Column>
                    </Columns>
                    <Where>
                        <Conditions>
                            <Condition>
                                <Body>TEST2.NAME LIKE ''%a%''</Body>
                                <Operator>AND</Operator>
                            </Condition>
                            <Condition>
                                <Body>TEST2.NUMB BETWEEN 10 AND 15</Body>
                            </Condition>
                        </Conditions>
                    </Where>
                </Operation>
            </Condition>
        </Conditions>
    </Where>
</Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(PARSE(INPUT_DATA));
END;

