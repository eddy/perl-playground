#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Unicode::UCD 'charinfo';

my $file = 'BUG_2471_F_BC_08_P_0697_201605111.dat__';
open my $foh, "<:encoding(UTF-8)", $file
    or die "cannot open file: $!";

binmode( STDOUT, ":encoding(UTF-8)");

while (my $line = <$foh>) {

    my @chars = split //, $line;
    foreach my $char (@chars) {
        my $hex = sprintf "%x", ord($char);
        say $char . ' : ' . ord($char) . ' - Hex: ' . $hex;
    }
}

close $foh;
exit 0;

__END__
