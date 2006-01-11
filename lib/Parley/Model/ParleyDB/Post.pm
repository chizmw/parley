package Parley::Model::ParleyDB::Post;

use strict;
use warnings;
use base 'DBIx::Class::Core';
use DateTime::Format::Pg;

__PACKAGE__->inflate_column(
    'created',
    {
        inflate     => sub {
            my $dtf = DateTime::Format::Pg->parse_timestamptz( shift );
            $dtf->set_time_zone('UTC');
            $dtf->set('locale', 'en_GB');
            return $dtf;
        },
        deflate     => sub {
            my $dtf = shift;
            DateTime::Format::Pg->format_timestamptz( $dtf );
        },
    }
);

=head1 NAME

Parley::Model::ParleyDB::Post - Catalyst DBIC Table Model

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
