#!/bin/env perl


use strict;
use warnings;
use Getopt::Long;
use POSIX;
use File::Basename;
use Data::Dumper;
use POSIX qw(strftime);

use PDF::API2;


my @input = qw(AS400Q.GHWB021F2.11468.pdf);
{
    foreach my $pdf (@input) {
        my $inpdf   = PDF::API2->open( $pdf );
        my $outpdf  = PDF::API2->new();
        $outpdf->preferences( -outlines => 1 );
        my $root    = $outpdf->outlines;

        my $tot_pages = $inpdf->pages();
        for my $page_no (1 .. $tot_pages) {
            my $page = $outpdf->import_page($inpdf, $page_no, $page_no);
        }

        $outpdf->saveas( 'sample_output_rotated.pdf' );

        undef $inpdf;
        undef $outpdf;
    }
}

exit 0;
