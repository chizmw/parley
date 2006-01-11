
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Parley' );
use_ok('Parley::Controller::Thread');

ok( request('thread')->is_success );

