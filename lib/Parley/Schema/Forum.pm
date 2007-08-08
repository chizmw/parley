package Parley::Schema::Forum;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("forum");
__PACKAGE__->add_columns(
  "last_post",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "post_count",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "forum_id",
  {
    data_type => "integer",
    default_value => "nextval('forum_forum_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "active",
  {
    data_type => "boolean",
    default_value => "true",
    is_nullable => 0,
    size => 1,
  },
  "name",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "description",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("forum_id");
__PACKAGE__->add_unique_constraint("forum_name_key", ["name"]);
__PACKAGE__->has_many("threads", "Thread", { "foreign.forum" => "self.forum_id" });
__PACKAGE__->belongs_to("last_post", "Post", { post_id => "last_post" });

sub moderators {
    my $self = shift;
    my ($schema, $results, @modlist);

    $schema = $self->result_source()->schema();

    # get all forum_moderators for a given forum
    $results = $schema->resultset('ForumModerator')->search(
        {
            forum           => $self->id(),
            can_moderate    => 1,
        },
    );

    while (my $res = $results->next()) {
        push @modlist, $res->person();
    }

    return \@modlist;
}

1;

