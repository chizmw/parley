use strict;
use warnings;
use Test::More tests => 4;

use_ok 'Catalyst::Test', 'Parley';
use_ok 'Parley::Controller::Help';

# this should show the help contents
ok( request('/help')->is_success, 'Help contents found' );

# this should show the help contents
ok( request('/help/faq')->is_success, 'FAQ page found' );
