#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

my $counter = 0;

while ($counter < 500) {
    srand( time+$$+$counter );
    my $foo = int( rand(100_000_000_000_000) );
    $foo = sprintf "%015s", $foo;
    say '6' . $foo;
    $counter++;
    sleep 0.5;
}

exit 0;
