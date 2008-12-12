package Parley::Controller::ForumCode;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use parent 'Catalyst::Controller';

use JSON::Any;
use HTML::ForumCode;

sub preview : Local {
    my ($self, $c) = @_;
    my $tt_forum = HTML::ForumCode->new();
    my $msg_source = $c->request->param('msg_source');

    my $j = JSON::Any->new;
    my $json = $j->to_json(
        {
            'formatted' =>
                $tt_forum->forumcode(
                    $msg_source
                )
        }
    );

    $c->response->body( $json );
    return;
}

1;
