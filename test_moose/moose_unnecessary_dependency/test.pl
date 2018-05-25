#!/usr/bin/perl

use strict;
use warnings;

use lib '.';
use MyClass;
my $class = MyClass->new( bar => MyBar->new );
print $class->bar; # or whatever

