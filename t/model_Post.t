use strict;
use warnings;
use Test::More tests => 4;

BEGIN { use_ok 'Parley::Schema' }

my ($schema, $resultset, $rs);

# get a schema to query
$schema = Parley::Schema->connect(
    'dbi:Pg:dbname=parley'
);
isa_ok($schema, 'Parley::Schema');

# grab the Post resultset
$resultset = $schema->resultset('Post');
isa_ok($resultset, 'Parley::ResultSet::Post');

# test the "who posted from XXX ip" resultset method
$rs = $resultset->people_posting_from_ip('127.0.0.1');
isa_ok($rs, 'Parley::ResultSet::Post');

my %creator_id;
while (my $record = $rs->next) {
    diag $record->creator->forum_name;
}

diag $rs->count;
