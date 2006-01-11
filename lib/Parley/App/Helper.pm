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

1;
__END__
vim: ts=8 sts=4 et sw=4 sr sta

