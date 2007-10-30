#!/usr/bin/env perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Parley::Schema;

my $schema = Parley::Schema->connect;

$schema->create_ddl_dir(
    ['PostgreSQL'],
    '0.57_08',
    'db_script',
);
