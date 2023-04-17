DECLARE
    INPUT_DATA VARCHAR2(3000) := '
    <Operation>
        <Type>DELETE</Type>
        <Table>XMLTEST1</Table>
        <Where>
            <Conditions>
                <Condition>
                    <Body>XMLTEST1.ID = 1</Body>
                    <ConditionOperator>AND</ConditionOperator>
                </Condition>
                <Condition>
                    <Body>EXISTS</Body>
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
                </Condition>
            </Conditions>
        </Where>
    </Operation>';
BEGIN
    DBMS_OUTPUT.PUT_LINE(PACKAGE4.PROCESS_DELETE(INPUT_DATA));
END;
