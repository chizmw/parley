package Parley::Schema::Thread;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('ResultSetManager', "PK::Auto", "Core");
__PACKAGE__->table("thread");
__PACKAGE__->add_columns(
  "thread_id",
  {
    data_type => "integer",
    default_value => "nextval('thread_thread_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "locked",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "creator",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "subject",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "active",
  {
    data_type => "boolean",
    default_value => "true",
    is_nullable => 0,
    size => 1,
  },
  "forum",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "created",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "last_post",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "sticky",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
  "post_count",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "view_count",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("thread_id");
__PACKAGE__->belongs_to("creator", "Person", { person_id => "creator" });
__PACKAGE__->belongs_to("last_post", "Post", { post_id => "last_post" });
__PACKAGE__->belongs_to("forum", "Forum", { forum_id => "forum" });
__PACKAGE__->has_many("posts", "Post", { "foreign.thread" => "self.thread_id" });
__PACKAGE__->has_many(
  "thread_views",
  "ThreadView",
  { "foreign.thread" => "self.thread_id" },
);



foreach my $datecol (qw/created/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}




1;

