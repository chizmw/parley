package TimeDB::Thingy;
use strict;
use warnings;
use base qw/DBIx::Class/;
use DateTime::Format::Pg;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('thingy');
__PACKAGE__->add_columns(qw/
    thingy_id
    created
    stuff
/);
__PACKAGE__->set_primary_key('thingy_id');

foreach my $datecol (qw/created/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}

1;
