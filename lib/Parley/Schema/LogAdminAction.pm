package Parley::Schema::LogAdminAction;
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

use Parley::Version;  our $VERSION = $Parley::VERSION;

use base 'DBIx::Class';
use DateTime::Format::Pg;

use Parley::App::DateTime qw( :interval );

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("log_admin_action");
__PACKAGE__->add_columns(
  id            => { },
  person_id     => { },
  admin_id      => { },
  created       => { },
  message       => { },
);

__PACKAGE__->set_primary_key("id");
#__PACKAGE__->resultset_class('Parley::ResultSet::Role');

__PACKAGE__->belongs_to(
    "person" => "Person",
    { 'foreign.id' => "self.person_id" }
);
__PACKAGE__->belongs_to(
    "admin" => "Person",
    { 'foreign.id' => "self.person_id" }
);

foreach my $datecol (qw/created/) {
    __PACKAGE__->inflate_column($datecol, {
        inflate => sub { DateTime::Format::Pg->parse_datetime(shift); },
        deflate => sub { DateTime::Format::Pg->format_datetime(shift); },
    });
}

1;
