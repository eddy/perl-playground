#! /usr/bin/env perl
use v5.14;
use warnings;

use Carp;
use Data::Dumper;
use Data::Printer;
use autodie qw(:all);
use CAM::PDF;

my $pdf  = CAM::PDF->new( 'test_pdf_with_bookmark.pdf' ) || croak "failed to instantiate CAM::PDF";
my $info = $pdf->getValue($pdf->{trailer}->{Info});


if ($info) {
    for my $key (sort keys %{$info}) {
        my $value = $info->{$key};
        if ($value->{type} eq 'string') {
            print "$key: $value->{value}\n";
        } else {
            print "$key: <$value->{type}>\n";
        }
    }
}

if ($info) {
    p $info;
}

my @prefs = $pdf->getPrefs();
p @prefs;

my $root = $pdf->getRootDict();
p $root->{Outlines};
say Dumper($root->{Outlines});

my $pages = $pdf->getPagesDict();
say Dumper($pages);
