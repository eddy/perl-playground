#!/usr/bin/perl 

use strict;
use warnings;


sub upto {
    my ($m, $n) = @_;

    return sub {
        return $m <= $n ? $m++ : undef;
    }
}

my $it = upto(3,5);

use Data::Dumper;
print Dumper($it);

# my $nextval = $it->();
# print $nextval . "---\n";
# 
# $nextval = $it->();
# print $nextval . "------\n";
# 
# $nextval = $it->();
# print $nextval . "---------\n";
# 
# $nextval = $it->();
# print $nextval . "------------\n" if $nextval;

my $count = 2;
while ( defined(my $val = $it->()) ) {
    print $val . '-'x$count . "\n"; 
    $count += 2;
}


exit 0;


