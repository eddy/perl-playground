#!/usr/local/perl/bin/perl

use strict;
use warnings;

use feature qw(say);


my %hash;
my $n=0;

say $hash{x};

no autovivification;
while (!exists ($hash{x}) && $n < 5) {
    $n++;
    if (!exists ($hash{x}{y})) {
        print "hash{x}{y} does not exist: $n\n";
    }
    say $hash{x};
}

#
# If we do NOT use autovivification, the above code MUST be 
# re-written as below:
#
# while (!exists ($hash{x}) && $n < 5) {
#     if (defined ($hash{x})) {
#         if (!exists ($hash{x}{y})) {
#             print "$n: hash{x}{y} does not exist.\n";
#         }
#     } else {
#         print "$n: hash{x} is undefined.\n";
#     }
# }    
