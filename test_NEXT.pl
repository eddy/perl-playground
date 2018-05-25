#!/usr/bin/perl

use strict;
use warnings;
use NEXT;

# use 5.010_000;
use feature 'say';

{
    package A;

    sub method {
        say 'A::method';
        $_[0]->NEXT::method();
    }
}

{
    package B;
#     use base qw( A );
    our @ISA = qw( A );

    sub method  {
        say 'B::method';
        $_[0]->NEXT::DISTINCT::ACTUAL::method();
    }
}

{
    package C;
    sub method  {
        say 'C::method';
        $_[0]->NEXT::method();
    }
}

{
    package D;
#     use base qw( B C);
    our @ISA = qw(B C);        

    sub method  {
        say 'D::method';
        $_[0]->NEXT::method();
    }
}

package main;

my $d = bless {}, 'D';
$d->method();

