package Parley::App::I18N;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Perl6::Export::Attrs;

sub first_valid_locale :Export( :locale ) {
    my ($c) = @_;

    foreach my $lang ( @{$c->languages} ) {
        if (-d $c->path_to( 'root', 'base', 'help', $lang) ) {
            return $lang;
        }
    }

    # default to a generic english variant
    return 'en';
}

1;

__END__

=head1 NAME

Parley::App::I18N - i18n helper functions

=head1 SYNOPSIS

  use Parley::App::I18N qw( :locale );

  first_valid_locale($c);

=head1 SEE ALSO

L<Parley::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
