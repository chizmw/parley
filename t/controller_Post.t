
use Test::More tests => 3;
use_ok( Catalyst::Test, 'Parley' );
use_ok('Parley::Controller::Post');

ok( request('post')->is_success );

