
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Parley' );
use_ok('Parley::Controller::User');

ok( request('user')->is_success );

