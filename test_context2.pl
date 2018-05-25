#!/usr/bin/env perl

use 5.12.0;
use warnings;

use Data::Dumper::Simple;

sub operation {
    defined( wantarray ) ? wantarray ? say 'list'
                                     : say 'scalar'
                         : say 'void';

    return wantarray ? (11, 12, 13) : 10;                         
}

my $scalar = operation();
say $scalar;

my @array = operation();
say Dumper @array;

operation();

say "---------------";
my ($single) = operation();
say $single;




