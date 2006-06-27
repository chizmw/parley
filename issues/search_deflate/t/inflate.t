use Test::More tests => 7;
use strict;
use warnings;

# global variables
our ($schema, $new_thingy, $thingy_list, $pg_time, $nanoseconds);

BEGIN {
    # use modules
    use_ok('TimeDB');

    # this is the time we'll use to create a new thingy
    # it uses both tz-offset and nanoseconds
    $nanoseconds = 987654321;
    $pg_time = qq{1974-10-02 14:17:52.${nanoseconds}+03};

    # get DBIC schema
    $schema = TimeDB->connect('dbi:Pg:dbname=search_deflate');
    ok(defined $schema, 'schema object is defined');

    # do everything inside a transaction - then we can discard our test data
    $schema->txn_begin;
}

END {
    # rollback our changes
    $schema->txn_rollback;
}

################################################################################
diag q{first of all get an item into the database};
################################################################################
$new_thingy = $schema->resultset('Thingy')->create(
    {
        created => $pg_time,
    }
);
# make sure we made a thingy and that it has an ID
ok(defined $new_thingy, 'resultset for new Thingy is defined');
ok(defined $new_thingy->id(), 'PK-id for new Thingy is defined');
################################################################################


################################################################################
diag q{look up the thingy by pg_time - this should be fine};
################################################################################
# get all thingies matching $pg_time
$thingy_list = $schema->resultset('Thingy')->search(
    {
        created => { '=', $pg_time },
    }
);
# check we get the right number of Thingies
is($thingy_list->count(), 1, q{correct number of thingies [=, $pg_time]});
################################################################################


################################################################################
diag q{look up the thingy by ->created() - this should be fine, but it isn't};
diag q{search() doesn't appear to deflate as we might expect it to};
################################################################################
# get all thingies matching $pg_time
$thingy_list = $schema->resultset('Thingy')->search(
    {
        created => { '=', $new_thingy->created() },
    }
);
# check we get the right number of Thingies
is($thingy_list->count(), 1, q{correct number of thingies [=, $new_thingy->created()]});
################################################################################


################################################################################
diag q{look up the thingy by ->created(), using an explicit 'deflate'};
################################################################################
# get all thingies matching $pg_time
$thingy_list = $schema->resultset('Thingy')->search(
    {
        created => { '=', DateTime::Format::Pg->format_datetime($new_thingy->created()) },
    }
);
# check we get the right number of Thingies
is($thingy_list->count(), 1, q{correct number of thingies [=, DateTime::Format::Pg->format_datetime($new_thingy->created())]});
################################################################################
