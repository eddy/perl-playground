#! /usr/bin/env perl
#
# Read: http://www.manchicken.com/2013/general/gist-of-the-day-perl-closure-extravaganza.htm
# for further details.
#
# A closure is a function which was created dynamically inside of another function. In Perl (among other languages), these
# are sometimes referred to as anonymous subroutines. In Perl, all closures are anonymous subroutines, but not all
# anonymous subroutines are closures. The key differentiating feature is scope: a closure has access to lexically-scoped
# variables within a containing subroutine, whereas an anonymous subroutine is not necessarily even inside of a function.
#

use v5.14;
use warnings;
use Data::Printer;

# Here is an example of  an anonymous subroutine:
# Notice how this creates a CODEREF and then executes it. This is essentially just a normal functionNotice how this
# creates a CODEREF and then executes it. This is essentially just a normal function
my $anonsub = sub { return join ',', @_; };
my @foos = $anonsub->(1,2,3,4);
p @foos;


# To contrast, here is an example of a closure:
# Notice how this is a function which returns a CODEREF, and then when you call that CODEREF it has access to the
# @inputs variable of its containing function
sub make_closure {
  my @inputs = @_;
  return sub { join ',', @inputs, @_; };
}

my $closure = make_closure(1,2,3,4);
say $closure->('X');
undef $closure;



