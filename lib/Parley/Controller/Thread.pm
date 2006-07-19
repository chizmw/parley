package Parley::Controller::Thread;

use strict;
use warnings;
use base 'Catalyst::Controller';

use List::MoreUtils qw{ uniq };

use Parley::App::Helper;
use Data::FormValidator 4.02;
use Data::SpreadPagination;
use DateTime;

our $DFV;

BEGIN {
    $DFV = Data::FormValidator->new(
        {
            'new_topic' => {
                required        => [qw/thread_subject thread_message/],
                field_filters   => {
                    thread_subject  => 'trim',
                    thread_message  => 'trim',
                },
                msgs => {
                    missing => q{One or more required fields are missing},
                    format => '%s',
                },
            },
            'new_reply' => {
                required        => [qw/thread_message/],
                optional        => [qw/thread_subject/],
                field_filters   => {
                    thread_subject  => 'trim',
                    thread_message  => 'trim',
                },
                msgs => {
                    missing => q{One or more required fields are missing},
                    format => '%s',
                },
            },
        }
    );
}

sub view : Local {
    my ($self, $c) = @_;

    # TODO - configure this somewhere, maybe a user preference
    my $rows_per_page = $c->config->{posts_per_page};

    # page to show - either a param, or show the first
    my $page = $c->request->param('page') || 1;

    # if we have a current_post, view the page with the post on it
    if ($c->stash->{current_post}) {
        $c->detach('/post/view');
    }

    # get all the posts in the thread
    $c->stash->{post_list} = $c->model('ParleyDB')->table('post')->search(
        {
            thread => $c->stash->{current_thread}->id(),
        },
        {
            order_by    => 'created ASC',
            rows        => $rows_per_page,
            page        => $page,
        }
    );

    # get the last post on the page
    my ($last_post, $last_post_timestamp);
    $last_post = $c->model('ParleyDB')->table('post')->last_post_in_list(
        $c->stash->{post_list}
    );
    $last_post_timestamp = $last_post->created();

    # ONLY DO THE FOLLOWING IF THE USER IS LOGGED IN
    if ($c->authed_user()) {
        # make a note of when we last viewed this thread
        my $thread_view = $c->model('ParleyDB')->table('thread_view')->find_or_create(
            {
                person      => $c->authed_user()->id(),
                thread      => $c->stash->{current_thread}->id(),
                timestamp   => $last_post_timestamp,
            },
        );
        # set the timestamp the time of the last post on the page (unless the
        # existing time is later)
        if ($thread_view->timestamp() < $last_post_timestamp) {
            $c->log->debug('thread view time is less than last_post time');
            $thread_view->timestamp( $last_post_timestamp );
        }
        $thread_view->update;


        # find out if the user is watching the thread
        $c->stash->{watching_thread} = $c->model('ParleyDB')->table('thread')->watching_thread(
            $c->stash->{current_thread},
            $c->authed_user(),
        );
    }

    # how many people are watching this thread?
    $c->stash->{watcher_count} = $c->model('ParleyDB')->table('thread_view')->count(
        {
            thread  => $c->stash->{current_thread}->id(),
            watched => 1,
        }
    );

    # set up the pager
    $c->stash->{page} = $c->stash->{post_list}->pager();

    # TODO - find a better way to do this
    # set up Data::SpreadPagination
    my $pagination = Data::SpreadPagination->new(
        {
            totalEntries        => $c->stash->{page}->total_entries(),
            entriesPerPage      => $rows_per_page,
            currentPage         => $page,
            maxPages            => 4,
        }
    );
    $c->stash->{page_range_spread} = $pagination->pages_in_spread();

    # increase the number of views
    $self->_increase_view_count($c);
}

sub next_post : Local {
    my ($self, $c) = @_;

    # need to be logged in to use next_post
    # (we don't store last_viewed information for people who aren't logged in)
    Parley::App::Helper->login_if_required($c, q{You must be logged in before you can use the thread continuation functionality.});

    # now get the most recent post the user has seen
    my $last_viewed_post = $c->model('ParleyDB')->table('person')->last_post_viewed_in_thread(
        $c->authed_user(),
        $c->stash->{current_thread},
    );

    # now get the next post after it
    $c->stash->{current_post} = $c->model('ParleyDB')->table('post')->next_post(
        $last_viewed_post
    );

    # now view the next post
    $c->detach('/post/view');
}

