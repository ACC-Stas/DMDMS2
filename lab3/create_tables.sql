CREATE TABLE dev.smth1
(
    id         NUMBER       not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT smth1_pk PRIMARY KEY (id)
);

CREATE TABLE dev.smth2
(
    id         NUMBER(10)   not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT smth2_pk PRIMARY KEY (id)
);

CREATE TABLE prod.smth1
(
    id            NUMBER       not null,
    some_field    VARCHAR2(59) not null,
    another_field VARCHAR2(59),
    CONSTRAINT smth1_pk PRIMARY KEY (id)
);

CREATE TABLE prod.smth3
(
    id         NUMBER       not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT smth1_pk PRIMARY KEY (id)
);

CREATE TABLE dev.three
(
    id         NUMBER       not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT three_pk PRIMARY KEY (id)
);

CREATE TABLE dev.two
(
    id         NUMBER(10)   not null,
    id_2 NUMBER(10) not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT two_pk PRIMARY KEY (id),
    CONSTRAINT two_fk FOREIGN KEY (id_2) REFERENCES dev.three(id)
);

CREATE TABLE dev.one
(
    id         NUMBER(10)   not null,
    id_2 NUMBER(10) not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT one_pk PRIMARY KEY (id),
    CONSTRAINT one_fk FOREIGN KEY (id_2) REFERENCES dev.two(id)
);

CREATE TABLE fk_table
(
    id     NUMBER,
    child  VARCHAR2(100),
    parent VARCHAR2(100)
);

CREATE TABLE dev.cycled
(
    id NUMBER(10) not null,

    CONSTRAINT pk PRIMARY KEY (id),
    CONSTRAINT fk FOREIGN KEY (id) REFERENCES dev.cycled (id)
);

CREATE TABLE ddl_table
(
    table_name VARCHAR2(100),
    ddl_script VARCHAR2(3000),
    type       VARCHAR2(100),
    priority   NUMBER(10) DEFAULT 100000
);

