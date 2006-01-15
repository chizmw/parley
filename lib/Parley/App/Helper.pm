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

1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

