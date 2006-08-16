package Parley::Controller::Thread;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub view : Local {
    my ($self, $c) = @_;

    # TODO - configure this somewhere, maybe a user preference
    my $rows_per_page = $c->config->{posts_per_page};

    # page to show - either a param, or show the first
    my $page = $c->request->param('page') || 1;

    # if we have a current_post, view the page with the post on it
    if ($c->_current_post) {
        $c->detach('/post/view');
    }

    ##################################################
    # get all the posts in the thread
    ##################################################
    $c->stash->{post_list} = $c->model('ParleyDB')->resultset('Post')->search(
        {
            thread => $c->_current_thread->id(),
        },
        {
            order_by    => 'created ASC',
            rows        => $rows_per_page,
            page        => $page,
        }
    );

    ##################################################
    # some updates for logged in users
    ##################################################
    if ($c->_authed_user) {
        $c->log->debug('thread view by authed user');

        # update thread_view for user
        $self->_update_thread_view($c);

        # store thread watch status info
        $self->_watching_thread($c);
    }

    ##################################################
    # general information for all viewers
    ##################################################
    {
        # get the number of people watching the thread
        $self->_thread_watch_count($c);
    }

    1; # return 'true'
}

sub _thread_watch_count {
    my ($self, $c) = @_;

    # how many people are watching the current thread?
    $c->stash->{watcher_count} = $c->model('ParleyDB')->resultset('ThreadView')->count(
        {
            thread  => $c->_current_thread()->id(),
            watched => 1,
        }
    );
}



sub _watching_thread {
    my ($self, $c) = @_;
    
    # find out if the user is watching the thread, and store it in the stash
    $c->stash->{watching_thread} = $c->model('ParleyDB')->resultset('ThreadView')->watching_thread(
        $c->_current_thread(),
        $c->_authed_user(),
    );
}

sub _update_thread_view {
    my ($self, $c) = @_;

    my ($last_post, $last_post_timestamp);
    
    # get the last post on the page
    $last_post = $c->model('ParleyDB')->resultset('Post')->last_post_in_list(
        $c->stash->{post_list}
    );
    # get the timestamp of the last post
    $last_post_timestamp = $last_post->created();
    $c->log->debug( $last_post_timestamp );

    # make a note of when the user last viewed this thread, if a record doesn't already exist
    my $thread_view = $c->model('ParleyDB')->resultset('ThreadView')->find_or_create(
        {
            person      => $c->_authed_user()->id(),
            thread      => $c->_current_thread()->id(),
            timestamp   => $last_post_timestamp,
        },
    );

    # set the timestamp the time of the last post on the page (unless the
    # existing time is later)
    if ($thread_view->timestamp() < $last_post_timestamp) {
        $c->log->debug('thread view time is less than last_post time');
        $thread_view->timestamp( $last_post_timestamp );
    }

    # update/store the thread_view record
    $thread_view->update;
}

1;

__END__

=pod

=head1 NAME

Parley::Controller::Thread - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 ACTIONS

=head2 view

This action prepares data in the stash for viewing the current thread.

=head1 PRIVATE METHODS

=head2 _thread_watch_count

Sets C<$c-E<gt>stash-E<gt>{watcher_count}> with the number of people who have a watch
set for the current thread.

=head2 _watching_thread

Sets C<$c-E<gt>stash-E<gt>{watching_thread}> with a true|false value indicating
whether the current authenticated user is watching the current thread.

Sets 

=head2 _update_thread_view

This method updates an existing record in the thread_view table, or creates a
new one if it doesn't exist.

The timestamp value for the record (keyed on I<person-thread>) is updated to
the timestamp of the creation time for the last post on the page - unless the
user has already viewed a page containing later posts.

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
