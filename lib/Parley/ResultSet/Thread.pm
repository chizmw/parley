package Parley::ResultSet::Thread;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub latest_terms {
    my $resultset = shift;

    my $latest_rs = $resultset->search(
        {
        },
        {
            rows        => 1,
            order_by    => 'created DESC',
        }
    );

    if ($latest_rs->count()) {
        return $latest_rs->first();
    }

    return;
}

sub recent {
    my ($resultset, $c) = @_;
    my ($thread_list, $where, @join);

    # page to show - either a param, or show the first
    $c->stash->{current_page}= $c->request->param('page') || 1;

    # always want to join with last_post table
    @join = qw(last_post);

    # only search active forums
    $where->{'me.active'} = 1;

    # if we're only interested in a given forum
    if (defined $c->_current_forum()) {
        $where->{forum} = $c->_current_forum->id();
    }

    $resultset->search(
        $where,
        {
            join        => \@join,
            order_by    => 'last_post.created DESC',

            rows        => $c->config->{threads_per_page},
            page        => $c->stash->{current_page},

            prefetch => [
                {'creator' => 'authentication'},
                'last_post',
                'forum',
            ],
        }
    );
}

1;
