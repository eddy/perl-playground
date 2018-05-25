#! /usr/bin/env perl

package MYMAIN;
use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments

__PACKAGE__->main() unless caller();

sub main {
    say "Inside main program";
    # die "die from main program";

    foo();
}


sub foo {
    exit 1;
}
