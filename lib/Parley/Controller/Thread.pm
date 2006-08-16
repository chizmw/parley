package Parley::Controller::Thread;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::Thread in Thread.');
}

1;

__END__

=pod

=head1 NAME

Parley::Controller::Thread - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
