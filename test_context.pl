#!/usr/bin/env perl

use 5.12.2;
use Data::Dumper::Simple;


sub context
{
    my $context = wantarray();

    say defined $context
        ? $context
            ? 'list'
            : 'scalar'
        : 'void';

    return 0;        
}

my @list_slice  = (1, 2, 3)[context()];
my @array_slice = @list_slice[context()];
my $array_index = $array_slice[context()];
context();


print Dumper @list_slice;
print Dumper @array_slice;
print Dumper $array_index;


