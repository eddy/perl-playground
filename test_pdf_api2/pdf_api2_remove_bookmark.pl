#! /usr/bin/env perl

use v5.14;
use warnings;
use PDF::API2;

my $pdfFiles = '/home/et6339/gein0065.pdf';
write_pdf_api2($pdfFiles);
exit 0;

sub write_pdf_api2 {
    my $pdfFile = shift;

    my $pdf = PDF::API2->new( -file => 'output.pdf' );    # new PDF output
    my $input = PDF::API2->open($pdfFile);                # open input PDF

    my @pages = 1 .. $input->pages;
    if ( scalar @pages > 0 ) {
        # iterate through all input PDF's pages
        foreach my $pageNumber (@pages) {
            # open page for the new PDF
            my $page = $pdf->page();
            my $gfx  = $page->gfx();
            $page->mediabox( 0, 0, 594.9, 841.3597 );     # default mediabox to A4

            my $input_page = $input->openpage($pageNumber);
            if ( defined $input_page->{Contents} ) {
                my $xo = $pdf->importPageIntoForm( $input, $pageNumber );
                $gfx->formimage( $xo, 0, 0, 1 );
            }
        }
    }

    $input->end;     # close input PDF
    $pdf->update;    # update new PDF
    $pdf->end;       # flush new PDF
}