sub watch : Local {
    my ($self, $c) = @_;

    my $watched = $c->request->param('watch');
    if (not defined $watched) {
        $watched = 1;
    }

    # need to be logged in to watch threads
    Parley::App::Helper->login_if_required($c, q{You must be logged in before you can watch a topic.});

    # get the ThreadView so we can update it
    my $thread_view = $c->model('ParleyDB')->table('thread_view')->find(
        {
            person  => $c->authed_user()->id(),
            thread  => $c->stash->{current_thread}->id(),
        }
    );

    if (defined $thread_view) {
        my $redirect_url;

        # update the watched status
        $thread_view->watched($watched);
        $thread_view->update;

        # if we have a current post, we can just use 'post/view'
        if (defined $c->stash->{current_post}) {
            $c->detach('/post/view');
        }
        # otherwise we want to redirect back the the same page of the sane
        # thread
        else {
            # page to show - either a param, or show the first
            my $page_number = $c->request->param('page') || 1;

            # build the URL to redirect to
            my $redirect_url = $c->uri_for(
                '/thread',
                'view?thread='
                . $c->stash->{current_thread}->id()
                . "&page=$page_number"
            );

            # redirect to the apropriate place
            $c->response->redirect( $redirect_url );
        }
    }
    else {
        $c->stash->{error}{message} = q{Failed to watch thread};
    }
}

sub add : Local {
    my ($self, $c) = @_;

    # need to be logged in to post
    Parley::App::Helper->login_if_required($c, q{You must be logged in before you can start a new topic.});

    # need to be authenticated to post
    if (not Parley::App::Helper->is_authenticted($c)) {
        $c->stash->{error}{message} = q{You need to authenticate your registration before you can start a new topic.};
    }
}

sub reply : Local {
    my ($self, $c) = @_;

    # need to be logged in to post
    Parley::App::Helper->login_if_required($c, q{You must be logged in before you can add a reply.});

    # need to be authenticated to post
    if (not Parley::App::Helper->is_authenticted($c)) {
        $c->stash->{error}{message} = q{You need to authenticate your registration before you can reply to a topic.};
        return;
    }

    # grab the post we're replying to
    $self->_get_thread_reply_post($c);
     
    # XXX
    if (defined $c->stash->{current_post}) {
        my $post_position = $c->model('ParleyDB')->table('post')->thread_position(
            $c->stash->{current_post},
        );
        $c->log->info( $c->stash->{current_post}->id() . ' is at position ' . $post_position);
        my $page_number =  $c->model('ParleyDB')->table('post')->page_containing_post(
            $c->stash->{current_post},
            $c->config->{posts_per_page},
        );
        $c->log->info( $c->stash->{current_post}->id() . ' is on page #' . $page_number);
    }
    # XXX


    # quoting a post?
    if ($c->request->param('quote_post')) {
        $c->log->info('QUOTE THE POST!');
        $c->stash->{quote_post} = $c->stash->{current_post};
    }
}

sub post : Local {
    my ($self, $c) = @_;
    my (@messages);

    # assume success, deal with failure later
    $c->stash->{template} = 'thread/view';

    if ($c->request->param('post_topic')) {
        @messages = $self->_add_new_topic($c);
    }
    elsif ($c->request->param('post_reply')) {
        @messages = $self->_add_new_reply($c);
    }
    elsif ($c->request->param('cancel_new_topic')) {
        $c->response->redirect(
            $c->uri_for(
                  '/forum/view?forum='
                . $c->stash->{current_forum}->id()
            )
        );
    }

    if (scalar @messages) {
        $c->log->error('FillInForm needed');
        # show the appropriate template
        if ($c->request->param('post_topic')) {
            $c->stash->{template} = 'thread/add';
        }
        elsif ($c->request->param('post_reply')) {
            $c->stash->{template} = 'thread/reply';
        }
        $c->stash->{messages} = \@messages;

        # get the post we're replying to
        my $status = $self->_get_thread_reply_post($c);
        if (not $status) {
            return;
        }
    }
}

