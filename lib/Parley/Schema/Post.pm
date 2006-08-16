package Parley::Schema::Post;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use DateTime::Format::Pg;

use base 'DBIx::Class';

__PACKAGE__->load_components("ResultSetManager", "PK::Auto", "Core");
__PACKAGE__->table("post");
__PACKAGE__->add_columns(
  "creator",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "subject",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "quoted_post",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "message",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "quoted_text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "created",
  {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "thread",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "reply_to",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "post_id",
  {
    data_type => "integer",
    default_value => "nextval('post_post_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "edited",
  {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("post_id");
__PACKAGE__->has_many("threads", "Thread", { "foreign.last_post" => "self.post_id" });
__PACKAGE__->has_many("forums", "Forum", { "foreign.last_post" => "self.post_id" });
__PACKAGE__->belongs_to("creator", "Person", { person_id => "creator" });
__PACKAGE__->belongs_to("reply_to", "Post", { post_id => "reply_to" });
__PACKAGE__->has_many(
  "post_reply_toes",
  "Post",
  { "foreign.reply_to" => "self.post_id" },
);
__PACKAGE__->belongs_to("thread", "Thread", { thread_id => "thread" });
__PACKAGE__->belongs_to("quoted_post", "Post", { post_id => "quoted_post" });
__PACKAGE__->has_many(
  "post_quoted_posts",
  "Post",
  { "foreign.quoted_post" => "self.post_id" },
);
__PACKAGE__->has_many("people", "Person", { "foreign.last_post" => "self.post_id" });




foreach my $datecol (qw/created/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}




sub last_post_in_list : ResultSet {
    my ($self, $post_list) = @_;

    my $posts_in_list = $post_list->count();
    warn "posts_in_list:   $posts_in_list\n";
    my $splice_position = $posts_in_list - 2;
    warn "splice_position: $splice_position\n";

    # get the last post on the page
    my $slice = $post_list->slice(
        $splice_position,
        $splice_position,
    );
    warn "posts_in_slice:   " . $slice->count() . "\n";
    warn (ref($slice));

    if (defined $slice->first()) {
        warn "first in slice is defined\n";
        warn $slice->first()->created();
        return $slice->first();
    }

    warn "return naff all\n";
    return;
}

sub my_damn_function {
}

1;

