package Parley::Schema::Person;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("person");
__PACKAGE__->add_columns(
  "id" => {
    data_type => "integer",
    #default_value => "nextval('person_person_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "authentication_id" => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 1,
    size => 4
  },
  "last_name" => {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "email" => {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "forum_name" => {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "preference_id" => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 1,
    size => 4
  },
  "last_post_id" => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 1,
    size => 4
  },
  "post_count" => {
    data_type => "integer",
    default_value => 0,
    is_nullable => 0,
    size => 4
  },
  "first_name" => {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->resultset_class('Parley::ResultSet::Person');

__PACKAGE__->add_unique_constraint(
    "person_forum_name_key",
    ["forum_name"]
);
__PACKAGE__->add_unique_constraint(
    "person_email_key",
    ["email"]
);
__PACKAGE__->has_many(
    "threads" => "Thread" =>
    { "foreign.creator_id" => "self.id" }
);
__PACKAGE__->has_many(
  "email_queues",
  "EmailQueue",
  { "foreign.recipient_id" => "self.id" },
);
__PACKAGE__->has_many(
    "posts" => "Post",
    { "foreign.creator_id" => "self.id" });
__PACKAGE__->has_many(
  "thread_views" => "ThreadView",
  { "foreign.person_id" => "self.id" },
);
__PACKAGE__->belongs_to(
    "preference" => "Preference",
    { 'foreign.id' => "self.preference_id" }
);
__PACKAGE__->belongs_to(
    "last_post" => "Post",
    { 'foreign.id' => "self.last_post_id" });
__PACKAGE__->belongs_to(
  "authentication" => "Authentication",
  { 'foreign.id' => 'self.authentication_id' },
);
__PACKAGE__->has_many(
  "registration_authentications",
  "RegistrationAuthentication",
  { "foreign.recipient" => "self.id" },
);

__PACKAGE__->has_many(
    map_user_role => 'Parley::Schema::UserRole',
    'person_id',
    { join_type => 'right' }
);

sub roles {
    my $record = shift;
    my ($schema, $rs);

    $schema = $record->result_source()->schema();

    $rs = $schema->resultset('Role')->search(
        {
            'person.id'  => $record->id(),
        },
        {
            prefetch => [
                { 'map_user_role' => 'person' },
            ],
        }
    );

    return $rs;
}

sub check_user_roles {
    my $record = shift;
    my @roles  = @_;

    my ($schema, $rs);

    $schema = $record->result_source()->schema();

    $rs = $schema->resultset('Role')->search(
        {
            'map_user_role.person_id'   => $record->id(),
            'me.name' => {
                -in => \@roles,
            },
        },
        {
            prefetch => [
                { 'map_user_role' => 'person' },
            ],
        },
    );

    return ($rs->count == scalar(@roles) || 0);
}

1;
