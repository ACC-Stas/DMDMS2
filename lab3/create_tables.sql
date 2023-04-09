CREATE TABLE dev.smth1(
    id NUMBER not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT smth1_pk PRIMARY KEY (id)
);

CREATE TABLE dev.smth2(
    id NUMBER(10) not null,
    some_field VARCHAR2(59) not null,
    CONSTRAINT smth2_pk PRIMARY KEY (id)
);

CREATE TABLE prod.smth1(
    id NUMBER not null,
    some_field VARCHAR2(59) not null,
	another_field VARCHAR2(59),
    CONSTRAINT smth1_pk PRIMARY KEY (id)
);

