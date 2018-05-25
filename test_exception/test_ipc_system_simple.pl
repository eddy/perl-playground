#!/usr/bin/perl

use strict;
use warnings;

use IPC::System::Simple qw(capturex $EXITVAL);

my $r   = eval { my $res = capturex("cat abc.txt"); 1 };
my $err = $@;

if (! $r) {
    $err = defined $err ? $err : 'Unknown error';
}

if ($err) {
    print "Error: $err";
    print "Exit status: $EXITVAL\n";
}

exit 0;
