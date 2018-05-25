#!/usr/bin/perl

#
# Iterator for circular list, e.g. we want to keep a log file in 3-day period
# using FileA, FileB, and FileC
#

use strict;
use warnings;

my $next_file = rotate( qw/FileA FileB FileC/ );

print $next_file->(), "\n" for 1 .. 10;
print $next_file->(), "\n";

sub rotate {
    my @list  = @_;
    my $index = -1;

    return sub {
        $index++;
        $index = 0 if $index > $#list;
        return $list[ $index ];
    };
}
