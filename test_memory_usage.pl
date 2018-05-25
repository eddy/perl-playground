#!/usr/bin/perl

use strict;
use warnings;
use IPC::System::Simple qw( runx );
use Devel::Peek;

print "Starting...\n";
runx('ps', '-o', "rss,vsz", $$);
print "\n";

mem();
 
print "Outside lexical scope\n";
runx('ps', '-o', "rss,vsz", $$);
print "\n";

print '-'x50 ; 
print "Done\n";

sub mem {
    print "allocating \@foo\n";
    my @foo = map { $_  } (1 .. 100000);
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";
    Dump(\@foo);
    print "\n";

    print 'allocating @bar' . "\n";
    my @bar = map { $_  } (1 .. 100000);
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";
    
    print "allocating baz\n";
    my @baz = map { $_  } (1 .. 100000);
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";
 
    print "allocating a bunch of other variables\n";
    my @fubar = map {  $_ } (1 .. 100000);
    my @fubaz = map {  $_ } (1 .. 100000);
    my @fubas = map {  $_ } (1 .. 100000);
    my @fubaa = map {  $_ } (1 .. 100000);
    my @fubab = map {  $_ } (1 .. 100000);
    my @fubac = map {  $_ } (1 .. 100000);
    my @fubad = map {  $_ } (1 .. 100000);
    my @fubae = map {  $_ } (1 .. 100000);
    my @fubaf = map {  $_ } (1 .. 100000);
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";
    

    print "undefing \@foo \n";
    undef @foo;
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";
    Dump(\@foo);
    print "\n";
    
    print "undefing \@bar and \@baz\n";
    undef @bar; undef @baz;
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";

    print "undefing all other varialbes\n";
    undef @fubar;
    undef @fubaz;
    undef @fubas;
    undef @fubaa;
    undef @fubab;
    undef @fubac;
    undef @fubad;
    undef @fubae;
    @fubaf = undef;
    runx('ps', '-o', "rss,vsz", $$);
    print "\n";

}
