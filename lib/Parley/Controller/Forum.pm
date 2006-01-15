package Parley::Controller::Forum;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Parley::Controller::Parley - Catalyst Controller

=head1 SYNOPSIS

See L<Parley>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body('Parley::Controller::Parley is on Catalyst!');
}

sub list : Local {
    my ($self, $c) = @_;
    #$c->response->body('forum list');

    $c->stash->{forum_list} = $c->model('ParleyDB')->table('forum')->search(
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

    $c->stash->{thread_list} = $c->model('ParleyDB')->table('thread')->search(
        {
            forum       => $c->stash->{current_forum}->id(),
            active      => 1,
        },
        {
            join        => 'last_post',
            order_by    => 'sticky DESC, last_post.created DESC',
        }
    );

    # user permissions
    $c->stash->{can_lock}  = Parley::App::Helper->can_make_locked($c);
    $c->stash->{can_stick} = Parley::App::Helper->can_make_sticky($c);
}

=head1 AUTHOR

Chisel Wright C<< <pause@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
