package Parley::Model::ParleyDB::Thread;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use Carp;
use DateTime::Format::Pg;

__PACKAGE__->belongs_to(
    last_post => 'Parley::Model::ParleyDB::Post',
);

__PACKAGE__->inflate_column(
    'created',
    {
        inflate     => sub {
            my $dtf = DateTime::Format::Pg->parse_timestamptz( shift );
            $dtf->set_time_zone('UTC');
            $dtf->set('locale', 'en_GB');
            return $dtf;
        },
        deflate     => sub {
            my $dtf = shift;
            DateTime::Format::Pg->format_timestamptz( $dtf );
        },
    }
);

sub watching_thread {
    my ($self, $thread, $person) = @_;

    if (not defined $thread) {
        warn 'undefined value passed as $thread in watching_thread()';
        return;
    }
    if (not defined $person) {
        warn 'undefined value passed as $person in watching_thread()';
        return;
    }

    my $thread_view = Parley::Model::ParleyDB::ThreadView->find(
        {
            person  => $person->id(),
            thread  => $thread->id(),
        }
    );

    return $thread_view->watched();
}

sub new_post_alert_list {
    my ($self, $thread, $last_post) = @_;

    if (not defined $thread) {
        Carp::carp('undefined value passed as $thread in new_post_alert_list()');
        return;
    }
    if (not defined $last_post) {
        Carp::carp('undefined value passed as $last_post in new_post_alert_list()');
        return;
    }

    # - get a list of people watching thread X
    # - whos last_viewed timestamp is LESS than the timestamp of the last post in the thread
    #
    # This would give an alert for each new post ... so:
    #
    # - only email matches where last_viewed timestamp > last_notified (or is NULL)
    my $list = Parley::Model::ParleyDB::ThreadView->search(
        {
            watched     => 1,
            thread      => $thread->id(),
            person      => { '!=', $last_post->creator->id() },
            timestamp   => { '<', DateTime::Format::Pg->format_datetime($last_post->created()) },
             
            last_notified   => [
                -and =>
                #{ '<', DateTime::Format::Pg->format_datetime($last_post->created()) },
                    [ \'< timestamp', {'==', undef} ],
            ],

        },
    );

    return $list;
}

=head1 NAME

Parley::Model::ParleyDB::Thread - Catalyst DBIC Table Model

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst DBIC Table Model.

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
