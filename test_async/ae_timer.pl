#! /usr/bin/env perl

use v5.14;
use warnings;

use AnyEvent;
 
my $foo = localtime; say $foo;
my $cv = AnyEvent->condvar;
 
my $wait_one_and_a_half_seconds = AnyEvent->timer (
   after => 2.0,  # after how many seconds to invoke the cb?
   cb    => sub { # the callback to invoke
      say "Here 2";
      $cv->send;
   },
);
 
# can do something else here
say "Here 1";
 
# now wait till our time has come
$cv->recv;
$foo =  localtime; say $foo;

say "End";

