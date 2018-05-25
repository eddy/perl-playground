#!/usr/bin/perl

use strict;
use warnings;

use Simple;

my $talking = Horse->new(name => "Mr. Ed");
print $talking->name . "\n";    # prints Mr. Ed
$talking->color("grey"); # sets the color
print $talking->color . "\n";
print $talking->{color} . "<<<<<\n";

print $talking->speak . "\n";

# use Data::Dump;
# print ddx($talking);

use Data::Dumper::Simple;
print Dumper $talking;

exit 0;

