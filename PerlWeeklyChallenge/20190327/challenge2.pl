#!/bin/env perl

use strict;
use v5.14;

# write a one liner to solve FizzBuzz problem and print 1-20.
# However any number divisible by 3 will print "fizz", any divisible by 5 will print "buzz".
# Numbers divisible by both become "fizz buzz".

### All the following codes are equivalent

# for (1..20) {
#     if    ( ! ($_ % 15) ) { $_ = "fizz buzz "}
#     elsif ( ! ($_ % 5) )  { $_ = "buzz" }
#     elsif ( ! ($_ % 3) )  { $_ = "fizz" }
#     say $_;
# }



# for (1..20) {
#     my $foo =
#       ( ! ($_ % 15) ) ? "fizz buzz"
#     : ( ! ($_ % 5)  ) ? "buzz"
#     : ( ! ($_ % 3)  ) ? "fizz"
#     : $_;
#     say $foo;
# }


# for (1..20) {
#     say(
#           ( ! ($_ % 15) ) ? "fizz buzz"
#         : ( ! ($_ % 5)  ) ? "buzz"
#         : ( ! ($_ % 3)  ) ? "fizz"
#         : $_
#     );
# }


# for (1..20) {
#     say(
#            !($_ % 15) ? "fizz buzz"
#         :  !($_ % 5)  ? "buzz"
#         :  !($_ % 3)  ? "fizz"
#         : $_
#     );
# }


# below map block can only be said as one liner:
# perl -E 'map {say( !($_ % 15)?"fizz buzz" : !($_ % 5)?"buzz" : !($_ % 3) ?"fizz" : $_)} (1..20)'
map { say(
          !($_ % 15) ? "fizz buzz"
        : !($_ % 5)  ? "buzz"
        : !($_ % 3)  ? "fizz"
        : $_
    )
} (1..20);
