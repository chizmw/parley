package Parley::Controller::Site;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'Catalyst::Controller';

use Proc::Daemon;
use Proc::PID::File;

use Parley::App::Error qw( :methods );

sub auto : Private {
    my ($self, $c) = @_;

    if (not $c->stash->{site_moderator}) {
        parley_warn($c, $c->localize(q{SITE MODERATOR REQUIRED}));

        $c->response->redirect(
            $c->uri_for(
                $c->config->{default_uri}
            )
        );
        return 0;
    }

    return 1;
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::Site in Site.');
}

sub services : Local {
    my ($self, $c) = @_;

    # does the email engine appear to be running?
    # get the pid file ...
    my $pid = Proc::PID::File->running(
        debug   => 0,
        name    => q{parley_email_engine},
        dir     => q{/tmp},
    );
    $c->stash->{email_engine}{pid} = $pid;
}


=head1 NAME

Parley::Controller::Site - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut


=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