sub _add_new_topic {
    my ($self, $c) = @_;
    my ($results, @messages, $new_thread, $new_post);

    if ($DFV) {
        $results = $DFV->check($c->request->parameters, 'new_topic');
    };

    if ($results || !$DFV) {
        # transaction method taken from:
        #  http://search.cpan.org/~mstrout/DBIx-Class-0.04999_01/lib/DBIx/Class/Manual/Cookbook.pod#Transactions
        eval {
            # start a transaction
            $c->model('ParleyDB')->table('thread')->storage->txn_begin;

            # create a new thread
            $new_thread = $c->model('ParleyDB')->table('thread')->create(
                {
                    forum       => $c->stash->{current_forum}->id(),
                    subject     => $results->valid->{thread_subject},
                    creator     => $c->authed_user->id(),
                }
            );

            # create a new post in the new thread
            $new_post = $c->model('ParleyDB')->table('post')->create(
                {
                    thread      => $new_thread->id(),
                    subject     => $results->valid->{thread_subject},
                    message     => $results->valid->{thread_message},
                    creator     => $c->authed_user->id(),
                }
            );

            # update information about the most recent forum/thread post
            $self->_update_last_post($c, $new_post);

            # increase the post count for the thread
            $self->_increase_post_count($c, $new_thread);

            # increase the post count for the user
            $self->_update_person_post_info($c, $c->authed_user, $new_post);

            # commit everything
            $c->model('ParleyDB')->table('thread')->storage->txn_commit;
        };
        # any errors?
        if ($@) {
            # put something in the logs
            $c->log->error($@);
            # put something useful for the user to see
            push @messages, q{Failed to insert new post information};
            # rollback
            eval { $c->model('ParleyDB')->table('thread')->storage->txn_rollback };
        }

        # view the new thread - but only if no errors
        if (not scalar(@messages)) {
            $c->response->redirect(
                $c->uri_for(
                      '/thread/view?thread='
                    . $new_thread->id()
                )
            );
        }
    }
    else {
        $c->log->error('DFV failed');
        push @messages, map {$_} values %{$results->msgs};
    }

    return (uniq(sort @messages));
}

sub _add_new_reply {
    my ($self, $c) = @_;
    my ($results, @messages, $new_post);

    if ($DFV) {
        $results = $DFV->check($c->req->parameters, 'new_reply');
    };

    if ($results || !$DFV) {
        # transaction method taken from:
        #  http://search.cpan.org/~mstrout/DBIx-Class-0.04999_01/lib/DBIx/Class/Manual/Cookbook.pod#Transactions
        eval {
            # start a transaction
            $c->model('ParleyDB')->table('post')->storage->txn_begin;

            # create a new reply to a thread
            $new_post = $c->model('ParleyDB')->table('post')->create(
                {
                    thread      => $c->stash->{current_thread}->id(),
                    subject     => ($results->valid->{thread_subject} || undef),
                    message     => $results->valid->{thread_message},
                    creator     => $c->authed_user->id(),
                }
            );

            # if we have current_post information it means this is in reply to
            # another post (instead of just a new post to a thread)
            if (defined $c->stash->{current_post}) {
                $new_post->reply_to( $c->stash->{current_post}->id() );
                $new_post->update();
            }

            # do we have a quoted post? if we do we need to store the
            # (potentially ammended) quoted text, and the actual post being
            # quoted (so we can get author, date, etc)
            if (defined $c->request->param('have_quoted_post')) {
                $new_post->quoted_post( $c->stash->{current_post}->id() );
                $new_post->quoted_text( $c->req->param('quote_message') );
                $new_post->update();
            }

            # get the full object record
            $new_post = $c->model('ParleyDB')->table('post')->find(
                {
                    post_id => $new_post->id(),
                }
            );

            # update information about the most recent forum/thread post
            $self->_update_last_post($c, $new_post);

            # increase the post count for the thread
            $self->_increase_post_count($c, $c->stash->{current_thread});

            # increase the post count for the user
            $self->_update_person_post_info($c, $c->authed_user, $new_post);

            # commit everything
            $c->model('ParleyDB')->table('post')->storage->txn_commit;
        };
        # any errors?
        if ($@) {
            # put something in the logs
            $c->log->error($@);
            # put something useful for the user to see
            push @messages, q{Failed to insert new post information};
            # rollback
            eval { $c->model('ParleyDB')->table('post')->storage->txn_rollback };
        }

        # now get a list of people we want to send an alert to
        $c->model('ParleyDB')->table('thread')->storage->debug(1);
        my $alert_list = $c->model('ParleyDB')->table('thread')->new_post_alert_list(
            $c->stash->{current_thread},
            $new_post,
        );
        if (defined $alert_list) {
            $c->log->dumper( $alert_list->count() );

           while (my $cd = $alert_list->next) { $c->log->dumper( $cd ); }

        }
        $c->model('ParleyDB')->table('thread')->storage->debug(0);

        # view the new thread - but only if no errors
        if (not scalar(@messages)) {
            $c->response->redirect(
                $c->uri_for(
                      '/thread/view?thread='
                    . $c->stash->{current_thread}->id()
                    . '&post='
                    . $new_post->id()
                )
            );
        }
    }
    else {
        $c->log->error('DFV failed');
        push @messages, map {$_} values %{$results->msgs};
    }

    return (uniq(sort @messages));
}

