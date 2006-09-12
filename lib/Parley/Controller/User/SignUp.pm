package Parley::Controller::User::SignUp;

use strict;
use warnings;
use base 'Catalyst::Controller';

use List::MoreUtils qw{ uniq };
use Digest::MD5 qw{ md5_hex };
use Email::Valid;
use Readonly;
use Time::Piece;
use Time::Seconds;

#use Data::FormValidator 4.02;
#use Data::FormValidator::Constraints qw(:closures);

# used by DFV
sub _dfv_constraint_confirm_equal {
    my $dfv  = shift;
    my $val1 = shift;
    my $val2 = shift;

    return ( $val1 eq $val2 );
}

sub _dfv_constraint_valid_email {
    my $dfv   = shift;
    my $email = shift;

    return Email::Valid->address($email);
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Global class data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Readonly my $LIFETIME => Time::Seconds::ONE_WEEK;

my %dfv_profile_for = (
    'signup' => {
        required => [ qw(
                username password confirm_password email confirm_email
                first_name last_name forum_name
        ) ],

        filters => [qw(trim)],

        constraint_methods => {
            confirm_password => {
                name => 'confirm_password',
                constraint  => \&_dfv_constraint_confirm_equal,
                params      => [qw( password confirm_password )],
            },
            email => {
                name => 'email',
                constraint_method => \&_dfv_constraint_valid_email,
                params      => [qw( email )],
            },
            Xconfirm_email => {
                name => 'Xconfirm_email',
                constraint  => \&_dfv_constraint_confirm_equal,
                params      => [qw( email confirm_email )],
            },

            confirm_email => {
                name        => q{confirm_email},
                constraint  => \&_dfv_constraint_confirm_equal,
                params      => [qw( email confirm_email )],
            },

        },

        msgs => {
            constraints => {
                confirm_password => q{The passwords do not match},
                confirm_email => q{The email addresses do not match},
                email => q{You must enter a valid email address},
            },
            missing => q{One or more required fields are missing},
            format => '%s',
        },
    },
);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller Actions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub authenticate : Path('/user/authenticate') {
    my ($self, $c, $auth_id) = @_;

    # we should have an auth-id in the url
    if (not defined $auth_id) {
        $c->stash->{error}{message} = q{Incomplete authentication URL};
        return;
    }

    # fetch the info from the database
    my $regauth = $c->model('ParleyDB')->resultset('RegistrationAuthentication')->find(
        {
            registration_authentication_id => $auth_id,
        }
    );

    # if we don't have any matches then the id was bogus
    if (not defined $regauth) {
        $c->stash->{error}{message} = q{Bogus authentication ID};
        return;
    }

    # TODO
    # if we get this far, we've got a valid ID, so we can yank out their details,
    # and to be safe we'll finish the process by asking them for their password
    #
    # for now, we assume the link clicking is good enough, and we mark them
    # as authenticated

    # get the person matching the ID
    $c->stash->{signup_user} = $c->model('ParleyDB')->resultset('Person')->find(
        {
            person_id => $regauth->recipient->person_id(),
        }
    );

    # get the first (and should be only) match
    $c->log->dumper($c->stash->{signup_user}->{_column_data});

    # mark the person as authenticated
    $c->stash->{signup_user}->authentication->authenticated(1);
    $c->stash->{signup_user}->authentication->update();

    # delete registration_authentication record
    $regauth->delete;

    # set a suitable success template
    $c->stash->{template} = 'user/auth_success';
}


sub signup : Path('/user/signup') {
    my ( $self, $c ) = @_;
    my (@messages);

    # deal with form submissions
    if (defined $c->request->method()
            and $c->request->method() eq 'POST'
            and defined $c->request->param('form_submit')
    ) {
        @messages = $self->_user_signup($c);
    }

    if (scalar @messages) {
        $c->stash->{messages} = \@messages;
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller (Private/Helper) Methods
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub _add_new_user {
    my ($self, $c) = @_;
    my ($valid_results, @messages, $new_user);

    # less typing
    $valid_results = $c->form->valid;

    # is the requested username already in use?
    if ($self->_username_exists($c, $valid_results->{username})) {
        push @messages, q{The username you have chosen is already in use. Please try a different one.};
    }
    # is the requested email address already in use?
    if ($self->_email_exists($c, $valid_results->{email})) {
        push @messages, q{The email address you have chosen is already in use.<br />Please try a different one, or use the <a href="user/password/forgotten">Forgotten Password</a> page.};
    }
    # is the requested forum name already in use?
    if ($self->_forumname_exists($c, $valid_results->{forum_name})) {
        push @messages, q{The forum name you have chosen is already in use. Please try a different one.};
    }

    # if we DON'T have any messages, then there were no errors, so we can try
    # to add the new user
    if (not scalar @messages) {
        # make the new user inside a transaction
        eval {
            $new_user = $c->model('ParleyDB')->schema->txn_do(
                sub { return $self->_txn_add_new_user($c) }
            );
        };
        # deal with any transaction errors
        if ($@) {                                   # Transaction failed
            die "something terrible has happened!"  #
                if ($@ =~ /Rollback failed/);       # Rollback failed

            $c->stash->{error}{message} = qq{Database transaction failed: $@};
            $c->log->error( $@ );
            return;
        }
    }


    # return our error messages (if any)
    return sort(@messages);
}

sub _create_regauth {
    my ($self, $c, $person) = @_;
    my ($random, $invitation);

    # if it's good enough for Cozens, it's good enough for me
    $random = md5_hex(time.(0+{}).$$.rand);

    # create an invitation
    $invitation = $c->model('ParleyDB')->resultset('RegistrationAuthentication')->create(
        {
            'registration_authentication_id'	=> $random,
            'recipient'				=> $person->person_id,
            'expires'				=> Time::Piece->new(time + $LIFETIME)->datetime,
        }
    );

    return $invitation;
}

sub _email_exists {
    my ($self, $c, $email) = @_;
    # look for the specified email
    $c->log->info("Looking for: $email");
    my $match_count = $c->model('ParleyDB')->resultset('Person')->count(
        email => $email,
    );
    # return the number of matches
    return $match_count;
}

sub _forumname_exists {
    my ($self, $c, $forum_name) = @_;
    # look for the specified forum_name
    $c->log->info("Looking for: $forum_name");
    my $match_count = $c->model('ParleyDB')->resultset('Person')->count(
        forum_name => $forum_name,
    );
    # return the number of matches
    return $match_count;
}

sub _new_user_authentication_email {
    my ($self, $c, $person) = @_;
    my ($invitation, $send_status);

    # create a new reg-auth entry
    $invitation = $self->_create_regauth($c, $person);

    # send an email off to the (new) user
    $send_status = $c->send_email(
        {
            template    => q{authentication_email.eml},
            person      => $person,
            headers => {
                from    => $c->application_email_address(),
                subject => qq{Activate your @{[$c->config->{name}]} registration},
            },
            template_data => {
                regauth => $invitation,
            },
        }
    );

    return $send_status;
}

sub _user_signup {
    my ($self, $c) = @_;
    my ($results, @messages);

    # validate the form data
    $c->form(
        $dfv_profile_for{signup}
    );

    # deal with missing/invalid fields
    if ($c->form->has_missing()) {
        $c->stash->{view}{error}{message} = q{You must fill in all the required fields};
        foreach my $f ( $c->form->missing ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }
    }
    elsif ($c->form->has_invalid()) {
        $c->stash->{view}{error}{message} = q{One or more fields are invalid};
        foreach my $f ( $c->form->invalid ) {
            push @{ $c->stash->{view}{error}{messages} }, $f;
        }
    }

    # otherwise the form data is ok...
    else {
        @messages = $self->_add_new_user($c, $results);
    }

    return (uniq(sort @messages));
}

sub _username_exists {
    my ($self, $c, $username) = @_;
    # look for the specified username
    $c->log->info("Looking for: $username");
    my $match_count = $c->model('ParleyDB')->resultset('Authentication')->count(
        username => $username,
    );
    # return the number of matches
    return $match_count;
}


# send notification email

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Functions for database transactions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub _txn_add_new_user {
    my ($self, $c) = @_;
    my ($valid_results, $new_auth, $new_person, $status_ok);

    # less typing
    $valid_results = $c->form->valid;

    # add authentication record
    $new_auth = $c->model('ParleyDB')->resultset('Authentication')->create(
        {
            username => $c->form->valid->{username},
            password => md5_hex( $c->form->valid->{password} ),
        }
    );

    # add new person
    $new_person = $c->model('ParleyDB')->resultset('Person')->create(
        {
            first_name      => $valid_results->{first_name},
            last_name       => $valid_results->{last_name},
            forum_name      => $valid_results->{forum_name},
            email           => $valid_results->{email},
            authentication  => $new_auth->id(),
        }
    );

    # send an authentication email
    $status_ok = $self->_new_user_authentication_email( $c, $new_person );

    # if we sent the email OK take them off to a "it worked" type screen
    if ($status_ok) {
        $c->stash->{newdata}  = $new_person;
        $c->stash->{template} = q{user/auth_emailed};
    }
}



1;
__END__

=pod

=head1 NAME

Parley::Controller::User::SignUp

=cut

vim: ts=8 sts=4 et sw=4 sr sta
