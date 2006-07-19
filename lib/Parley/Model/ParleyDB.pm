package Parley::Model::ParleyDB;
use strict;

use base 'Catalyst::Model::DBIC';

__PACKAGE__->config(
    dsn           => 'dbi:Pg:dbname=parley',
    user          => 'parley',
    password      => undef,
    options       => {
        AutoCommit => 1,
    },
    relationships => 1,

    debug   => 0,
);

=head1 NAME

Parley::Model::ParleyDB - Catalyst DBIC Model

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst DBIC Model.

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
