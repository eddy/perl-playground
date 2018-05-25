#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);
use File::Basename qw (fileparse);

use PDF::API2;

my $bookmark = 1;
my @pdfFiles = qw( rlumraad.pdf);
write_pdf_api2( 'rlumraad_new.pdf', @pdfFiles );

sub write_pdf_api2 {
    my ($outputpdf) = fileparse( shift @_ );
    my @pdfFiles = @_;

    my ( $file, $pdf, $root, );
    $pdf = PDF::API2->new( -file => $outputpdf );

    #default mediabox to A4
    $pdf->mediabox( 0, 0, 612, 859 );

    $pdf->info(
        'Author'   => 'Foobar',
        'Creator'  => $0,
        'Producer' => "PDF::API2",
    );

    $root = $pdf->outlines;

    my $import_page   = 0;
    my $document_page = 0;


    foreach $file (@pdfFiles) {
        my ( $inputpdf, $inputdir ) = fileparse( shift @_ );

        print "Inside here ------- $file \n";
        my $input = PDF::API2->open($file);

        my @pages = 1 .. $input->pages;

        if ( scalar @pages > 0 ) {
            my $outline;
            $outline = $root->outline
                if $bookmark;

            foreach my $ind (@pages) {
                ++$import_page;
                ++$document_page;

                # EDDY
                my $page = $pdf->page();
                my $gfx  = $page->gfx();

                # EDDY:
                # my $page = $pdf->importpage( $input, $_, $import_page );
                p $ind;
                p $import_page;
                my $page1 = $input->openpage($import_page);

                if ( defined $page1->{Contents} ) {
                    my $xo = $pdf->importPageIntoForm( $input, $import_page );
                    $gfx->formimage( $xo, 0, 0, 1 );
                }

                if ($bookmark) {

                    # create bookmark
                    my ($bmtext) = ( $inputpdf =~ /([^\.]+)/ );
                    $bmtext .= ' -------------- ';
                    $outline->title($bmtext);

                    my $bm = $outline->outline;
                    $bm->title("page TEST: $document_page");

                    $bm->dest($page);
                    $outline->dest($page) if $document_page == 1;
                    $outline->closed;
                }
            }

        }

        $input->end;
    }


    $pdf->preferences( -outlines => 1 )
        if $bookmark;

    $pdf->update;
    $pdf->end;
}
