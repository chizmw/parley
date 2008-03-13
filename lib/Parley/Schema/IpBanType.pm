package Parley::Schema::IpBanType;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Parley::Version;  our $VERSION = $Parley::VERSION;

use base qw/DBIx::Class/;

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('ip_ban_type');
# Set columns in table
__PACKAGE__->add_columns(qw/id name description/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/id/);

#
# Set relationships:
#

__PACKAGE__->add_unique_constraint(
    'unique_ban_name',
    ['name']
);



1;
