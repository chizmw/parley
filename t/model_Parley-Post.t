use Test::More tests => 4;

BEGIN {
    # use modules
    use Data::Dumper;
    use_ok( Catalyst::Test, 'Parley' );
    use_ok('Parley::Model::ParleyDB::Post');

    our $post_table      = Parley->model('ParleyDB')->table('post');
    our $thread_table    = Parley->model('ParleyDB')->table('thread');
    diag(Dumper ($post_table));
    diag(Dumper ($thread_table));

    # BEGIN TRANSACTION
    Parley->model('ParleyDB')->table('post')->storage->txn_begin;
}

END {
    # ROLLBACK TRANSACTION
    Parley->model('ParleyDB')->table('post')->storage->txn_rollback;
}

my $pg_time = q{1974-10-02 09:17:52.855649000+01};

# create a new thread to add post(s) to
my $new_thread = $thread_table->create(
    {
        forum   => 0,
        subject => 'Test Thread',
        creator => 0,
    }
);

# create a new post (with a specific creation time)
my $new_post = $post_table->create(
    {
        created     => $pg_time,

        thread      => $new_thread->id(),
        subject     => 'Post Time Test',
        message     => $pg_time,
        creator     => 0,
    }
);

diag $new_post->created;

# get the number of posts created at *exactly* the same time of our new post
my $post_count;
$post_count = $post_table->count(
    {
        created => $pg_time,
    }
);
is($post_count, 1);

# get the number of posts created on or before the time of our new post
my $post_count;
$post_count = $post_table->count(
    {
        created => { '<=', $pg_time },
    }
);
is($post_count, 1);
