package Parley::Controller::User::LostPassword;

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

Readonly my $LIFETIME => Time::Seconds::ONE_HOUR;
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
            'password_reset' => {
                require_some => {
                    user_details => [
                        1,
                        qw/ username email /
                    ],
                },

                field_filters => {
                    username  => 'trim',
                    email     => 'trim',
                },

                constraints => {
                    email => {
                        name => 'email',
                        constraint_method => email(),
                    },
                },

                msgs => {
                    constraints => {
                        email => q{You must enter a valid email address},
                    },
                    missing => q{One or more required fields are missing},
                    format => '%s',
                },
            },

            'set_new_password' => {
                required => [
                    qw/
                        reset_username
                        new_password
                        confirm_password
                    /
                ],

                field_filters => {
                    reset_username      => 'trim',
                    new_password        => 'trim',
                    confirm_password    => 'trim',
                },

                constraints => {
                    confirm_password => {
                        name       => 'confirm_password',
                        constraint => \&_confirm_equal,
                        params     => [qw(new_password confirm_password)],
                    },
                },

                msgs => {
                    constraints => {
                        confirm_password => q{The passwords do not match},
                    },
                    missing => q{One or more required fields are missing},
                    format => '%s',
                },
            }
        },
    );
}

# nice and easy - catch the url to display the lost password page
# if we have a form submit, deal with it
sub lost_password : Path('/user/password/forgotten') {
    my ($self, $c) = @_;
    my ($results, @messages);

    if (defined $c->request->param('pwd_reset_submit')) {
        @messages = $self->_user_reset($c);

        # if we have any validation errors ...
        if (scalar @messages) {
            $c->stash->{messages} = \@messages;
        }

        # no messages, means that all should be well, so head off to the
        # "details in the post" page
        else {
            $c->stash->{template} = 'user/lostpassword/lost_password_details_sent';
        }
    }
}

# this action uses the uid in the URL to work out who's password we are
# resetting, after a little validation, we can use the new choice of password
# for the user
sub reset : Path('/user/password/reset') {
    my ($self, $c, $reset_uid) = @_;
    my ($results, @messages);

    # we should have the reset UID in the URL
    if (not defined $reset_uid) {
        $c->stash->{error}{message} = q{Incomplete password reset URL};
        return;
    }

    # fetch the info from the database
    my $pwd_reset = $c->model('ParleyDB')->table('password_reset')->search(
        {
            password_reset_id => $reset_uid,
        }
    );

    # if we don't have any matches then the id was bogus
    if (not $pwd_reset->count()) {
        $c->stash->{error}{message} = q{Bogus password reset ID};
        return;
    }

    # get the first result
    # TODO - we should probably ensure there's exactly one result
    $pwd_reset = $pwd_reset->first;

    #$c->log->dumper( $pwd_reset->{_column_data} ); # XXX
    #$c->log->dumper( $pwd_reset->recipient()->{_column_data} ); # XXX

    # put the reset_uid into the stash
    $c->stash->{reset_uid} = $reset_uid;

    # make user available to template
    $c->stash->{reset_user} = $pwd_reset->recipient();


    # do we have a form submit?
    if ($c->request->method() eq 'POST') {
        $c->log->debug('Reset form submitted');

        if ($DFV) {
            $results = $DFV->check($c->request->parameters(), 'set_new_password');
        }

        if ($results || !$DFV) {
            # make sure the reset_uid points to a user that matches the username in
            # the field
            my $reset_username = $pwd_reset->recipient()->authentication()->username();
            if ($reset_username eq $results->{valid}{reset_username}) {
                eval {
                    # start a transaction
                    $c->model('ParleyDB')->table('password_reset')->storage->txn_begin;

                    # username is a match, the form is OK ... looks like we're
                    # ready to update the password
                    $pwd_reset->recipient()->authentication()->password(
                        md5_hex($results->{valid}{new_password})
                    );
                    $pwd_reset->recipient()->authentication()->authenticated(1);
                    $pwd_reset->recipient()->authentication()->update();

                    # remove all password_reset records for the current user
                    $c->model('ParleyDB')->table('password_reset')->search(
                        {
                            recipient => $pwd_reset->recipient()->id(),
                        }
                    )->delete;

                    # commit everything
                    $c->model('ParleyDB')->table('password_reset')->storage->txn_commit;
                };
                # any errors?
                if ($@) {
                    # put something in the logs
                    $c->log->error($@);
                    # put something useful for the user to see
                    push @messages, q{Failed to update database information};
                    # rollback
                    eval { $c->model('ParleyDB')->table('password_reset')->storage->txn_rollback };
                }
                else {
                    push @messages, 'Password reset';
                    $c->stash->{template} = 'user/lostpassword/reset_success';
                }
            }
            else {
                # silly user - wrong username
                push @messages, 'Incorrect username supplied';
            }
        }
        else {
            # something went wrong
            $c->log->error('DFV failed');
            push @messages, uniq(sort(map {$_} values %{$results->msgs}));
        }
    }
    else {
        # show a page where the user can set a new password
        # (this defaults to user/lostpassword/reset which is fine)
    }

    # if we have any validation errors ...
    if (scalar @messages) {
        $c->stash->{messages} = \@messages;
    }

    # no messages, means that all should be well
    else {
        #$c->stash->{template} = 'user/lostpassword/lost_password_details_sent';
    }
}

