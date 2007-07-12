package Parley::Controller::Help;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Parley::Controller::Help - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    $c->response->body('Matched Parley::Controller::Help in Help.');
}

sub default :Private {
    my ($self, $c) = @_;
    $c->response->body('Help-default');
}


=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
