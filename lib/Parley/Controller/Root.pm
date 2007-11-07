package Parley::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Parley::App::Terms qw( :terms );
use Parley::App::Error qw( :methods );

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

# pre-populate values in the stash if we're given "appropriate" information:
# - _authed_user
# - _current_post
# - _current_thread
# - _current_forum
sub auto : Private {
    my ($self, $c) = @_;

    # get a list of (all/available) forums
    $c->stash->{available_forums} = $c->model('ParleyDB')->resultset('Forum')->search(
        {
            active  => 1,
        },
        {
            order_by    => 'name ASC',
        }
    );

    ##################################################
    # do we have a post id in the URL?
    ##################################################
    if (defined $c->request->param('post')) {
        # make sure the paramter looks sane
        if (not $c->request->param('post') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} =
                  $c->localize('non-integer post id passed')
                . ': ['
                . $c->request->param('post')
                . ']';
            return;
        }

        # get the matching post
        $c->_current_post(
            $c->model('ParleyDB')->resultset('Post')->find(
                {
                    'me.id'  => $c->request->param('post')
                }
            )
        );

        # set the current_thread from the current_post
        $c->_current_thread(
            $c->_current_post->thread()
        );

        # set the current_forum from the current thread
        $c->_current_forum(
            $c->_current_thread->forum()
        );
    }
    ##################################################
    # (elsif) do we have a thread id in the URL?
    ##################################################
    elsif (defined $c->request->param('thread')) {
        # make sure the paramter looks sane
        if (not $c->request->param('thread') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} =
                  $c->localize('non-integer thread id passed')
                . ': ['
                . $c->request->param('thread')
                . ']';
            return;
        }

        # get the matching thread
        $c->_current_thread(
            $c->model('ParleyDB')->resultset('Thread')->find(
                {
                    'me.id'  => $c->request->param('thread'),
                }
            )
        );

        # set the current_forum from the current thread
        $c->_current_forum(
            $c->_current_thread->forum()
        );
    }
    ##################################################
    # do we have a forum id in the URL?
    ##################################################
    elsif (defined $c->request->param('forum')) {
        # make sure the paramter looks sane
        if (not $c->request->param('forum') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} =
                  $c->localize('non-integer forum id passed')
                . ': ['
                . $c->request->param('forum')
                . ']';
            return;
        }

        # get the matching forum
        $c->_current_forum(
            $c->model('ParleyDB')->resultset('Forum')->find(
                {
                    'me.id'  => $c->request->param('forum'),
                }
            )
        );
    }

    ############################################################
    # if we have a user ... fetch some info (if we don't already have it)
    ############################################################
    if ( $c->user and not defined $c->_authed_user ) {
        $c->log->info('Fetching user information for ' . $c->user->id);

        # get the person info for the username
        my $row = $c->model('ParleyDB')->resultset('Person')->find(
            {
                'authentication.username'   => $c->user->username(),
            },
            {
                join => 'authentication',
                prefetch => [
                    'authentication',
                    { 'preference' => 'time_format' },
                ],
            },
        );
        $c->_authed_user( $row );

        # make sure they've agreed to any (new) T&Cs
        my $status = terms_check($c, $c->_authed_user);
        if (not $status) {
            $c->res->body('need to accept');
            $c->log->debug('User needs to accept T&Cs');
            return 0;
        }
    }


    ######################################
    # TopDog is always a site moderator
    # ####################################
    if (defined $c->_authed_user() and 0 == $c->_authed_user()->id()) {
        $c->log->debug( q{topdog user site-moderates anything he wants} );
        $c->stash->{site_moderator} = 1;
    }

    ##################################################
    # if we are logged in and if we have a current_forum, can the (current)
    # user moderate it?
    ##################################################
    if (defined $c->_authed_user() and defined $c->_current_forum()) {
        # 'topdog' user can moderate anything
        if (0 == $c->_authed_user()->id()) {
            $c->log->debug( q{topdog user moderates anything he wants} );
            $c->stash->{moderator} = 1;
        }
        else {
            # look up person/forum
            my $results = $c->model('ParleyDB')->resultset('ForumModerator')->find(
                {
                    person_id       => $c->_authed_user()->id(),
                    forum_id        => $c->_current_forum()->id(),
                    can_moderate    => 1,
                },
                {
                    key     => 'forum_moderator_person_key',
                }
            );
            # if we found something, they must moderate the current forum
            if ($results) {
                #$c->log->debug( q{user moderates this forum} );
                $c->stash->{moderator} = 1;
            }
        }
    }

    # let things continue ...
    return 1;
}

# if someone hits the application index '/' then send them off to the default
# action (defined in the app-config)
sub index : Private {
    my ( $self, $c ) = @_;
    # redirect to the default action
    $c->response->redirect( $c->uri_for($c->config->{default_uri}) );
}

# by default show a 404 for anything we don't know about
sub default : Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->response->body( $c->localize('404 Not Found') );
}


# deal with the end of the phase
sub render : ActionClass('RenderView') {
    my ($self, $c) = @_;

    # if we have any error(s) in the stash, automatically show the error page
    if (defined $c->stash->{error}) {
        $c->stash->{template} = 'error/simple';
        $c->log->error( $c->stash->{error}{message} );
    }

    if (has_died($c)) {
        $c->stash->{template} = 'error/simple';
        $c->log->error( @{ $c->stash->{view}{error}{messages} } );
    }
}

sub end : Private {
    my ($self, $c) = @_;
    $c->forward('render');

    # fill in any forms
    $c->fillform( );
    $c->fillform( $c->stash->{formdata} );
}


1;

__END__


=pod

=head1 NAME

Parley::Controller::Root - Root Controller for Parley

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

Used to fetch user-information if the user has authenticated.

Also pre-populate current_(post|thread|forum) values in the stash if we have
appropriate information in the URL's query parameters.

=head2 default

Emit a 404 status and a 'Not Found' message.

=head2 end

Attempt to render a view, if needed.

If I<error> is defined in the stash, render the error template.

=head2 index

Redirect to the applications default action, as defined by I<default_uri> in
parley.yml

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
