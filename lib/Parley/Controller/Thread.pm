package Parley::Controller::Thread;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::Thread in Thread.');
}

sub view : Local {
    my ($self, $c) = @_;

    # TODO - configure this somewhere, maybe a user preference
    my $rows_per_page = $c->config->{posts_per_page};

    # page to show - either a param, or show the first
    my $page = $c->request->param('page') || 1;

    # if we have a current_post, view the page with the post on it
    if ($c->_current_post) {
        $c->detach('/post/view');
    }

    # get all the posts in the thread
    $c->stash->{post_list} = $c->model('ParleyDB')->resultset('Post')->search(
        {
            thread => $c->_current_thread->id(),
        },
        {
            order_by    => 'created ASC',
            rows        => $rows_per_page,
            page        => $page,
        }
    );

}

1;

__END__

=pod

=head1 NAME

Parley::Controller::Thread - Catalyst Controller

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
