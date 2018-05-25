#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);
use File::Basename qw (fileparse);

use PDF::API2;

my $bookmark = 1;
my @pdfFiles = qw( desktop.pdf);
write_pdf_api2( 'desktop_new.pdf', @pdfFiles );

sub write_pdf_api2 {
    my ($outputpdf) = fileparse( shift @_ );
    my @pdfFiles = @_;

    my ( $file, $pdf, $root, );
    $pdf = PDF::API2->new( -file => $outputpdf );

    #default mediabox to A4
    $pdf->mediabox( 0, 0, 612, 859 );

    $pdf->info(
        'Author'   => 'Foobar - Test for Tim Tam',
        'Creator'  => $0,
        'Producer' => "Foobar - Test, 6666 Hight St",
        'Title'    => "Foobar - Test, 61524363",
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

             my  $xml=<<EOT;
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <rdf:Description rdf:about="" xmlns:dc="http://purl.org/dc/elements/1.1/">
         <dc:subject>
            <rdf:Bag>
               <rdf:li>CompanyName: Eddy Test</rdf:li>
               <rdf:li>DateScanned: Today Test - 24/11/2017</rdf:li>
               <rdf:li>Resolution: 300dpi</rdf:li>
               <rdf:li>LevelOfAccuracy: 2</rdf:li>
            </rdf:Bag>
         </dc:subject>
      </rdf:Description>
  </rdf:RDF>
</x:xmpmeta>
EOT


    my $xml1 = $pdf->xmpMetadata( $xml );
    p $xml1;

    $pdf->update;



    $pdf->end;
}
