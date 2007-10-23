use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Parley' }
BEGIN { use_ok 'Parley::Controller::Help' }

# this should show the help contents
ok( request('/help')->is_success, 'Request should succeed' );

