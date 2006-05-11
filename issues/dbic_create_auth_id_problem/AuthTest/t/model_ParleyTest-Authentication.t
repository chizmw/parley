use Test::More tests => 6;
use_ok( Catalyst::Test, 'AuthTest' );
use_ok('AuthTest::Model::ParleyTest::Authentication');
use Data::Dumper;


# create a new Authentication record (do it all inside a transaction, so we can rollback)

# BEGIN TRANSACTION
AuthTest->model('ParleyTest')->table('authentication')->storage->txn_begin;

# create new record
my $now = scalar(localtime);
my $new_auth = AuthTest->model('ParleyTest')->table('authentication')->create(
    {
        username => $now,
        password => 'pwd',
    }
);

# correct class returned
isa_ok($new_auth, 'AuthTest::Model::ParleyTest::Authentication');

diag Dumper($new_auth->{_column_data});

# new object has values we created it with
is($new_auth->username(), $now, 'username set');
is($new_auth->password(), 'pwd', 'password set');

# now the kicker ... doe we have an id?
ok(defined($new_auth->authentication_id()), 'authentication_id set');

# ROLLBACK TRANSACTION
AuthTest->model('ParleyTest')->table('authentication')->storage->txn_rollback;
