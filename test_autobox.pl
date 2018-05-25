#!/usr/bin/perl

use strict;
use warnings;

use autobox::Core;
use Data::Dumper;

my $string = '      Test me          ';

print $string        . ".....\n";
print $string->strip . "......\n";

print 10->add(5) . "\n";
10->to(15)->say;


print 4->sqrt() . "------\n";


my %hash = (
    one   => '   1   ',
    two   => '2',
    three => '3',
);

print reverse sort keys %hash;     print "\n";
%hash->keys->sort->reverse->print; print "\n";
%hash->each( sub { print $_[1] ."\n" } );
$hash{one}->say;
$hash{one}->strip->say;

print "hello, world!"->uc;         print "\n";
print "hello, world!"->ucfirst;    print "\n";

my @array = qw( 1 20 40 50);

print @array->pop();        print "\n";
print @array->shift;        print "\n";
@array->push(-100)->print;  print "\n";
@array->unshift(35)->print; print "\n";
@array->sort->say;






