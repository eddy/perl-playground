#!/usr/bin/perl

use strict;
use warnings;
# use re 'debugcolor';

my $text = '/F12345 FF FF this is SCF SF really MV (important stuff SH';

$text =~ m{^
            (\/F\d+)?    # /F12345
            \s 
            FF            
            \s 
            (.*?)         # FF this is
            \s 
            SCF 
            \s 
            SF 
            \s 
            (.*?)         # really
            \s 
            MV 
            \s            # important stuff
            (\(.*?)SH 
          $}xm;


# $text =~ m{^(\/F\d+) FF (?>((?:[^S]|S[^C]|SC[^F]SCF\B)*))SCF SF (?>((?:[^M]|M[^V]|MV\B)*))MV (?>(\((?:[^S]|S[^H]|SH.)*))SH$};

print $1 . "\n";
print $2 . "\n";
print $3 . "\n";
print $4 . "\n";


