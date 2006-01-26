package Parley::Controller::Thread;

use strict;
use warnings;
use base 'Catalyst::Controller';

use List::MoreUtils qw{ uniq };

use Parley::App::Helper;
use Data::FormValidator 4.02;

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

    # get all the posts in the thread
    $c->stash->{post_list} = $c->model('ParleyDB')->table('post')->search(
        {
            thread => $c->stash->{current_thread}->id(),
        },
        {
            order_by    => 'created ASC',
        }
    );

    # increase the number of views
    $self->_increase_view_count($c);
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
        $c->response->redirect( $c->request->base() . 'forum/view?forum=' . $c->stash->{current_forum}->id());
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
                    creator     => $c->session->{authed_user}->id(),
                }
            );

            # create a new post in the new thread
            $new_post = $c->model('ParleyDB')->table('post')->create(
                {
                    thread      => $new_thread->id(),
                    subject     => $results->valid->{thread_subject},
                    message     => $results->valid->{thread_message},
                    creator     => $c->session->{authed_user}->id(),
                }
            );

            # update information about the most recent forum/thread post
            $self->_update_last_post($c, $new_post);

            # increase the post count for the thread
            $self->_increase_post_count($c, $new_thread);

            # increase the post count for the user
            $self->_update_person_post_info($c, $c->session->{authed_user}, $new_post);

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
            $c->response->redirect( $c->req->base . 'thread/view?thread=' . $new_thread->id() );
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
                    creator     => $c->session->{authed_user}->id(),
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

            # update information about the most recent forum/thread post
            $self->_update_last_post($c, $new_post);

            # increase the post count for the thread
            $self->_increase_post_count($c, $c->stash->{current_thread});

            # increase the post count for the user
            $self->_update_person_post_info($c, $c->session->{authed_user}, $new_post);

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

        # view the new thread - but only if no errors
        if (not scalar(@messages)) {
            $c->response->redirect( $c->req->base . 'thread/view?thread=' . $c->stash->{current_thread}->id() );
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
