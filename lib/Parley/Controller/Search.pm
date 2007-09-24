package Parley::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Text::Search::SQL;
use URI;
use URI::QueryParam;

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Parley::Controller::Search in Search.');
}

sub end :Private {
    my ($self, $c) = @_;

    # we're likely to want pages results for numerous seaches
    $self->_results_view_pager($c);

    # finish processing the page and display
    $c->forward('/end');
}

sub forum :Local {
    my ($self, $c) = @_;
    my ($search_terms, $resultset, $tss, $search_where, $where, @join);

    # page to show - either a param, or show the first
    $c->stash->{current_page}= $c->request->param('page') || 1;

    # the search terms
    $search_terms = $c->request->param('search_terms');

    # if we don't have anything to search for ..
    if (not defined $search_terms or $search_terms =~ m{\A\s*\z}xms) {
        return;
    }

    # start with no join(s)
    @join = ();

    # save the search terms for the template to display
    $c->stash->{search_terms}{raw} = $search_terms;

    # get a suitable where-clause to use based on the search terms
    $tss = Text::Search::SQL->new(
        {
            search_term     => $search_terms,
            search_type     => q{ilike},
            search_fields   => [ qw(me.subject me.message) ],
        }
    );
    $tss->parse();
    $search_where = $tss->get_sql_where();

    # build the where clause to pass to our search
    $where = {
        # we want to OR the items in $sql_where
        -or => $search_where,
    };

    # if we have a search_forum, limit to that
    if (defined $c->request->param('search_forum')) {
        my ($forum);
        eval {
            $forum = $c->model('ParleyDB')->resultset('Forum')->find(
                {
                    forum_id    => $c->request->param('search_forum'),
                }
            );
        };

        if (defined $forum) {
            $where->{'thread.forum'} = $forum->id(),
            push @join, 'thread';
            # put in the stash
            $c->stash->{search_forum} = $forum;
        }
    }

    # search for any posts in the forum with the search_terms (phrase) in the
    # subject or body
    $resultset = $c->model('ParleyDB')->resultset('Post')->search(
        $where,
        {
            join        => \@join,
            order_by    => q{created DESC},
            # results paging
            rows        => $c->config->{search_results_per_page},
            page        => $c->stash->{current_page},
        }
    );

    if ($resultset->count() > 0) {
        $c->stash->{search_results} = $resultset;
    }
}

sub _results_view_pager {
    my ($self, $c) = @_;

    if (not $c->stash->{search_results}) {
        $c->log->debug('no results - no pager');
        return;
    }

    $c->stash->{page} = $c->stash->{search_results}->pager();

    # TODO - find a better way to do this if possible
    # set up Data::SpreadPagination
    my $pagination = Data::SpreadPagination->new(
        {
            totalEntries        => $c->stash->{page}->total_entries(),
            entriesPerPage      => $c->config->{search_results_per_page},
            currentPage         => $c->stash->{current_page},
            maxPages            => 4,
        }
    );
    $c->stash->{page_range_spread} = $pagination->pages_in_spread();

    # extra params to use in pager links (to preserve search data)
    my $u = URI->new("", "http");
    $u->query_param(search_terms => $c->stash->{search_terms}{raw});
    $u->query_param(search_forum => $c->request->param('search_forum'));
    $c->stash->{url_extra_args} = '&' . $u->query();
}

=head1 NAME

Parley::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index 

=head1 AUTHOR

Chisel Wright C<< <chiselwright@users.berlios.de> >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
