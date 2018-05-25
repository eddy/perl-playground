#! /usr/bin/env perl

use v5.14;
use warnings;

no strict 'refs';
my $foo = q{
  my $bar = 'bar';
  print $bar . "-----";
};

sub f { eval "$foo"; }
my $action = 'f';

# your subs above won't get call till this line is invoked
$action->();



