package ClassMethod::Model::CMDB::ClassMethod;

use strict;
use warnings;
use base 'DBIx::Class::Core';

sub some_method {
    my $self = shift;
    return 1;
}

=head1 NAME

ClassMethod::Model::CMDB::ClassMethod - Catalyst DBIC Table Model

=head1 SYNOPSIS

See L<ClassMethod>

=head1 DESCRIPTION

Catalyst DBIC Table Model.

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
