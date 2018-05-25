#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments

use Fcntl 'O_RDWR', 'O_CREAT';
use SDBM_File;

tie my %h, 'SDBM_File', '/tmp/footest', O_RDWR|O_CREAT, 0666
    or die "$!";

$h{ouch} = '-' x 524;
say 'ok1';

$h{bouches} = '-' x 1024;
say 'ok2';



