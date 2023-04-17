DECLARE
    INPUT_DATA VARCHAR2(3000) := '<Operation>
    <Type>INSERT</Type>
    <Table>Table1</Table>
    <Columns>
        <Column>XMLTEST2.ID</Column>
    </Columns>
    <Operation>
        <Type>SELECT</Type>
        <Tables>
            <Table>XMLTEST1</Table>
        </Tables>
        <Columns>
            <Column>ID</Column>
        </Columns>
        <Where>
            <Conditions>
                <Condition>
                    <Body>ID = 1</Body>
                </Condition>
            </Conditions>
        </Where>
    </Operation>
</Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(PARSE(INPUT_DATA));
END;
