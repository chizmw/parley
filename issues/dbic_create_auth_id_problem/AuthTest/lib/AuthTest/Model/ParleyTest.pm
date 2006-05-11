package AuthTest::Model::ParleyTest;

use strict;
use base 'Catalyst::Model::DBIC';

__PACKAGE__->config(
    dsn           => 'dbi:Pg:dbname=parleytest',
    user          => 'parleytest',
    password      => '',
    options       => {},
    relationships => 1
);

=head1 NAME

AuthTest::Model::ParleyTest - Catalyst DBIC Model

=head1 SYNOPSIS

See L<AuthTest>

=head1 DESCRIPTION

Catalyst DBIC Model.

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
