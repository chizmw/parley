package Parley::Schema::Terms;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('PK::Auto', 'Core');
__PACKAGE__->table('terms');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'integer',
    },
    created => {
        data_type   => 'timestamp with time zone',
    },
    content => {
        data_type   => 'text',
    },
    change_summary => {
        data_type   => 'text',
    },
);

__PACKAGE__->set_primary_key('id');

1;
