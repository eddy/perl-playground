#!/usr/bin/perl 

use strict;
use warnings;
use Benchmark qw(:all);

sub fac {
    my ($number) = @_;

    return 1 if $number <= 2;

    return $number * fac($number - 1);
}


my %cache;
sub cache_fac {
    my ($number) = @_;

    return $cache{$number} if exists $cache{$number};
    if ($number <= 2) {
        $cache{$number} = 1;
    }
    else {
        $cache{$number} = $number * fac($number -1);
    }
}



my $count = -2;
my $t = timethese($count,
            {
                'fac'   => fac(10),
                'cache' => cache_fac(10),
            }
        );

cmpthese($t);

my $a = fac(9);
my $b = cache_fac(9);
print $a . " - " . $b . "\n";

exit 0;

__END__


