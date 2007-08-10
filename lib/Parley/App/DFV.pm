package Parley::App::DFV;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Email::Valid;
use Perl6::Export::Attrs;

sub dfv_constraint_confirm_equal :Export( :constraints ) {
    my ($attrs)  = @_;

    my ($first, $second) = @{ $attrs->{fields} } if $attrs->{fields};

    return sub {
        my $dfv = shift;
        my $data = $dfv->get_filtered_data();

        warn $data->{ $first };
        warn $data->{ $second };

        return ( $data->{$first} eq $data->{$second} );
    }
}

sub dfv_constraint_valid_email :Export( :constraints ) {
    my $attrs = @_;

    return sub {
        my $dfv = shift;
        my $data = $dfv->get_filtered_data();

        return Email::Valid->address($data->{email});
    }
}

1;

__END__

=pod

=head1 NAME

Parley::App::DFV - Functions used with Data::FormValidator

=head1 SYNOPSIS

  use Parley::App::DFV qw( :constraints );

  my %dfv_profile_for = (
    'some_form' => {

        # ...

        constraint_methods => {
            confirm_email =>
                dfv_constraint_confirm_equal(
                    {
                        fields => [qw/email confirm_email/],
                    }
                ),
        },

        # ...

    },
  );

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=cut
