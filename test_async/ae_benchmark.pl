#! /usr/bin/env perl

#                   s/iter      AnyEvent   Serial
#   AnyEvent          11.8         --       -23%
#   Serial            9.03         30%       --

use v5.14;
use warnings;
use AnyEvent;
use AnyEvent::Util;
use Benchmark qw(:all) ;


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

# cmpthese(-5, {
#     'Serial'   => \&SERIAL,
#     'AnyEvent' => \&AE,
# });

SERIAL();
AE();

sub AE {
    my $s1    = time;

    my $quit_program = AnyEvent->condvar(
        cb => sub {
            warn "------------------------------------- done async";
        }
    );

    my $result;
    $quit_program->begin( sub { shift->send($result) } );

    for my $file (@files) {
        $quit_program->begin;

        my $cv; $cv = run_cmd [qw(zip), "${file}.zip", $file],
                    "<" , "/dev/null",
                    ">" , "/dev/null",
                    "2>", "/dev/null";

        my $now = time;
        $cv->cb (sub {
            shift->recv and die "command failed";

            # undef $cv;
            $result .= "Finish in " . (time - $now) . " ms\n";
            $quit_program->end;
        });
    }

    $quit_program->end;   # end loop
    warn "End of loop";

    my $foo = $quit_program->recv;
    say $foo;
    say "Total elapsed time: ", time - $s1, " ms";
}

sub SERIAL {
    my $s1    = time;
    for my $file (@files) {
        my $now = time;
        `zip ${file}.2.zip $file`;
        say "Finish in ", time - $now, " ms";
    }
    warn "End of loop";
    warn "------------------------------------- done serial";
    say "Total elapsed time: ", time - $s1, " ms";
}

