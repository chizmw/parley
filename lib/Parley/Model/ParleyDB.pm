package Parley::Model::ParleyDB;
# ABSTRACT:  Catalyst DBIC Schema Model
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;

use base 'Catalyst::Model::DBIC::Schema';

#__PACKAGE__->config(
#    schema_class => 'Parley::Schema',
#    connect_info => [
#        'dbi:Pg:dbname=parley',
#        'parley',
#        
#    ],
#);

# CONFIG COMES FROM parley.conf

1;
__END__

=pod

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Parley::Schema>

=cut
