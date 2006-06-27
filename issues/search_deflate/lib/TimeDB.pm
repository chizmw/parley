package TimeDB;
use strict;
use warnings;

use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_classes(qw/ Thingy /);


1;

