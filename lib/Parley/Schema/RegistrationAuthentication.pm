package Parley::Schema::RegistrationAuthentication;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("registration_authentication");
__PACKAGE__->add_columns(
  "recipient",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "registration_authentication_id",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "expires",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("registration_authentication_id");
__PACKAGE__->belongs_to("recipient", "Person", { person_id => "recipient" });

1;

