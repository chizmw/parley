#!/usr/bin/env perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;
use Data::Dump qw(pp);

use Test::More tests => 36;

BEGIN {
    use_ok('Text::Search::SQL');
}

# GLOBAL VARIABLES
my ($sp);

# make sure we offer the expected methods in the interface
can_ok('Text::Search::SQL',
    qw[
        new
        set_search_term
        get_search_term
        set_search_fields
        get_search_fields
        set_chunks
        get_chunks
        set_sql_where
        get_sql_where
        parse

        _parse_chunks
    ]
);

# get a new instance of the object, name sure it's what we're expecting
$sp = Text::Search::SQL->new();
isa_ok($sp, q{Text::Search::SQL});

# calling with no argument means we should have default attributes
is( $sp->{search_term}, undef, q{undefined search_term} );

# create a new object with a search_term in the call to new
$sp = Text::Search::SQL->new( { search_term => 'one man' } );
isa_ok($sp, q{Text::Search::SQL});

# calling with no argument means we should have default attributes
is( $sp->{search_term}, q{one man}, q{search_term is 'one man'} );

# using set_search_term() gives expected results
$sp->set_search_term('went to mow');
is( $sp->{search_term}, q{went to mow}, q{search_term is 'went to mow'} );

# data to loop through for _parse_chunks() and parse() tests
my @data = (
    {
        input   => q{isn't},
        output  => [ q{isn't} ],

        search_fields   => [ qw/subject/ ],
        sql_where       => {
            subject => [ q{isn't} ],
        },
    },
    {
        input   => q{went to mow},
        output  => ['went', 'to', 'mow'],

        search_fields   => [ qw/subject/ ],
        sql_where       => {
            subject => [ qw(went to mow) ],
        },
    },
    {
        input   => q{"went to" mow},
        output  => ['went to', 'mow'],

        search_fields   => [ qw/subject/ ],
        sql_where       => {
            subject => [ q{went to}, q{mow} ],
        },
    },
    {
        input   => q{'went to' mow},
        output  => [ q{'went}, q{to'}, q{mow} ],
    },
    {
        input   => q{'went to' "mow a meadow"},
        output  => [ q{'went}, q{mow a meadow}, q{to'}],
    },
    {
        input   => q{went to' mow a meadow"},
        output  => [ q{a}, q{meadow"}, q{mow}, q{to'}, q{went} ],
    },
    {
        input   => q{went to' mow a "meadow"'},
        output  => [ q{'}, q{a}, q{meadow}, q{mow}, q{to'}, q{went} ],
    },
    {
        input   => q{went to" mow a 'meadow'"},
        output  => [ q{ mow a 'meadow'}, q{to}, q{went} ],
    },
    {
        input   => q{isn't it nice to be here?},
        output  => [ q{isn't}, q{it}, q{nice}, q{to}, q{be}, q{here?} ],
    },
    {
        input   => q{"isn't it nice to be here?"},
        output  => [ q{isn't it nice to be here?} ],
    },

    # some tests geared to the returned where data
    {
        input   => q{alpha beta},
        output  => [ qw(alpha beta) ],

        search_fields   => [ qw(subject) ],
        sql_where       => {
            subject => [ qw(alpha beta) ],
        },
    },
    {
        input   => q{alpha beta},
        output  => [ qw(alpha beta) ],

        search_fields   => [ qw(subject message) ],
        sql_where       => {
            subject => [ qw(alpha beta) ],
            message => [ qw(alpha beta) ],
        },
    },
);

# tests for _parse_chunks()
foreach my $data (@data) {
    # _parse_chunks()
    my $chunks = $sp->_parse_chunks( $data->{input} );
    is_deeply(
        [ sort @{ $data->{output} } ],
        [ sort @{ $chunks } ],
        qq{_parse_chunks: $data->{input}}
    );

    # check where clause meets our expectation
    if (defined $data->{search_fields}) {
        $sp->set_search_fields( $data->{search_fields} );
    }

    # parse()
    $sp->set_search_term( $data->{input} );
    $sp->parse();
    is_deeply(
        $sp->{chunks},
        $chunks,
        qq{\$sp->{chunks} matches _parse_chunks($data->{input})}
    );

    # where clause
    if (defined $data->{sql_where}) {
        is_deeply(
            $sp->get_sql_where(),
            $data->{sql_where},
            qq{correct where data for $data->{input}},
        );
    }
}

