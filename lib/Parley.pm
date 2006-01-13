package Parley;

use strict;
use warnings;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the applications root directory
#
use Catalyst qw/
    -Debug
    Dumper

    Email
    Static::Simple

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    Authentication
    Authentication::Store::DBIC
    Authentication::Credential::Password

    FillInForm
/;
use YAML;

our $VERSION = '0.05';

#
# Configure the application
#
__PACKAGE__->config( YAML::LoadFile(__PACKAGE__->config->{'home'}.'/parley.yml') );
__PACKAGE__->config( version => $VERSION );
__PACKAGE__->setup;

=head1 NAME

Parley - Catalyst based application

=head1 SYNOPSIS

    script/forum_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=head2 default

=cut

sub auto : Private {
    my ($self, $c) = @_;

    # if we have a user ... fetch some info (if we don't already have it)
    if ( $c->user and not defined $c->session->{authed_user} ) {
        $c->log->info('Fetching user information');
        # XXX once we've worked out has_one or belongs_to ...
        if (0) {
#            my $results = $m_person->search(
#                'authentication.username'   => $c->user->user->username(),
#            );
#            $c->log->debug('results returned: ' . $results->count());
#            $c->session->{authed_user} = $results->first();
#            $c->log->dumper( $c->session->{authed_user} );
        }

        # XXX for now do it the long way ...
        else {
            # get the (first) authentication record
            my $auth = $c->model('ParleyDB')->table('authentication')->search(
                'username' => $c->user->user->username(),
            )->first();
            # get the corresponding persion record
            my $person = $c->model('ParleyDB')->table('person')->search(
                'authentication' => $auth->authentication_id,
            );

            # if count isn't one we have a problem
            if (1 != $person->count()) {
                # TODO use a nicer error page
                die "we've got two mathing usernames for a lookup on " . $c->user->user->username();
            }
            # store the person information
            $c->session->{authed_user} = $person->first();
        }
    }



    # do we have a post id in the URL?
    if (defined $c->req->param('post')) {
        if (not $c->req->param('post') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} = 'non-integer post id passed: ['
                . $c->req->param('post')
                . ']';
            return;
        }
        $c->log->debug('setting: current_post');
        $c->stash->{current_post} = $c->model('ParleyDB')->table('post')->search(
            post_id  => $c->req->param('post'),
        )->first;

        # set the current_thread from the current_post
        $c->log->debug('setting: current_thread');
        $c->stash->{current_thread} = $c->stash->{current_post}->thread();

        # set the current_forum from the current thread
        $c->log->debug('setting: current_forum');
        $c->stash->{current_forum} = $c->stash->{current_thread}->forum();
    }

    # do we have a thread id in the URL?
    elsif (defined $c->req->param('thread')) {
        if (not $c->req->param('thread') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} = 'non-integer thread id passed: ['
                . $c->req->param('thread')
                . ']';
            return;
        }
        $c->log->debug('setting: current_thread');
        $c->stash->{current_thread} = $c->model('ParleyDB')->table('thread')->search(
            thread_id  => $c->req->param('thread'),
        )->first;

        # set the current_forum from the current thread
        $c->log->debug('setting: current_forum');
        $c->stash->{current_forum} = $c->stash->{current_thread}->forum();
    }

    # do we have a forum id in the URL?
    elsif (defined $c->req->param('forum')) {
        if (not $c->req->param('forum') =~ m{\A\d+\z}) {
            $c->stash->{error}{message} = 'non-integer forum id passed: ['
                . $c->req->param('forum')
                . ']';
            return;
        }
        $c->log->debug('setting: current_forum');

        $c->stash->{current_forum} = $c->model('ParleyDB')->table('forum')->search(
            forum_id  => $c->req->param('forum'),
        )->first;
    }

    return 1;
}


#
# Output a friendly welcome message
#
sub default : Private {
    my ( $self, $c ) = @_;

    # redirect to the default fop action
    $c->response->redirect( $c->req->base . $c->config->{default_uri} );
}


sub end : Private {
    my ($self, $c) = @_;

    die 'forced debug' if $c->debug && $c->request->params->{dump_info};
    return 1
        if $c->response->status =~ m{^3\d\d^};
    return 1
        if $c->response->body;
    if (not $c->response->content_type) {
        $c->response->content_type('text/html; charset=utf-8');
    }

    # if we have any error(s) in the stash, automatically show the error page
    if (defined $c->stash->{error}) {
        $c->stash->{template} = 'error/simple';
    }

    return $c->forward($c->config->{view})
        if $c->config->{view};

    my ($comp) = $c->comp('^' . ref($c) . '::(V|View)::');
    $c->forward(ref $comp);

    # (re)populate the form
    $c->fillform( $c->stash->{formdata} );
}
        
=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
