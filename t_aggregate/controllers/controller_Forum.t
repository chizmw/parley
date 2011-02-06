use strict;
use warnings;
use Test::More tests => 4;

use_ok 'Catalyst::Test', 'Parley';
use_ok 'Parley::Controller::Forum';

ok( request('/forum/list')->is_success, 'forum/list exists' );
ok( request('/forum/view')->is_success, 'forum/view exists' );
