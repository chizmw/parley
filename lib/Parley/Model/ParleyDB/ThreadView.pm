package Parley::Model::ParleyDB::ThreadView;
use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('thread_view');
__PACKAGE__->add_columns(qw/
    thread_view_id
    person
    thread
    timestamp
/);
__PACKAGE__->set_primary_key('thread_view_id');
__PACKAGE__->add_unique_constraint(
    constraint_name => [ qw/person thread/ ],
);

foreach my $datecol (qw/timestamp/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { my $ts = shift; warn $ts; DateTime::Format::Pg->parse_datetime($ts); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}


1;
