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

__PACKAGE__->has_many(
    'forum_moderators',
    'ForumModerator',
    {
        'foreign.forum' => 'self.forum',
    }
);


foreach my $datecol (qw/created/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}

# This is slightly complicated; the way we find the last post a user has seen
# in a thread is:
#
# - If there is a thread_view entry for person-thread then find the last post
#    made on or before that time
# - If there is no thread_view entry, then the user has never seen the thread
#   before, in which case the last post viewed is considered to be the
#   first post in the thread
sub last_post_viewed_in_thread :ResultSet {
    my ($self, $person, $thread) = @_;
    my ($last_viewed, $last_post) = @_;

    my $schema = $self->result_source()->schema();

    # we need to be careful that we haven't deleted/hidden the post that
    # matches the exact timestamp of last_viewed for a thread - this is why we
    # use <= and not ==, since we can just return the latest undeleted post

    # get the entry (if any) for person-thread from the thread_view table
    $last_viewed = $schema->resultset('ThreadView')->find(
        {
            person  => $person->id(),
            thread  => $thread->id(),
        }
    );

    # if we don't have a $last_viewed, then return the thread's first post
    if (not defined $last_viewed) {
        warn "thread has never been viewed - returning first post in thread";

        # get all the posts in the thread, oldest first
        my $posts_in_thread = $schema->resultset('Post')->search(
            {
                thread  => $thread->id(),
            },
            {
                rows        => 1,
                order_by    => 'created ASC',
            }
        );

        # set the first post
        $last_post = $posts_in_thread->first();
    }

    # otherwise, find the most recent post made on or before the timestamp in
    # $last_viewed
    else {
        warn q{looking for a post on or before } . $last_viewed->timestamp();

        # get a list of posts created on or before our last-post time, newest
        # first
        my $list_of_posts = $schema->resultset('Post')->search(
            {
                created => {
                    '<=',
                    DateTime::Format::Pg->format_datetime(
                        $last_viewed->timestamp()
                    )
                },
                thread  => $thread->id(),
            },
            {
                rows        => 1,
                order_by    => 'created DESC',
            }
        );

        # the most recent post is the first (and only) post in our list
        $last_post = $list_of_posts->first();
    }

    # we should now have a Post object in $last_post
    if (not defined $last_post) {
        warn q{$last_post is undefined in last_post_viewed_in_thread()};
        return;
    }

    # return the last post ..
    return $last_post;
}

sub _last_post_viewed_in_thread :ResultSet {
    my ($self, $person, $thread) = @_;
    my ($last_viewed, $last_post);

    my $schema = $self->result_source()->schema();

    # we need to be careful that we haven't deleted/hidden the post that
    # matches the exact timestamp of last_viewed for a thread - this is why we
    # use <= and not ==, since we can just return the latest undeleted post

    # get the "last_viewed" value from thread_view
    $last_viewed = $schema->resultset('ThreadView')->search(
        {
            person  => $person->id(),
            thread  => $thread->id(),
        },
        {
            rows => 1,
        }
    );

    # if last_viewed isn't defined, it should mean the user has never viewed
    # this thread
    if (not defined $last_viewed) {
        warn "thread has never been viewed - returning first post in thread";

        $last_post = $schema->resultset('Post')->search(
            {
                thread  => $thread->id(),
            },
            {
                rows        => 1,
                order_by    => 'created ASC',
            }
        );

        return $last_post->first();
    }
        
    #die dump(ref $last_viewed);
    if (not $last_viewed->count()) {
        warn "no matches for 'last viewed' in last_post_viewed_in_thread()";
        return;
    }

    # now get the last post made on or before our timestamp for when we last
    # viewed the thread
    $last_post = $schema->resultset('Post')->search(
        {
            created => {
                '<=', 
                DateTime::Format::Pg->format_datetime($last_viewed->timestamp())
            },
            thread  => $thread->id(),
        },
        {
            rows        => 1,
            order_by    => 'created DESC',
        }
    );

    # return the first result (if we have any)
    if ($last_post->count()) {
        return $last_post->first();
    }

    # oh well, we didn't get anything
    # XXX this might cause problems in the future, but we'll see
    return;
}


1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta
