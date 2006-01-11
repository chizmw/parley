package Parley::View::TT;

use strict;
use base 'Catalyst::View::TT';

# allow us to configure TT from the application config
__PACKAGE__->config( Parley->config->{template} );

=head1 NAME

Parley::View::TT - Catalyst TT View

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst TT View.

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
