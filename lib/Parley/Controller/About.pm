package Parley::Controller::About;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub modules : Local {
    my ( $self, $c ) = @_;
    my $inc_data;

    my @inc_loaded = grep { s/\//::/g; s/\.pm//g; } sort keys %INC;

    foreach my $module_name (@inc_loaded) {
        eval {
            $inc_data->{ $module_name } = $module_name->VERSION();
        };
        push @{$c->stash->{loaded_module_data}},
        {
            name    => $module_name,
            version => $inc_data->{ $module_name },
        };
    }

}


=head1 NAME

Parley::Controller::About - Catalyst Controller

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head1 AUTHOR

Chisel Wright C< <<pause@herlpacker.co.uk>> >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
