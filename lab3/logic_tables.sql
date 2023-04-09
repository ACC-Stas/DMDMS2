CREATE TABLE ddl_table
(
    table_name VARCHAR2(100),
    ddl_script VARCHAR2(3000),
    type       VARCHAR2(100),
    priority   NUMBER(10) DEFAULT 100000
);

CREATE TABLE fk_table
(
    id     NUMBER,
    child  VARCHAR2(100),
    parent VARCHAR2(100)
);


