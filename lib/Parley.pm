package Parley;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use Catalyst qw/
    -Debug
    Dumper
    StackTrace

    ConfigLoader

    FormValidator
    FillInForm

    Email
    Static::Simple

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    Authentication
    Authentication::Store::DBIC
    Authentication::Credential::Password
/;

use Parley::App::Communication::Email qw( :email );

our $VERSION = '0.53_004';

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

################################################################################


sub application_email_address {
    my ($c) = @_;

    my $address = 
          $c->config->{alerts}{from_name}
        . q{ <}
        . $c->config->{alerts}{from_address}
        . q{>}
    ;

    return $address;
}


sub is_logged_in {
    my ($c) = @_;

    if ($c->user) {
        return 1;
    }

    return 0;
}

sub login_if_required {
    my ($c, $message) = @_;

    if( not $c->is_logged_in($c) ) {
        # make sure we return here after a successful login
        $c->session->{after_login} = $c->request->uri();
        # set an informative message to display on the login screen
        if (defined $message) {
            $c->session->{login_message} = $message;
        }
        # send the user to the login screen
        $c->detach( '/user/login' );
        return;
    }
}

1;

__END__

=pod

=head1 NAME

Parley - Catalyst based application

=head1 SYNOPSIS

    script/parley_server.pl

=head1 DESCRIPTION

Catalyst driven forum application

=head1 METHODS

=head2 application_email_address($c)

=over 4

B<Return Value:> $string

=back

Returns the email address string for the application built from the
I<from_name> and I<from_address> in the alerts section of parley.yml

=head2 is_logged_in($c)

=over 4

B<Return Value:> 0 or 1

=back

Returns 1 or 0 depending on whether there is a logged-in user or not.

=head2 login_if_required($c,$message)

=over 4

B<Return Value:> Void Context

=back

If a user isn't logged in, send them to the login page, optionally setting the
message for the login box.

Once logged in the user should (by virtue of stored session data, and login
magic) be redirected to wherever they were trying to view before the required
login.

=head2 send_email($c,\%options)

=over 4

B<Return Value:> 0 or 1

=back

Send an email using the render() method in the TT view. \%options should
contain the following keys:

=over 4

=item headers

Header fields to be passed though to the call to L<Catalyst::Plugin::Email>.

=item person

A Parley::Schema::Person object for the intended recipient of the message.

Or, any object with an email() method, and methods to match
"S<[% person.foo() %]>"
methods called in the email template(s).

=item template

Used to store the name of the email template(s) to be sent. I<Currently the
application only sends plain-text emails, so only one file is specified.>

The text template name should be passed in ->{template}{text}.

The html template name should be passed in ->{template}{html}. (I<Not Implemented>)

=back

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

L<Parley::Controller::Root>, L<Catalyst::Plugin::Email>, L<Catalyst>

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
