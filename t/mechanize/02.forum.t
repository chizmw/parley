#!/usr/bin/env perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Test::More tests => 8;

use_ok( 'Test::WWW::Mechanize::Catalyst', 'Parley' );

my ($mech, @forum_links, $status);

$mech = Test::WWW::Mechanize::Catalyst->new;
isa_ok($mech, 'Test::WWW::Mechanize::Catalyst');

$mech->get_ok("http://localhost/forum/list", 'Got forum list page URL');
$mech->content_contains('Forum List', 'Returned page is the forum list');

TODO: {
    local $TODO = q{::Mechanize::Test seems to give incorrect <base>};
    $status = $mech->base_is('http://localhost/');
}

if (not $status) {
    diag "<base> is wrong for tests, overriding";
    $mech->{base} = 'http://localhost/';
}

@forum_links = $mech->find_all_links( url_regex => qr{\Aforum/view\?forum=} );
$mech->links_ok(
    \@forum_links,
    'Check all links for forum/view'
);

# let's follow the link into the first forum...
$mech->get_ok($forum_links[0]->url(), 'Got forum view page OK');
$mech->content_contains('List Of Active Threads', 'Returned page is the forum view');
