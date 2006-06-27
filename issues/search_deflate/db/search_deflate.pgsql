-- To create the database, do the following:
--  $ createdb -E UTF8 time_precision
--  $ psql -d time_precision -f db/time_precision.pgsql

-- we don't want half a schema
BEGIN;

CREATE TABLE thingy (
    thingy_id   SERIAL primary key,
    created     timestamp with time zone default CURRENT_TIMESTAMP,
    stuff       text default 'foo'
);

COMMIT;
