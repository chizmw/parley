package Parley::Controller::My;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub auto : Private {
    my ($self, $c) = @_;
    # need to be logged in to perform any 'my' actions
    my $status = $c->login_if_required(
        q{You must be logged in before you can access this area}
    );
    if (not defined $status) {
        return 0;
    }

    # undecided if you need to be authed to perform 'my' actions
    #if (not Parley::App::Helper->is_authenticted($c)) {
    #    $c->stash->{error}{message} = q{You need to authenticate your registration before you can start a new topic.};
    #}

    return 1;
}


sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::My in My.');
}


sub preferences : Local {
    my ($self, $c) = @_;
    my ($tz_categories);

    # where did we come from? it would be nice to return there when we're done
    if ($c->request->referer() !~ m{/my/preferences}xms) {
        $c->session->{my_pref_came_from} = $c->request->referer();
    }

    # what's the current time? then we can show it in the TZ area
    $c->stash->{current_time} = DateTime->now();

    # fetch timezone categories
    $tz_categories = DateTime::TimeZone->categories();
    $c->stash->{tz_categories} = $tz_categories;



    return;
}

=head1 NAME

Parley::Controller::My - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
