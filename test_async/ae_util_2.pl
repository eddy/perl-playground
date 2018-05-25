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

my @dirs = qw(
    ./
    /
    /home/et6339
);

my $s1    = time;
my $start = localtime; say "Start: $start";

my $result;
$quit_program->begin( sub { shift->send($result) } );

for my $dir (@dirs) {
    $quit_program->begin;

    my $cv; $cv = run_cmd [qw(ls -l), $dir],
                 "<" , "/dev/null",
                 ">" , \my $stdout,
                 "2>", "/dev/null";
    
    $cv->cb (sub {
        shift->recv and die "command failed";
        
        my $now = localtime; 
        say "Here, $now ----------------------------------------------";
        push @$result, $stdout;

        undef $cv;
        $quit_program->end;
    });
}


$quit_program->end;
my $foo = $quit_program->recv;

print join( "\n", @$foo ), "\n";
say "Total elapsed time: ", time - $s1, " ms";
