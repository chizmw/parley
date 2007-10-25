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
        moniker   => 'Person',
    }
);
$schematest->methods(
    {
        columns => [
            qw[
                person_id
                authentication
                first_name
                last_name
                email
                forum_name
                preference
                last_post
                post_count
            ]
        ],

        relations => [
            qw[
                threads
                email_queues
                thread_views
                preference
                last_post
                authentication
                registration_authentications
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