sub _user_reset {
    my ($self, $c) = @_;
    my ($results, @messages);

    if ($DFV) {
        $results = $DFV->check($c->request->parameters(), 'password_reset');
    }

    if ($results || !$DFV) {
        # things are good - we met the basic form requirements
        $c->log->info('DFV OK');
        my ($criteria, $matches, $person);

        # make sure we can match user/email supplied
        if (defined $results->{valid}{username}) {
            $criteria->{'authentication.username'} = $results->{valid}{username};
        }
        elsif (defined $results->{valid}{email}) {
            $criteria->{'email'} = $results->{valid}{email};
        }
        $matches = $c->model('ParleyDB')->table('person')->search(
            $criteria,
            {
                join => 'authentication',
            }
        );
        # get the first (and should be only) match
        $person = $matches->first();

        if (defined $person) {
            # do the actual password reset
            @messages = $self->_user_password_reset($c, $person);
        }
        else {
            push @messages, q{There are no users matching that information};
            $c->log->debug(' NO MATCHES ');
        }
    }
    else {
        # something went wrong
        $c->log->error('DFV failed');
        push @messages, map {$_} values %{$results->msgs};
    }

    return (uniq(sort @messages));
}

sub _create_pwd_reset {
    my ($self, $c, $person) = @_;
    my ($random, $pwd_reset);

    # if it's good enough for Cozens, it's good enough for me
    $random = md5_hex(time.(0+{}).$$.rand);

    # create an invitation
    $pwd_reset = $c->model('ParleyDB')->table('password_reset')->create(
        {
            'password_reset_id' => $random,
            'recipient'		=> $person->person_id,
            'expires'		=> Time::Piece->new(time + $LIFETIME)->datetime,
        }
    );

    return $pwd_reset;
}

sub _user_password_reset {
    my ($self, $c, $person) = @_;
    my (@messages, $pwd_reset, $uid);

    $c->log->debug( $person->email() );

    # blank the password and make them no longer authenticated
    eval {
        # start a transaction
        $c->model('ParleyDB')->table('authentication')->storage->txn_begin;

        # create a new entry in the password_reset table
        $pwd_reset = $self->_create_pwd_reset($c, $person);
        $uid = $pwd_reset->id();

        # make the changes we want
        $person->authentication->password('X');
        $person->authentication->authenticated(0);
        $person->authentication->update();

        # commit everything
        $c->model('ParleyDB')->table('authentication')->storage->txn_commit;
    };
    # any errors?
    if ($@) {
        # put something in the logs
        $c->log->error($@);
        # put something useful for the user to see
        push @messages, q{Failed to update database information};
        # rollback
        eval { $c->model('ParleyDB')->table('authentication')->storage->txn_rollback };
    }
    else {
        # send the email with the reset link
        $c->log->debug('about to send an email');
        $c->email(
            header => [
                From    => Parley::App::Helper->application_email_address($c),
                To      => $person->email(),
                Subject => qq{Reset your @{[$c->config->{name}]} password},
            ],
            body => qq[@{[$person->first_name()]},

To reset your account password please click on the link below.

@{[$c->req->{base}]}user/password/reset/${uid}

Regards,

The @{[$c->config->{name}]} team.],
        );
        $c->log->debug('email sent - supposedly');
    }

    return @messages;
}


1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

