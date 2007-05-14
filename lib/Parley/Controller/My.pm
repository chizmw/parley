package Parley::Controller::My;

use strict;
use warnings;
use base 'Catalyst::Controller';

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global class data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

my %dfv_profile_for = (
    # DFV validation profile for adding a new topic
    timezone => {
        require_some => {
            tz_data => [ 1, qw(use_utc selectZone) ],
        },

        filters     => [qw( trim )],
        msgs => {
            format  => q{%s},
            missing => q{One or more required fields are missing},

            constraints => {
                tz_data => 'you must do stuff',
            },
        },
    },
);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller Actions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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


    # data we always want in the stash for /my

    # what's the current time? then we can show it in the TZ area
    $c->stash->{current_time} = DateTime->now();

    # fetch timezone categories
    my $tz_categories = DateTime::TimeZone->all_names();
    $c->stash->{tz_categories} = $tz_categories;

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

    return;
}

sub update :Path('/my/preferences/update') {
    my ($self, $c) = @_;
    # use the my/preferences template
    $c->stash->{template} = 'my/preferences';

    # are we updating TZ information?
    # validate the form data
    $c->form(
        $dfv_profile_for{timezone}
    );
    # deal with missing/invalid fields
    if ($c->form->has_missing()) {
        $c->stash->{view}{error}{message} = q{You must fill in all the required fields};
        foreach my $f ( $c->form->missing ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }
    }
    elsif ($c->form->has_invalid()) {
        $c->stash->{view}{error}{message} = q{One or more fields are invalid};
        foreach my $f ( $c->form->invalid ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }
    }

    # otherwise, the form data is ok ...
    else {
        $c->log->debug(
            ref($c->_authed_user()->preference())
        );
        $c->response->redirect( $c->uri_for('/my/preferences') );
    }

    return;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Private Methods
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
