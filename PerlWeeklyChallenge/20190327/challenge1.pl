#! /usr/bin/env perl

use v5.14;
use warnings;

# Write a script to replace 'e' with 'E' in 'Perl Weekly Challenge' and print the number of times character 'e' found in
# the string.

my $str = 'Perl Weekly Challenge';
my $count = $str =~ s/e/E/g;

say "$str : 'e' appears $count times";

