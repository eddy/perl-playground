#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments


# Implementation here

open FH, ">", "file.txt";

my $smiley = chr( 174 );

print FH $smiley;
print FH "\nTrademark ---------------------------\n";
print FH chr(153);
print FH "\nTrademark too---------------------------\n";
print FH "\x99";
print FH "\n---------------------------\n";
print FH chr( 169 );

close FH;
