CREATE OR REPLACE NONEDITIONABLE PACKAGE "REPORTS" as
    procedure get_report(TS in timestamp);
    procedure get_report;
end;

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY "REPORTS" as
    last_date TIMESTAMP := SYSTIMESTAMP;
    PROCEDURE GET_REPORT(TS IN TIMESTAMP)
        IS
        l_clob  VARCHAR2(32767);
    begin
        l_clob := '
        <html>
            <head>
                <style>
                table, th, td {
                    border: 1px solid black;
                    border-collapse: collapse;
                }
                table.center {
                    margin-left: auto;
                    margin-right: auto;
                }
                </style>
            </head>
            <body>
            <h1 style="text-align: center"> Operation list since' || TS ||
                  '</h1> <table style="width:100%" class="center"> ';

        l_clob := l_clob || '
            <h1 align="center"> TABLE1 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE1_LOGGING_ACTIONS where DATE_EXEC > TS and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';


        l_clob := l_clob || '
            <h1 align="center"> TABLE2 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE2_LOGGING_ACTIONS where DATE_EXEC > TS and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';


        l_clob := l_clob || '
            <h1 align="center"> TABLE3 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE3_LOGGING_ACTIONS where DATE_EXEC > TS and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';

        l_clob := l_clob || '</body></html>';
        DBMS_OUTPUT.PUT_LINE(l_clob);
    end;


    PROCEDURE GET_REPORT
        IS
        l_clob  VARCHAR2(32767);
    begin
        l_clob := '
        <html>
            <head>
                <style>
                table, th, td {
                    border: 1px solid black;
                    border-collapse: collapse;
                }
                table.center {
                    margin-left: auto;
                    margin-right: auto;
                }
                </style>
            </head>
            <body>
            <h1 style="text-align: center"> Operation list since' || last_date ||
                  '</h1> <table style="width:100%" class="center"> ';

        l_clob := l_clob || '
            <h1 align="center"> TABLE1 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE1_LOGGING_ACTIONS where DATE_EXEC > last_date and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';


        l_clob := l_clob || '
            <h1 align="center"> TABLE2 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE2_LOGGING_ACTIONS where DATE_EXEC > last_date and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';


        l_clob := l_clob || '
            <h1 align="center"> TABLE3 INFO</h1>
            <table>
            <tr align="center">
                <th align="center">OPERATION</th>
                <th align="center">RECORDED ON </th>
            </tr>';
        for l_rec in (select * from TABLE3_LOGGING_ACTIONS where DATE_EXEC > last_date and IS_REVERTED = 0)
            loop
                l_clob := l_clob ||
                          '<tr align="center"> <td align="left">' ||
                          l_rec.operation || '</td> <td align="center">'
                    || l_rec.DATE_EXEC || '</td> </tr>';
            end loop;
        l_clob := l_clob || '</table>';

        l_clob := l_clob || '</body></html>';

        DBMS_OUTPUT.PUT_LINE(l_clob);
        last_date := SYSTIMESTAMP;
    end;
end;

