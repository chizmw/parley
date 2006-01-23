
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Parley' );
use_ok('Parley::Controller::My');

ok( request('my')->is_success );

