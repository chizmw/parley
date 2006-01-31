package Parley::App::Helper;
use strict;
use warnings;


sub is_logged_in {
    my ($self, $c) = @_;

    if ($c->user) {
        return 1;
    }

    return 0;
}

sub is_authenticted {
    my ($self, $c) = @_;

    # can't be authed if we're not logged in
    if (not $self->is_logged_in($c)) {
        return 0;
    }

    # is our authentication bit set?
    if (not $c->user->user->authenticated()) {
        return 0;
    }

    return 1;
}

sub login_if_required {
    my ($self, $c, $message) = @_;

    if( not Parley::App::Helper->is_logged_in($c) ) {
        # make sure we return here after a successful login
        $c->session->{after_login} = $c->request->uri();
        # set an informative message to display on the login screen
        if (defined $message) {
            $c->session->{login_message} = $message;
        }
        # send the user to the login screen
        $c->response->redirect( $c->req->base() . 'user/login' );
        return;
    }
}

# OK, shitty way of doing it, but we can look into proper ACLs, etc later
sub can_make_locked {
    my ($self, $c, $forum) = @_;

    # can't lock anything if we're not logged in
    if (not $self->is_logged_in($c)) {
        return 0;
    }

    # for now only user #0 can lock threads
    $c->log->dumper( $c->session->{authed_user}->id() );
    return (0 == $c->session->{authed_user}->id());
}

sub can_make_sticky {
    my ($self, $c, $thread) = @_;

    # can't lock anything if we're not logged in
    if (not $self->is_logged_in($c)) {
        return 0;
    }

    # for now only user #0 can lock threads
    return (0 == $c->session->{authed_user}->id());
}


sub user_preference_check {
    my ($self, $c) = @_;

    if (not defined $c->session->{authed_user}->preference()) {
        $c->log->error(
                q{User #}
            . $c->session->{authed_user}->id()
            . q{ doesn't have any preferences. Fixing.}
        );

        # create a new preference
        my $new_preference = $c->model('ParleyDB')->table('preference')->create(
            {
                # one value - the rest can default to whatever the table
                # says
                timezone => 'UTC',
            }
        );
        $c->session->{authed_user}->preference( $new_preference->id() );
        $c->session->{authed_user}->update();
    }
}



1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

