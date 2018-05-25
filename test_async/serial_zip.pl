#! /usr/bin/env perl

use v5.14;
use warnings;

my $s1    = time;
my $start = localtime; say "Start: $start";

my @files = qw(
    testdata1 
    testdata2 
    testdata3
    testdata4
    testdata5
    testdata6
    testdata7
    testdata8
    testdata9
    testdata10
);

for my $file (@files) {
    `zip ${file}.zip $file`;
}

say "Total elapsed time: ", time - $s1, " ms";
