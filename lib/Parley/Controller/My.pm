package Parley::Controller::My;
use strict;
use warnings;
use base 'Catalyst::Controller';
use Parley::App::Helper;

use DateTime::TimeZone;

sub auto : Private {
    my ($self, $c) = @_;
    # need to be logged in to perform any 'my' actions
    Parley::App::Helper->login_if_required(
        $c,
        q{You must be logged in before you can access this area}
    );

    # undecided if you need to be authed to perform 'my' actions
    #if (not Parley::App::Helper->is_authenticted($c)) {
    #    $c->stash->{error}{message} = q{You need to authenticate your registration before you can start a new topic.};
    #}

    return 1;
}


sub preferences : Local {
    my ($self, $c) = @_;
    my ($tz_categories);

    $tz_categories = DateTime::TimeZone->categories();
    $c->stash->{tz_categories} = $tz_categories;

    # if the user has a timezone picked (and it's not UTC) pre-populate the menus
    my $user_pref = $c->session->{authed_user}->preference();
    $c->log->dumper( $user_pref );
    if (defined (my $user_tz = $user_pref->timezone())) {
        $c->log->info( $user_tz );
        # deal with UTC differently
        if ($user_tz eq 'UTC') {
            $c->stash->{formdata}{use_utc} = 1;
        }
        else {
            my ($zone, $place, @items);

            # match <zone>/<place>
            ($zone,$place) = ($user_tz =~ m{\A(.+?)\/(.+?)\z});

            # set the zone
            $c->stash->{formdata}{selectZone} = $zone;
            # set the place
            $c->stash->{formdata}{selectPlace} = $place;

            # fetch information for the place
            @items = _select_data_from_zone( $zone );
            # put information into the stash
            $c->stash->{selectPlaceData} = \@items;
        }
    }
}

sub select_place : Path('/my/preferences/setSelectPlaces') {
    my ( $self, $c ) = @_;
    my ($zone, @places, @items);

    $zone = $c->request->param('zone');
    @places = DateTime::TimeZone->names_in_category($zone);
    @items = _select_data_from_zone( $zone );

    $c->stash(
        select => {
            id    => 'selectPlace',
            items => \@items
        },
        template => 'my/selectplace_ajaxresult'    # TT response template
    );
    $c->forward('Parley::View::NoHeader');
}

sub _select_data_from_zone {
    my ($zone) = @_;
    my (@places, @items);

    @places = DateTime::TimeZone->names_in_category($zone);

    if (scalar(@places)) {
        @items = ('[ Select Zone ]', @places);
    }
    else {
        push @items, '[ Select Zone First ]';
    }

    return @items;
}

=head1 NAME

Parley::Controller::My - Catalyst Controller

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
