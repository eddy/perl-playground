#! /usr/bin/env perl

use 5.014;
use warnings;
use Carp;
use MyTest;
use Data::Printer;

my $obj = MyTest->new( name => 'Eddy' );
p $obj;

p $obj->packId;


