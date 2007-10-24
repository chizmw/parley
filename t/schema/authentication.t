#!/usr/bin/perl
# vim: ts=8 sts=4 et sw=4 sr sta
use strict;
use warnings;

# evil globals
our ($schema, $methods, $namespace, $moniker);

BEGIN {
    use Test::More;

    $namespace = q{Parley::Schema};
    $moniker   = q{Authentication};

    $methods = {
        columns => [
            qw[
            ]
        ],

        relations => [
            qw[
            ]
        ],

        custom => [
            qw[
            ]
        ],

        resultsets => [
            qw[
            ]
        ],
    };

    # the number of tests depends (partly) on the number of functions we have in $methods
    plan tests =>
          7                             # fixed number of tests
        + @{ $methods->{columns} }
        + @{ $methods->{relations} }
        + @{ $methods->{custom} }
    ;

    use_ok( $namespace );

    # get a schema to query
    $schema = Parley::Schema->connect(
        'dbi:Pg:dbname=parley'
    );

    isa_ok($schema, $namespace);
}

# get a product record
my $product = $schema->resultset( $moniker )->search({})->first();
isa_ok($product, $namespace . '::' . $moniker);

# the standard test
my @std_method_types = qw(columns relations custom);

foreach my $method_type (@std_method_types) {
    SKIP: {
        skip qq{no $method_type methods}, 1
            unless @{ $methods->{$method_type} };

        can_ok(
            $product,
            @{ $methods->{$method_type} },
        );
        # try calling each method
        foreach my $method ( @{ $methods->{$method_type} } ) {
            eval { $product->$method };
            is($@, q{}, qq{calling $method didn't barf});
        }
    }
}

# resultset class methods - we need something slightly different here
SKIP: {
    skip qq{no resultsets methods}, 1
        unless @{ $methods->{resultsets} };

    my $rs = $schema->resultset( $moniker )->search({});
    can_ok(
        $rs,
        @{ $methods->{resultsets} },
    );
}
