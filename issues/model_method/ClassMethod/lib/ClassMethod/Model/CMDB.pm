package ClassMethod::Model::CMDB;

use strict;
use base 'Catalyst::Model::DBIC';

__PACKAGE__->config(
    dsn           => 'dbi:Pg:dbname=classmethod',
    user          => '',
    password      => '',
    options       => {},
    relationships => 1
);

=head1 NAME

ClassMethod::Model::CMDB - Catalyst DBIC Model

=head1 SYNOPSIS

See L<ClassMethod>

=head1 DESCRIPTION

Catalyst DBIC Model.

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
