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
        moniker   => 'Thread',
    }
);
$schematest->methods(
    {
        columns => [
            qw[
                thread_id
                forum
                subject
                created
                creator
                post_count
                view_count
                active
                sticky
                locked
                last_post
            ]
        ],

        relations => [
            qw[
                last_post
                posts
                thread_views
                forum_moderators
            ]
        ],

        custom => [
            qw[
            ]
        ],

        resultsets => [
            qw[
            ]
        ],
    }
);

$schematest->run_tests();
