package Parley::Schema::PasswordReset;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("password_reset");
__PACKAGE__->add_columns(

  password_reset_id => {
    data_type => "integer",
    is_nullable => 0,
    size => undef,
  },

  recipient => {
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

__PACKAGE__->set_primary_key("password_reset_id");

__PACKAGE__->belongs_to("recipient", "Person", { person_id => "recipient" });

1;
