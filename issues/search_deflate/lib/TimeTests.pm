package TimeTests;
use strict;
use warnings;
use Test::More;

sub connect_db {
    my $schema = TimeDB->connect('dbi:Pg:dbname=time_precision');
    ok(defined $schema, 'schema object is defined');
}

1;
