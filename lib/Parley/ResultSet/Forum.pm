package Parley::ResultSet::Forum;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Parley::Version;  our $VERSION = $Parley::VERSION;

use base 'DBIx::Class::ResultSet';

sub available_list {
    my ($resultsource) = @_;
    my ($rs);

    $rs = $resultsource->search(
        {
            active  => 1,
        },
        {
            order_by    => 'name ASC',
        }
    );

    return $rs;
}

sub record_from_id {
    my ($resultsource, $forum_id) = @_;
    my ($rs);

    $rs = $resultsource->find(
        {
            'me.id'  => $forum_id,
        },
        {
            prefetch => [
                'last_post',
            ],
        }
    );

    return $rs;
}

1;
