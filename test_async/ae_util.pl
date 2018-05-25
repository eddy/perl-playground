#! /usr/bin/env perl

use v5.14;
use warnings;

use AnyEvent;
use AnyEvent::Util;
 
my $foo = localtime; say $foo;

my $quit_program = AnyEvent->condvar;
my $cv = run_cmd [qw(ls -l)],
   "<" , "/dev/null",
   ">" , \my $stdout,
   "2>", "/dev/null";
 
$cv->cb (sub {
   shift->recv and die "command failed";
 
   say "Here----------------------------------------------";
   say $stdout;

   $quit_program->send;
});

$quit_program->recv;
say "End";
