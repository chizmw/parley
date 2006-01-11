package Parley::Model::ParleyDB::Forum;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->belongs_to(
    last_post => 'Parley::Model::ParleyDB::Post',
);

=head1 NAME

Parley::Model::ParleyDB::Parley - Catalyst DBIC Table Model

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst DBIC Table Model.

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
