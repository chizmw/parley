use strict;
use warnings;
use Test::More tests => 4;

use_ok 'Catalyst::Test', 'Parley';
use_ok 'Parley::Controller::Search';

ok( request('/search')->is_success, '/search exists' );
ok( request('/search/forum')->is_success, '/search/forum exists' );
