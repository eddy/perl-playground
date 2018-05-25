#! /usr/bin/env perl

use v5.14;
use warnings;
# use match::simple;
use match::smart;
use Test::More;

my $x = 'aku';
my $y = 'kamu';

ok( !($x |M| $y), "X not match Y" );

$y = 'aku';
ok( $x |M| $y, "X match Y" );

my @x = (1, 2, 3, 4, 5);
my @y = ();
ok( !(\@x |M| \@y), "array-X not match array-Y");

@y = (1, 2, 3, 4, 5);
ok( \@x |M| \@y, "array-X match array-Y");

$x = [
        {   cji_count      => 756,
            cji_desc       => "C'link reply paid envelope EN43",
            cji_station    => 1,
            cji_stock_code => "REPLYONE",
        },
        {   cji_count      => 75,
            cji_desc       => "C'link reply paid envelope EN43",
            cji_station    => 2,
            cji_stock_code => "EN43",
        }
];

$y = [
        {   cji_count      => 756,
            cji_desc       => "C'link reply paid envelope EN43",
            cji_station    => 1,
            cji_stock_code => "REPLYONE",
        },
        {   cji_count      => 75,
            cji_desc       => "C'link reply paid envelope EN43",
            cji_station    => 2,
            cji_stock_code => "EN43",
        }
];

ok( $x |M| $y, "arrayref-X match arrayref-Y");


{
    use FreezeThaw qw(cmpStr);
    ok( cmpStr( $x, $y) == 0, '$x match $y');

    $y = [
            {   cji_count      => 75,
                cji_desc       => "C'link reply paid envelope EN43",
                cji_station    => 2,
                cji_stock_code => "EN43",
            },
            {   cji_count      => 756,
                cji_desc       => "C'link reply paid envelope EN43",
                cji_station    => 1,
                cji_stock_code => "REPLYONE",
            },
    ];

    ok( cmpStr( $x, $y) == 0, '$x match $y');
}

done_testing();
