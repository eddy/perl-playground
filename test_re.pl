#!/usr/bin/perl

use strict;
use warnings;

local $_ = 'fish';

m/((\w)(\w))/ && do {
    print $1 . "\n";
    print $2 . "\n";
    print $3 . "\n";
};   

$_ = "1234567890";
m/(\d)+/ && do {
    print $1 . "\n";
};

print '-'x70 . "\n";

my $test = "Our server is training.perltraining.com.au";
my ($full, $host, $domain) = $test =~ m/( ([\w-]+) \. ([\w.-]+) )/xms;
    print "$1\n";
    print "$2\n";
    print "$3\n";
    print '-'x70 . "\n";
    print $full . "\n";
    print "$host : $domain\n";
    print "$full : $domain\n";

exit 0;
