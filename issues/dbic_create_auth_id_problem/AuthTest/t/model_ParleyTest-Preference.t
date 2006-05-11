use Test::More tests => 5;
use_ok( Catalyst::Test, 'AuthTest' );
use_ok('AuthTest::Model::ParleyTest::Preference');
use Data::Dumper;

# create a new Authentication record (do it all inside a transaction, so we can rollback)

# BEGIN TRANSACTION
AuthTest->model('ParleyTest')->table('preference')->storage->txn_begin;

# create new record
my $now = scalar(localtime);
my $new_auth = AuthTest->model('ParleyTest')->table('preference')->create(
    {
        timezone => 'MyTZ',
    }
);

# correct class returned
isa_ok($new_auth, 'AuthTest::Model::ParleyTest::Preference');

diag Dumper($new_auth->{_column_data});

# new object has values we created it with
is($new_auth->timezone(), 'MyTZ', 'timezone set');

# what about the compass_direction?
#ok(defined($new_auth->compass_direction()), 'compass_direction defined');

# now the kicker ... doe we have an id?
ok(defined($new_auth->preference_id()), 'preference_id set');

# ROLLBACK TRANSACTION
AuthTest->model('ParleyTest')->table('preference')->storage->txn_rollback;
