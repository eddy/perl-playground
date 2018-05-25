#!/usr/bin/perl

use strict;
use warnings;

use 5.010_000;
#
# Any of the following will also work
#
# use feature 'say';
# use 5.10.0;

my @list = qw( 1 2 2 3 3 3 4 5 6 6 6 7 8 8 9);

my %unique;

@unique{@list}  = ();

say sort keys %unique;

exit 0;
