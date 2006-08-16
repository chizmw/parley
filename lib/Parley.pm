package Parley;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use Catalyst qw/
    -Debug
    Dumper
    StackTrace

    ConfigLoader

    Email
    Static::Simple

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    Authentication
    Authentication::Store::DBIC
    Authentication::Credential::Password

    Prototype
    FillInForm
    DefaultEnd
/;


our $VERSION = '0.10-pre';

__PACKAGE__->config( version => $VERSION );
__PACKAGE__->setup;

# only show certain log levels in output
__PACKAGE__->log (Catalyst::Log->new( @{__PACKAGE__->config->{log_levels}} ));

# I'm sure there's a (better) way to do this by overriding set()/get() in Class::Accessor
{
    sub set_get {
        my $c = shift;
        my $key = shift;

        if(@_ == 1) {
            $c->stash->{$key} = $_[0];
        }
        elsif(@_ > 1) {
            $c->stash->{$key} = [@_];
        }

        $c->stash->{$key};
    }

    sub _authed_user {
        my $c = shift;
        $c->set_get('authed_user', @_);
    }
    sub _current_post {
        my $c = shift;
        $c->set_get('current_post', @_);
    }
    sub _current_thread {
        my $c = shift;
        $c->set_get('current_thread', @_);
    }
    sub _current_forum {
        my $c = shift;
        $c->set_get('current_forum', @_);
    }
}


=head1 NAME

Parley - Catalyst based application

=head1 SYNOPSIS

    script/parley_server.pl

=head1 DESCRIPTION

Catalyst driven forum application

=head1 EVIL, LAZY STASH ACCESS

I know someone will look at this at some point and tell me this is evil, but
I've added some get/set method shortcuts for commonly used stash items.

=over 4

=item $c->_authed_user

get/set value stored in $c->stash->{_authed_user}:

  $c->_authed_user( $some_value );

=item $c->_current_post

get/set value stored in $c->stash->{_current_post}:

  $c->current_post( $some_value );

=item $c->_current_thread

get/set value stored in $c->stash->{_current_thread}:

  $c->_current_thread( $some_value );

=item $c->_current_forum

get/set value stored in $c->stash->{_current_forum}:

  $c->_current_forum( $some_value );

=back

=head1 SEE ALSO

L<Parley::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
