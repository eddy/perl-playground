#!/usr/bin/perl 

use warnings;
use strict;


sub from_number {
    my $number = shift;
    return sub { $number++ } ;
}


my $from_three = from_number(3);
my $from_ten   = from_number(10);

print $from_three->() . "\n";
print $from_three->() . "\n";
print $from_three->() . "\n";


print $from_ten->() . "\n";
print $from_ten->() . "\n";
print $from_three->() . "\n";

exit 0;



