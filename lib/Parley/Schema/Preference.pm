package Parley::Schema::Preference;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("preference");
__PACKAGE__->add_columns(
  "timezone",
  {
    data_type => "text",
    default_value => "'UTC'::text",
    is_nullable => 0,
    size => undef,
  },

  "preference_id",
  {
    data_type => "integer",
    default_value => "nextval('preference_preference_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },

  'time_format' => {
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
);
__PACKAGE__->set_primary_key("preference_id");
__PACKAGE__->has_many(
  "people",
  "Person",
  { "foreign.preference" => "self.preference_id" },
);

__PACKAGE__->belongs_to("time_format", "PreferenceTimeString", { preference_time_string_id => "time_format" });


1;

