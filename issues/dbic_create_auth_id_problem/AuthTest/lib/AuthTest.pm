package AuthTest;

use strict;
use warnings;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the application's root 
# directory
#
use Catalyst qw/ConfigLoader Static::Simple Dumper/;

our $VERSION = '0.01';

#
# Start the application
#
__PACKAGE__->setup;

#
# IMPORTANT: Please look into AuthTest::Controller::Root for more
#

=head1 NAME

AuthTest - Catalyst based application

=head1 SYNOPSIS

    script/authtest_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 SEE ALSO

L<AuthTest::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Chisel Wright,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
