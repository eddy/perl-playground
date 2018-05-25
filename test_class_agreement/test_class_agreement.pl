#!/usr/bin/perl

use strict;
use warnings;
use lib ".";
use TestClassAgreement;

my $foo     = TestClassAgreement->new();
my $name    = $foo->test();
my $num     = $foo->count();
my $new_val = $foo->addone();

print $name    . " <--- \n\n";
print $num     . "\n\n";
print $new_val . "..... \n\n";

exit 0;


