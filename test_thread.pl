#! /usr/bin/env perl

use strict;
use warnings;
use threads;
use threads::shared;

my @ary : shared;

my $thr = threads->create('file_reader');

while (1) {
    my ($value);
    {
        lock(@ary);
        if ( $#ary > -1 ) {
            $value = shift(@ary);
            print "Found a line to process:  $value\n";
        }
        else {
            print "no more lines to process...\n";
        }
    }

    sleep(1);

    #process $value
}

sub file_reader {

    #File input
    open( INPUT, "<test.txt" );
    while (<INPUT>) {
        my ($line) = $_;
        chomp($line);

        print "reading $line\n";

        if ( $line =~ /X/ ) {
            print "pushing $line\n";
            lock(@ary);
            push @ary, $line;
        }
        sleep(4);
    }
    close(INPUT);
}

__DATA__
line 1
line 2X
line 3
line 4X
line 5
line 6
line 7X
line 8
line 9
line 10
line 11
line 12X
