#!/usr/bin/perl

use strict;
use warnings;

my %lookup;

@lookup{ qw/sales support security management/ }
    = map { { start => $_ * 10_000 } } 1..4;


use Data::Dumper;
print Dumper \%lookup;


