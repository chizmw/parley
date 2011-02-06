package Parley::Schema::PasswordReset;
# ABSTRACT: Schema class for password_reset table
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("parley.password_reset");
__PACKAGE__->add_columns(

  id => {
    data_type => "integer",
    is_nullable => 0,
    size => undef,
  },

  recipient_id => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => 4
  },

  expires => {
    data_type => "timestamp without time zone",
    is_nullable => 1,
    size => 8,
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
    "recipient" => "Person",
    { 'foreign.id' => 'self.recipient_id' }
);

1;
