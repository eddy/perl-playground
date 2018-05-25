#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

use lib '.';
use Network_Socket;
my $socket = Network_Socket->new( address => '127.0.0.A' );

p $socket;


