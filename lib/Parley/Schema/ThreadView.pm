package Parley::Schema::ThreadView;

# Created by DBIx::Class::Schema::Loader v0.03004 @ 2006-08-10 09:12:24

use strict;
use warnings;

use base 'DBIx::Class';
use DateTime::Format::Pg;

use Parley::App::DateTime qw( :interval );

__PACKAGE__->load_components('ResultSetManager', "PK::Auto", "Core");
__PACKAGE__->table("thread_view");
__PACKAGE__->add_columns(
  "id" => {
    data_type => "integer",
    default_value => "nextval('thread_view_thread_view_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },

  "watched" => {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },

  "last_notified" => {
    data_type => "timestamp with time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },

  "thread_id" => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => 4
  },
  "timestamp" => {
    data_type => "timestamp with time zone",
    default_value => "now()",
    is_nullable => 0,
    size => 8,
  },
  "person_id" => {
    data_type => "integer",
    default_value => undef,
    is_nullable => 0,
    size => 4
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
    'thread_view_person_key',
    ['person_id', 'thread_id']
);
__PACKAGE__->belongs_to(
    "thread" => "Thread",
    { 'foreign.id' => 'self.thread_id' },
);
__PACKAGE__->belongs_to(
    "person" => "Person",
    { 'foreign.id' => 'self.person_id' }
);




foreach my $datecol (qw/timestamp/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}


sub watching_thread : ResultSet {
    my ($self, $thread, $person) = @_;

    if (not defined $thread) {
        warn 'undefined value passed as $thread in watching_thread()';
        return;
    }
    if (not defined $person) {
        warn 'undefined value passed as $person in watching_thread()';
        return;
    }

    my $thread_view = $self->find(
        {
            person  => $person->id(),
            thread  => $thread->id(),
        }
    );

    return $thread_view->watched();
}

sub notification_list : ResultSet {
    my ($self, $post) = @_;
    my ($schema);

    if (not defined $post) {
        warn 'undefined value passed as $post in notification_list()';
        return;
    }

    # make sure we have full object details
    # [we don't seem to get all the default column data for a new create()]
    $schema = $self->result_source()->schema();
    $post = $schema->resultset('Post')->find(
        id => $post->id()
    );
    if (not defined $post) {
        warn 'failed to re-fetch post in notification_list()';
        return;
    }

    # find the list of people to notify about this update
    my $notification_list = $self->search(
        {
            # the thread the post belongs to
            thread          => $post->thread()->id(),
            # only interested in records where a person is watching
            watched         => 1,
            # and they last viewed the thread before the last post
            timestamp       => {
                '<',
                DateTime::Format::Pg->format_datetime(
                    $post->created()
                )
            },
            # and they've not been notified
            last_notified   => [
                {   '=',    undef   },
                   \'< timestamp'    ,
            ],
            # and they aren't the person that created the post itself
            person          => {
                '!=',
                $post->creator()->id(),
            },
        }
    );

    return $notification_list;
}

sub interval_ago {
    my $self = shift;
    my ($now, $duration, $longest_duration);

    my $interval_string = interval_ago_string(
        $self->timestamp()
    );
    return $interval_string;
}

1;
