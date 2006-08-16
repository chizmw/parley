package Parley::Controller::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub list : Local {
    my ($self, $c) = @_;

    # get a list of (active) forums
    $c->stash->{forum_list} = $c->model('ParleyDB')->resultset('Forum')->search(
        {
            active => 1,
        },
        {
            'order_by'  => 'forum_id ASC',
        }
    );
}

sub view : Local {
    my ($self, $c) = @_;

    # get a list of (active) threads in a given forum
    $c->stash->{thread_list} = $c->model('ParleyDB')->resultset('Thread')->search(
        {
            forum       => $c->stash->{current_forum}->id(),
            active      => 1,
        },
        {
            join        => 'last_post',
            order_by    => 'sticky DESC, last_post.created DESC',
        }
    );
}


1;

__END__

=pod

=head1 NAME

Parley::Controller::Forum - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
