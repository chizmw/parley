package Parley::Controller::User::SignUp;

use strict;
use warnings;
use base 'Catalyst::Controller';

use List::MoreUtils qw{ uniq };
use Digest::MD5 qw{ md5_hex };
use Readonly;
use Time::Piece;
use Time::Seconds;

use Data::FormValidator 4.02;
use Data::FormValidator::Constraints qw(:closures);

Readonly my $LIFETIME => Time::Seconds::ONE_WEEK;
our $DFV;

# used by DFV
sub _confirm_equal {
    my $val1 = shift;
    my $val2 = shift;
    return ( $val1 eq $val2 );
}

BEGIN {
    $DFV = Data::FormValidator->new(
        {   
            'signup' => {
                required => [
                    qw/
                        username password confirm_password email confirm_email
                        first_name last_name forum_name
                    /
                ],

                field_filters => {
                    username        => 'trim',
                    email           => 'trim',
                    confirm_email   => 'trim',
                    first_name      => 'trim',
                    last_name       => 'trim',
                    forum_name      => 'trim',
                },

                constraints => {
                    confirm_password => {
                        name => 'confirm_password',
                        constraint  => \&_confirm_equal,
                        params      => [qw( password confirm_password )],
                    },
                    email => {
                        name => 'email',
                        constraint_method => email(),
                    },
                    confirm_email => {
                        name => 'confirm_email',
                        constraint  => \&_confirm_equal,
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
        }
    );
}

sub signup : Path('/user/signup') {
    my ( $self, $c ) = @_;
    my (@messages);

    if ($c->req->param('form_submit')) {
        @messages = $self->_user_signup($c);
    }

    if (scalar @messages) {
        $c->stash->{messages} = \@messages;
    }
}

sub authenticate : Path('/user/authenticate') {
    my ($self, $c, $auth_id) = @_;

    # we should have an auth-id in the url
    if (not defined $auth_id) {
        $c->stash->{error}{message} = q{Incomplete authentication URL};
        return;
    }

    # fetch the info from the database
    my $regauth = $c->model('ParleyDB')->table('registration_authentication')->search(
        {
            registration_authentication_id => $auth_id,
        }
    );

    # if we don't have any matches then the id was bogus
    if (not $regauth->count()) {
        $c->stash->{error}{message} = q{Bogus authentication ID};
        return;
    }

    # get the first result
    # TODO - we should probably ensure there's exactly one result
    $regauth = $regauth->first;

    # TODO
    # if we get this far, we've got a valid ID, so we can yank out their details,
    # and to be safe we'll finish the process by asking them for their password
    #
    # for now, we assume the link clicking is good enough, and we mark them
    # as authenticated

    # get the person matching the ID
    $c->stash->{signup_user} = $c->model('ParleyDB')->table('person')->search(
        {
            person_id => $regauth->recipient->person_id(),
        }
    )->first();

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

sub _user_signup {
    my ($self, $c) = @_;
    my ($results, @messages);

    if ($DFV) {
        $results = $DFV->check($c->request->parameters(), 'signup');
    }

    if ($results || !$DFV) {
        # things are good - insert the information, and send email to new user
        $c->log->info('DFV OK');
        @messages = $self->_new_user($c, $results);
    }
    else {
        # something went wrong
        $c->log->error('DFV failed');
        push @messages, map {$_} values %{$results->msgs};
    }

    return (uniq(sort @messages));
}

sub _new_user {
    my ($self, $c, $dfv_results) = @_;
    my (@messages, $valid_results, $new_auth, $new_person);

    # less typing
    $valid_results = $dfv_results->valid;

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

    # if we *don't* have any messages, then it's safe to add stuff to the database
    if (not scalar(@messages)) {
        # transaction method taken from:
        #  http://search.cpan.org/~mstrout/DBIx-Class-0.04999_01/lib/DBIx/Class/Manual/Cookbook.pod#Transactions
        eval {
            # start a transaction
            $c->model('ParleyDB')->table('authentication')->storage->txn_begin;

            # add authentication
            $new_auth = $c->model('ParleyDB')->table('authentication')->create(
                {
                    username => $valid_results->{username},
                    password => md5_hex($valid_results->{password}),
                }
            );
            $c->log->dumper( $new_auth->{_column_data}, 'NEW_AUTH');

            # XXX I don't know why we're not getting all fields after the create()
            # XXX for now, just look up the newly created record ... pants isn't it?
            $new_auth = $c->model('ParleyDB')->table('authentication')->search(
                {
                    username => $valid_results->{username},
                    password => md5_hex($valid_results->{password}),
                }
            )->first();
            $c->log->dumper( $new_auth->{_column_data}, 'SEARCHED_NEW_AUTH');
            # make sure we have an authentication_id
            if (not defined $new_auth->authentication_id()) {
                # rollback
                eval { $c->model('ParleyDB')->table('authentication')->storage->txn_rollback };
                push @messages, q{Authentication ID is not available};
                die q{Authentication ID is not availablen $new_auth object};
            }

            # add person
            $new_person = $c->model('ParleyDB')->table('person')->create(
                {
                    first_name      => $valid_results->{first_name},
                    last_name       => $valid_results->{last_name},
                    forum_name      => $valid_results->{forum_name},
                    email           => $valid_results->{email},
                    authentication  => $new_auth->id(),
                }
            );
            $c->log->debug( "$valid_results->{email} added with auth: " . $new_auth->id() );
            $c->log->debug( "$valid_results->{email} added with auth: " . $new_auth->authentication_id() );

            # commit everything
            $c->model('ParleyDB')->table('authentication')->storage->txn_commit;
        };
        # any errors?
        if ($@) {
            # put something in the logs
            $c->log->error($@);
            # put something useful for the user to see
            push @messages, q{Failed to insert new user information};
            # rollback
            eval { $c->model('ParleyDB')->table('authentication')->storage->txn_rollback };
        }

        # if it was all ok, send the authentication email
        else {
            $self->_send_auth_email($c, $new_person);
            # set the template to show
            $c->stash->{newdata}  = $new_person;
            $c->stash->{template} = 'user/auth_emailed';
        }
    }

    return sort(@messages);
}


sub _username_exists {
    my ($self, $c, $username) = @_;
    # look for the specified username
    $c->log->info("Looking for: $username");
    my $user = $c->model('ParleyDB')->table('authentication')->search(
        username => $username,
    );
    # return the number of matches
    return $user->count;
}

sub _email_exists {
    my ($self, $c, $email) = @_;
    # look for the specified email
    $c->log->info("Looking for: $email");
    my $user = $c->model('ParleyDB')->table('person')->search(
        email => $email,
    );
    # return the number of matches
    return $user->count;
}

sub _forumname_exists {
    my ($self, $c, $forum_name) = @_;
    # look for the specified forum_name
    $c->log->info("Looking for: $forum_name");
    my $user = $c->model('ParleyDB')->table('person')->search(
        forum_name => $forum_name,
    );
    # return the number of matches
    return $user->count;
}

sub _create_regauth {
    my ($self, $c, $person) = @_;
    my ($random, $invitation);

    # if it's good enough for Cozens, it's good enough for me
    $random = md5_hex(time.(0+{}).$$.rand);

    # create an invitation
    $invitation = $c->model('ParleyDB')->table('registration_authentication')->create(
        {
            'registration_authentication_id'	=> $random,
            'recipient'				=> $person->person_id,
            'expires'				=> Time::Piece->new(time + $LIFETIME)->datetime,
        }
    );

    return $invitation;
}

sub _send_auth_email {
    my ($self, $c, $person) = @_;
    my (@messages, $uid, $invitation);

    # create a new reg-auth entry
    $invitation = $self->_create_regauth($c, $person);
    $uid = $invitation->registration_authentication_id();

    # send the email invite
    $c->log->info('about to send an email');
    $c->email(
        header => [
            From    => Parley::App::Helper->application_email_address($c),
            To      => $person->email(),
            Subject => qq{Activate your @{[$c->config->{name}]} registration},
        ],
        body => qq[@{[$person->first_name()]},
Thanks for registering with @{[$c->config->{name}]}.
To complete your registration please click on the link below.

  @{[$c->req->{base}]}user/authenticate/${uid}

and follow the on-screen instructions.

Regards,

The @{[$c->config->{name}]} team.],
    );
    $c->log->info('email sent - supposedly');
}

1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

