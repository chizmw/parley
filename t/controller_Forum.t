
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Parley' );
use_ok('Parley::Controller::Forum');

ok( request('forum')->is_success );

