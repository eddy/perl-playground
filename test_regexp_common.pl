#!/usr/bin/perl

use strict;
use warnings;

######################################################################
# Modules...
#
use Readonly;
use Regexp::Common;


######################################################################
# Constants...
#
Readonly my $NUMBER => $RE{num}{int};


######################################################################
# Main...
#
my $foo = '12a';

if ( $foo =~ m/^$NUMBER$/ ) {
    print $foo . " is a number\n";
}

if ( $NUMBER->matches($foo) ) {
    print "$foo : -----------\n";
}

print "end\n";

exit 0;


