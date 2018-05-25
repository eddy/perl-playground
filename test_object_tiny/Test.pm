#!/usr/bin/env perl
use strict;
use warnings;

package Foo;
use Object::Tiny qw{ bar baz };

# create own bas(), note: not in the "use" above...
sub bas {
    my $self = shift;
    if (@_) { $self->{bas} = shift }
    return $self->{bas};
}

1;

######################################################################
package Fubar;
use base 'Foo';
1;


######################################################################
package main;
use Data::Printer;
use Test;

# initialize object accessor...
my $o = Foo->new( bar => 'aaaa',  
                  bas => 2,
                );

# dump object...
print "Dump obect \$o...\n";
p $o;
print "\n";

# method bar()...
print "Method bar()...\n";
p $o->bar;
print "\n";

# method baz()...
print "method baz() is available here but undefined...\n";
p $o->baz;
print "\n";

# directly set baz, AVOID it...
$o->{baz} = 'foo';

# dump object again..
print "dump \$o again after directly set \$o->{baz}, AVOID it!!!\n";
p $o;
print "\n";

# directlry print bas...
print "directly print hash bas, \$o->{bas}, AVOIT it!!!\n";
print $o->{bas} . ".....................\n";
print "\n";

# method bas()...
print "own method bas() is fine...\n";
print $o->bas . "\n";
print "\n";

# method bas() again...
print "method bas() is a setter, fine here...\n";
$o->bas(123);
print $o->bas . "\n";
print "\n";

# Fubar object...
print "Fubar object inherits from Foo, set and print bar() ...\n";
my $f = Fubar->new(bar => 'bbbb' );
print $f->bar() . "\n";
print "\n";

# print object $o again...
print "Object \$o bar() again...\n";
p $o->bar();
print "\n";

exit 0;


