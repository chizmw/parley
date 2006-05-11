package AuthTest::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

AuthTest::Controller::Root - Root Controller for this Catalyst based application

=head1 SYNOPSIS

See L<AuthTest>.

=head1 DESCRIPTION

Root Controller for this Catalyst based application.

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( 'Dummy Content' );

    
    $c->model('ParleyTest')->table('authentication')->storage->txn_begin;
    my $new_auth = $c->model('ParleyTest')->table('authentication')->create(
        {
            username => scalar(localtime),
            password => 'pwd',
        }
    );
    $c->log->dumper($new_auth->{_column_data}, 'NEW_AUTHENTICATION');
    $c->model('ParleyTest')->table('authentication')->storage->txn_rollback;


    $c->model('ParleyTest')->table('preference')->storage->txn_begin;
    my $new_pref = $c->model('ParleyTest')->table('preference')->create(
        {
            timezone => 'UTC',
        }
    );
    $c->log->dumper($new_pref->{_column_data}, 'NEW_PREFERENCE');
    $c->model('ParleyTest')->table('preference')->storage->txn_rollback;


}

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
