package Parley::Controller::Post;

use strict;
use warnings;
use base 'Catalyst::Controller';


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Controller Actions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub view : Local {
    my ($self, $c) = @_;

    # if we don't have a post param, then return with an error
    unless (defined $c->_current_post) {
        $c->stash->{error}{message} = q{Incomplete URL};
        return;
    }

    # work out what page in which thread the post lives
    my $thread = $c->_current_post->thread->id();
    my $page_number =  $c->model('ParleyDB')->resultset('Post')->page_containing_post(
        $c->stash->{current_post},
        $c->config->{posts_per_page},
    );

    # build the URL to redirect to
    my $redirect_url = $c->uri_for(
        '/thread',
          "view?thread=$thread"
        . "&page=$page_number"
        . "#" . $c->_current_post->id()
    );

    # redirect to the relevant place in the appropriate thread
    $c->log->debug( "post/view: redirecting to $redirect_url" );
    $c->response->redirect( $redirect_url );
    return;
}


1;
__END__

=pod

=head1 NAME

Parley::Controller::Post - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 ACTIONS

=head2 view 

View a specific post, specified by the post in $c->_current_post

=head1 AUTHOR

Chisel Wright C<< <chisel@herlpacker.co.uk> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

vim: ts=8 sts=4 et sw=4 sr sta
