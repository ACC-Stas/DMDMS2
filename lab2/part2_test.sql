SELECT * FROM GROUPS;

INSERT INTO GROUPS (id, name, c_val)
VALUES
(3, 'adaaa', 12);

INSERT INTO GROUPS (name, c_val)
VALUES
('b', 12);


UPDATE GROUPS
SET name = 'BEBRA!'
WHERE ID=2;

DELETE
FROM GROUPS
WHERE name = 'BEBRA!';