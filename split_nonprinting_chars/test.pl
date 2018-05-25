#!/usr/bin/perl

use strict;
use warnings;
use Carp;

# Data separator...
use constant SPLIT => chr(31);

my $if = 'OLB_BILL.200809152200.02021.txt';
open my $fip, "<", $if
    or croak "Cannot open file: $if: $!";

while (my $line = <$fip>) {
    chomp $line;                        # strip new line

    my @foo = split SPLIT, $line, 12;   # tokenize into 12 tokens
    next if $foo[0] eq 'HDR';           # skip header
    next if $foo[0] eq 'TLR';           # skip trailer

    # Print each token...
    foreach my $token (@foo) {
        print $token . " : ";
    }
    print "\n";

    # FIXME: 
    # To find the "non-printing" character separator...
    #
    # my @foo = split(//,$line);
    # foreach my $token (@foo) {
    #     print ord($token) . " ";
    # }
}

close $fip
    or croak "Cannot close file: $!";

exit 0;


