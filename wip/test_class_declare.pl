#!/usr/bin/perl -w
use strict;

use lib ".";
use ClassDeclare;
use Data::Dumper;

my $obj = ClassDeclare->new();
print "\$obj: " .  Dumper($obj);

my $test1 = $obj->test1("test 1");
print "\$test1:" . Dumper($test1) ;
print "\$obj: " .  Dumper($obj);

# my $test2 = $obj->_test2("test 2");
# my $test2 = ClassDeclare::_test2("test 2");
# print "\$test2:" . Dumper($test2) ;

exit 0;