sub _update_last_post {
    my ($self, $c, $new_post) = @_;

    # get the thread the post lives in
    my $thread = $new_post->thread;

    # get the forum the thread lives in
    my $forum = $thread->forum;

    # set the last_post for both forum and thread
     $forum->last_post($new_post->post_id());
    $thread->last_post($new_post->post_id());
     $forum->update();
    $thread->update();
}

sub _increase_view_count {
    my ($self, $c) = @_;

    # increase the number of views for the thread
    # transaction method taken from:
    #  http://search.cpan.org/~mstrout/DBIx-Class-0.04999_01/lib/DBIx/Class/Manual/Cookbook.pod#Transactions
    eval {
        # start a transaction
        $c->model('ParleyDB')->table('thread')->storage->txn_begin;

        # we don't need to get the thread, it's in our stash,
        # and if it isn't we have bigger problems
        # increase the view count for the thread
        $c->stash->{current_thread}->view_count(
            $c->stash->{current_thread}->view_count() + 1
        );
        $c->stash->{current_thread}->update();
            
        # commit everything
        $c->model('ParleyDB')->table('thread')->storage->txn_commit;
    };
    # any errors?
    if ($@) {
        # put something in the logs
        $c->log->error($@);
        # rollback
        eval { $c->model('ParleyDB')->table('thread')->storage->txn_rollback };
    }
}

sub _increase_post_count {
    my ($self, $c, $thread) = @_;

    # increase the number of replies for the thread
        $thread->post_count(
            $thread->post_count() + 1
        );
        $thread->update();
}

sub _update_person_post_info {
    my ($self, $c, $person, $post) = @_;

    # increase the post count for the user
    $person->post_count( $person->post_count() + 1 );
    # make a note of their last post
    $person->last_post( $post->id() );
    # push the changes back tot the db
    $person->update();

}

sub _get_thread_reply_post {
    my ($self, $c) = @_;
    my ($posts);

    # it would be good to display the relevant post in the thread, so people know
    # what they're replying to
    # - if adding a reply, assume the first post
    # - if we have a post value, then that's the one we're replying to
    if (defined $c->stash->{current_post}) {
        # get the specific post we're responding to
        $posts = $c->model('ParleyDB')->table('post')->search(
            {
                post_id     => $c->stash->{current_post}->id(),
            },
            {
                rows        => 1,
            }
        );
    }
    elsif (defined $c->stash->{current_thread}) {
        # get the first post in the thread
        $posts = $c->model('ParleyDB')->table('post')->search(
            {
                thread      => $c->stash->{current_thread}->id(),
            },
            {
                order_by    => 'created ASC',
                rows        => 1,
            }
        );
    }
    else {
        $c->stash->{error}{message} = q{No information for thread or post to reply to};
        return;
    }

    # if we don't have one post, something really odd happened
    if (1 != $posts->count()) {
        $c->stash->{error}{message} = q{I don't know how you managed to reply to a thread with no posts};
        return;
    }

    # save the first (and only) post from our results
    $c->stash->{responding_to_post} = $posts->first();

    # be successful
    return 1;
}

=head1 NAME

Parley::Controller::Thread - Catalyst Controller

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
