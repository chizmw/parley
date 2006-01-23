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
}

sub select_country : Path('/my/preferences/setSelectCities') {
    my ( $self, $c ) = @_;
    my ($country, @cities, @items);

    $country = $c->request->param('country');
    @cities = DateTime::TimeZone->names_in_category($country);

    if (scalar(@cities)) {
        @items = ('[ Select City ]', @cities);
    }
    else {
        push @items, '[ Select Country First ]';
    }

    $c->log->dumper( \@items, 'COUNTRY_LIST' );
    $c->stash(
        select => {
            id    => 'selectCity',
            items => \@items
        },
        template => 'my/selectcountry_ajaxresult'    # TT response template
    );
    $c->forward('Parley::View::NoHeader');
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
