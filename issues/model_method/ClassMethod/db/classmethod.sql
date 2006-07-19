-- createdb -E UTF 8 classmethod

BEGIN;

CREATE TABLE class_method (
    id          SERIAL      primary key,
    int1        integer     default 1,
    text1       text        default 'one'
);

COMMIT;
