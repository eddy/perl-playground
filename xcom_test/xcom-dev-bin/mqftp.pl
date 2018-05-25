#!/usr/bin/perl

#
# Fake mqftp.pl to emulate sending files
# takes a while to emulate sending BIG files
# Sometimes failes, because we want to cater for that
#

use strict;
use warnings;

use Carp;

# Sleep for a while to emulate big files
sleep int(rand(300));

# Succeed or fail (but do nothing either way... :)
# (succeed more often then fail)
if ( rand() <= 0.80 ) {
  exit 0;
}
else {
  croak "Random failure";
}
