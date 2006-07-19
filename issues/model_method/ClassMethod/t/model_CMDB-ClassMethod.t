use Test::More tests => 3;
use_ok( Catalyst::Test, 'ClassMethod' );
use_ok('ClassMethod::Model::CMDB::ClassMethod');

can_ok('ClassMethod::Model::CMDB::ClassMethod', qw/ some_method /);
