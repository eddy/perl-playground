#!/usr/bin/perl

use strict;
use warnings;

use Fatal qw(open close);

open my $fip, '<', 'file1.txt';
open my $fop, '<', 'file2.txt';

my $lookup = q{};
while (my $line = <$fop>) {
    chomp $line;
    $line =~ s{\A \s* ["]? }{}gxms; # remove any leading space and quote
    $line =~ s{ ["]? \s* \z}{}gxms; # remove any trailing space and quote
    next if $line =~ m/^\s*$/;      # skip blank line

    vec( $lookup, $line, 1) = 1;
}

close $fop;

while (my $line = <$fip>) {
    chomp $line;
    next if $line =~ m/^\s*$/; # remove any blank line

    my $xxx = vec( $lookup, $line, 1);
    print $xxx . "-------------\n";

    if ( vec( $lookup, $line, 1) ) {

        print $line . "\n";
    }
}

exit 0;
