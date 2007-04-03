package Parley::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

# deal with user login requests on user/login
sub login : Path('/user/login') {
    my ( $self, $c ) = @_;

    # default form message
    $c->stash->{'message'} = 'Please enter your username and password';
    # if we have a custom message to use ..
    $c->stash->{'login_message'} = delete( $c->session->{login_message} );
    # make sure we use the correct template - we sometimes detach() here
    $c->stash->{template} = 'user/login';

    # if we have a username, try to log the user in
    if ( $c->request->param('username') ) {
        # try to log the user in
        my $login_status = $c->login(
            $c->request->param('username'),
            $c->request->param('password'),
        );

        # if we have a user we're logged in
        if ( $login_status ) {
            my $base    = $c->request->base();
            my $action  = $c->request->action();

            $c->log->debug("base:   $base");
            $c->log->debug("action: $action");

            # if we've stored somewhere to go after we log-in, got there now
            if ( $c->session->{after_login} ) {
                $c->response->redirect( delete $c->session->{after_login} );
            }

            # (else) if we've just been through Forgotten Password, don't go back there
            elsif ($c->request->referer() =~ m{user/password/}) {
                # go to the default app URL
                $c->response->redirect( $c->uri_for($c->config()->{default_uri}) );
            }

            # (else) redirect to where we were referred from, unless our referer is our action
            elsif ( $c->request->referer() =~ m{\A$base}xms and $c->request->referer() !~ m{$action\z}xms) {
                # go to where we came from
                $c->response->redirect( $c->request->referer() );
            }

            # (else) if all else fails go to the application's default_uri
            else {
                $c->response->redirect( $c->uri_for($c->config()->{default_uri}) );
            }
        }

        # otherwise we failed to login, try again!
        else {
            $c->stash->{'message'}
                = 'Unable to authenticate the login details supplied';
        }
    }
}

sub logout : Path('/user/logout') {
    my ($self, $c) = @_;

    # session logout, and remove information we've stashed
    $c->logout;
    delete $c->session->{'authed_user'};

    # redisplay the page we were on, or just do the 'default' action
    my $base    = $c->request->base();
    my $action  = $c->request->action();
    # redirect to where we were referred from, unless our referer is our action
    if ( $c->request->referer() =~ m{\A$base}xms and $c->request->referer() !~ m{$action\z}xms) {
        $c->response->redirect( $c->request->referer() );
    }
    else {
        $c->response->redirect( $c->uri_for($c->config()->{default_uri}) );
    }
}



1;

__END__

=head1 NAME

Parley::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
