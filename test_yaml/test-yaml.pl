#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use YAML::Tiny;

my %hash = (
    one => '1',
    two => { 'mytwo'   => '2-1',
             'yourtwo' => '2-2',
           },
    three => '3',           
);    

# Store to a human readable text file...
YAML::Tiny::DumpFile('test.yaml', \%hash);

# Get the value back from the file...
my $yaml = YAML::Tiny->new();
$yaml = YAML::Tiny->read('test.yaml');

#
# Now we can use the value back...
# Note that YAML::Tiny::read return a list, so we need
# to use the value in [0].
#
print $yaml->[0]->{one}            . "---\n";
print $yaml->[0]->{two}->{'mytwo'} . "===\n";

print Dumper $yaml;

exit 0;


