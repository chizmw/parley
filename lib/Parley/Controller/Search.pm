package Parley::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::Search in Search.');
}

sub forum :Local {
    my ($self, $c) = @_;
    my ($search_terms, $resultset);

    # the search terms
    $search_terms = $c->request->param('search_terms');

    # save the search terms for the template to display
    $c->stash->{search_terms}{raw} = $search_terms;

    # search for any posts in the forum with the search_terms (phrase) in the
    # subject or body
    $resultset = $c->model('ParleyDB')->resultset('Post')->search(
        {
            subject     => { 'ilike' => "%$search_terms%" },
        }
    );

    if ($resultset->count() > 0) {
        $c->stash->{search_results} = $resultset;
    }
}

=head1 NAME

Parley::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
