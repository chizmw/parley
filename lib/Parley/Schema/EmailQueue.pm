package Parley::Schema::EmailQueue;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("email_queue");
__PACKAGE__->add_columns(
  "recipient",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "cc",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "bcc",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sender",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "subject",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "html_content",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "email_queue_id",
  {
    data_type => "integer",
    default_value => "nextval('email_queue_email_queue_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "attempted_delivery",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "text_content",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "queued",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 0,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("email_queue_id");
__PACKAGE__->belongs_to("recipient", "Person", { person_id => "recipient" });
__PACKAGE__->belongs_to("cc", "Person", { person_id => "recipient" });
__PACKAGE__->belongs_to("bcc", "Person", { person_id => "recipient" });

1;

