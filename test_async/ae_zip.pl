#! /usr/bin/env perl

use v5.14;
use warnings;
use AnyEvent;
use AnyEvent::Util;
 

my $quit_program = AnyEvent->condvar(
    cb => sub {
            warn "done";
    }
);

my @files = qw(
    testdata1
    testdata2
    testdata3
    testdata4
    testdata5
    testdata6
    testdata7
    testdata8
    testdata9
    testdata10
);

my $s1    = time;
my $start = localtime; say "Start: $start";

my $result;
$quit_program->begin( sub { shift->send($result) } );

for my $file (@files) {
    $quit_program->begin;

    my $cv; $cv = run_cmd [qw(zip), "${file}.zip", $file],
                 "<" , "/dev/null",
                 ">" , "/dev/null",
                 "2>", "/dev/null";
    
    $cv->cb (sub {
        shift->recv and die "command failed";
        
        my $now = localtime; 
        say "Here, $now ----------------------------------------------";

        undef $cv;
        $quit_program->end;
    });
}


$quit_program->end;
my $foo = $quit_program->recv;

say "Total elapsed time: ", time - $s1, " ms";
