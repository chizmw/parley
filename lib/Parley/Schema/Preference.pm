package Parley::Schema::Preference;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("preference");
__PACKAGE__->add_columns(
  "id" => {
    data_type => "integer",
    #default_value => "nextval('preference_preference_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },

  "timezone" => {
    data_type => "text",
    default_value => "UTC",
    is_nullable => 0,
    size => undef,
  },

  'time_format_id' => {
    data_type => 'integer',
    size => 4,
  },

  'show_tz' => {
    data_type => 'boolean',
    default_value => 'true',
    size => 1,
  },

  'notify_thread_watch' => {
    data_type => 'boolean',
    default_value => 'false',
    size => 1,
  },

  'watch_on_post' => {
    data_type => 'boolean',
    default_value => 'false',
    size => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "people",
  "Person",
  { "foreign.id" => "self.preference_id" },
);

__PACKAGE__->belongs_to(
    "time_format" => "PreferenceTimeString",
    { 'foreign.id' => 'self.time_format_id' },
    { join_type => 'left' },
);


1;
