package Parley::Controller::Site;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use base 'Catalyst::Controller';

use JSON;
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

sub users : Local {
    my ($self, $c) = @_;

    $c->stash->{users_with_roles} =
        $c->model('ParleyDB::Person')->users_with_roles()
    ;
}

sub user : Local {
    my ($self, $c) = @_;
    my $pid = $c->request->param('pid');

    if (defined $pid && $pid =~ m{\A\d+\z}xms) {
        $c->stash->{person} =
            $c->model('ParleyDB::Person')->find($pid)
        ;

        $c->stash->{roles} =
            $c->model('ParleyDB::Role')->role_list();
    }
    else {
        $c->response->redirect(
            $c->uri_for('/site/users/')
        );
        return;
    }
}

sub users_autocomplete : Local {
    my ($self, $c) = @_;
    my @results;

    my $stuff = $c->model('ParleyDB::Person')->search(
        {
            forum_name => { -ilike => $c->request->param('query') . q{%} },
        },
        {
            'order_by' => 'forum_name',
            columns => [qw/id forum_name first_name last_name/],
        }
    );

    while (my $person = $stuff->next) {
        my %data = $person->get_columns;
        push @results, \%data;
    }

    $c->response->body(
        to_json( 
            {
                ResultSet => {
                    person => \@results,
                }
            }
        )
    );
    return;
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
