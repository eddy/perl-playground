#!/usr/bin/perl

use strict;
use warnings;

use File::SortedSeek qw(numeric);
use Fatal qw(open close);


open my $fip, "<", 'file1.txt';

while (my $line = <$fip> ) {
    chomp $line;
    next if $line =~ m/^\s*$/;
    print $line . "\n" if matchme('file2-sorted.txt', $line);
    # print $line . "\n" if matchme('file2.txt', $line);
}


exit 0;


sub matchme {
    my ($file, $id) = @_;

    open my $FOP, '<', $file;
    my $tell = numeric( *$FOP, $id, \&munge );
    my $line = <$FOP>;
#     chomp $line;
    close $FOP;

    return 1 if File::SortedSeek::was_exact();
    return;
}


sub munge {
    local $_ = shift;
    s{\A \s* ["]? }{}gxms;   # remove any leading space and quote
    s{ ["]? \s* \z}{}gxms;   # remove any trailing space and quote
    return if m/^\s*$/;      # skip blank line
    return unless m/^\d+$/;  # skip everything but digits
    s{^ \s* [0]+ }{}gxms;    # remove leading zero

    return $_;  
}
