package Parley::Schema::Person;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("person");
__PACKAGE__->add_columns(
  "person_id",
  {
    data_type => "integer",
    default_value => "nextval('person_person_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "authentication",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "last_name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "email",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "forum_name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "preference",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "last_post",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "post_count",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "first_name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("person_id");
__PACKAGE__->add_unique_constraint("person_forum_name_key", ["forum_name"]);
__PACKAGE__->add_unique_constraint("person_email_key", ["email"]);
__PACKAGE__->has_many("threads", "Thread", { "foreign.creator" => "self.person_id" });
__PACKAGE__->has_many(
  "email_queues",
  "EmailQueue",
  { "foreign.recipient" => "self.person_id" },
);
__PACKAGE__->has_many("posts", "Post", { "foreign.creator" => "self.person_id" });
__PACKAGE__->has_many(
  "thread_views",
  "ThreadView",
  { "foreign.person" => "self.person_id" },
);
__PACKAGE__->belongs_to("preference", "Preference", { preference_id => "preference" });
__PACKAGE__->belongs_to("last_post", "Post", { post_id => "last_post" });
__PACKAGE__->belongs_to(
  "authentication",
  "Authentication",
  { authentication_id => "authentication" },
);
__PACKAGE__->has_many(
  "registration_authentications",
  "RegistrationAuthentication",
  { "foreign.recipient" => "self.person_id" },
);

1;

