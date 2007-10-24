#!/usr/bin/perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

# load the module that provides all of the common test functionality
use FindBin qw($Bin);
use lib $Bin;
use SchemaTest;

my $schematest = SchemaTest->new(
    {
        dsn       => 'dbi:Pg:dbname=parley',
        namespace => 'Parley::Schema',
        moniker   => 'Forum',
    }
);
$schematest->methods(
    {
        columns => [
            qw[
                forum_id
                name
                description
                active
                post_count
                last_post
            ]
        ],

        relations => [
            qw[
                threads
                last_post
            ]
        ],

        custom => [
            qw[
                moderators
            ]
        ],

        resultsets => [
            qw[
            ]
        ],
    }
);

$schematest->run_tests();
