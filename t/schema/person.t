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
                id
                authentication_id
                first_name
                last_name
                email
                forum_name
                preference_id
                last_post_id
                post_count
                suspended
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
                map_user_role
            ]
        ],

        custom => [
            qw[
                roles
                check_user_roles
                is_site_moderator
                can_suspend_account
            ]
        ],

        resultsets => [
            qw[
                users_with_roles
            ]
        ],
    }
);

$schematest->run_tests();
