package Parley::Schema::ThreadView;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("thread_view");
__PACKAGE__->add_columns(
  "watched",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "thread_view_id",
  {
    data_type => "integer",
    default_value => "nextval('thread_view_thread_view_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "last_notified",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "thread",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "timestamp",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 0,
    size => 8,
  },
  "person",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("thread_view_id");
__PACKAGE__->add_unique_constraint("thread_view_person_key", ["person", "thread"]);
__PACKAGE__->belongs_to("thread", "Thread", { thread_id => "thread" });
__PACKAGE__->belongs_to("person", "Person", { person_id => "person" });

1;

