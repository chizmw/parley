package Parley::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

use List::MoreUtils qw{ uniq };
use Digest::MD5 qw{ md5_hex };
use Readonly;
use Time::Piece;
use Time::Seconds;

use Data::FormValidator 4.02;
use Data::FormValidator::Constraints qw(:closures);

Readonly my $LIFETIME => Time::Seconds::ONE_WEEK;
our $DFV;

# used by DFV
sub _confirm_equal {
    my $val1 = shift;
    my $val2 = shift;
    return ( $val1 eq $val2 );
}

BEGIN {
    # used to setup $DFV here
}

sub login : Path('/user/login') {
    my ( $self, $c ) = @_;

    # default form message
    $c->stash->{'message'} = 'Please enter your username and password';
    # if we have a custom message to use ..
    $c->stash->{'login_message'} = delete( $c->session->{login_message} );

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

            if ( $c->session->{after_login} ) {
                $c->response->redirect( delete $c->session->{after_login} );
            }
            # if we've just been through Forgotten Password, don't go back there
            elsif ($c->request->referer() =~ m{user/password/}) {
                # go to the default app URL
                $c->response->redirect( $c->uri_for($c->config()->{default_uri}) );
            }
            # redirect to where we were referred from, unless our referer is our action
            elsif ( $c->request->referer() =~ m{\A$base}xms and $c->request->referer() !~ m{$action\z}xms) {
                $c->response->redirect( $c->request->referer() );
            }
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
    my ( $self, $c ) = @_;

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
vim: ts=8 sts=4 et sw=4 sr sta

=pod

=head1 NAME

Parley::Controller::User - Catalyst Controller

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
