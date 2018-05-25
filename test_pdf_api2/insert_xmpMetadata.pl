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
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<!-- XMP extension schema container schema for the fm schema -->
<rdf:Description rdf:about=""
  xmlns:pdfaExtension="http://www.aiim.org/pdfa/ns/extension/"
  xmlns:pdfaSchema="http://www.aiim.org/pdfa/ns/schema#"
  xmlns:pdfaProperty="http://www.aiim.org/pdfa/ns/property#" >

  <!-- Container for all embedded extension schema descriptions -->
  <pdfaExtension:schemas>
    <rdf:Bag>
      <rdf:li rdf:parseType="Resource">
        <!-- Optional description of schema -->
        <pdfaSchema:schema>Foo Machines Schema</pdfaSchema:schema>

        <!-- Schema namespace URI -->
        <pdfaSchema:namespaceURI>http://www.foobar.com/ns/testMetadata/1/</pdfaSchema:namespaceURI>

        <!-- Preferred schema namespace prefix -->
        <pdfaSchema:prefix>fm</pdfaSchema:prefix>

        <!-- Description of schema properties -->
        <pdfaSchema:property>
          <rdf:Seq>
            <rdf:li rdf:parseType="Resource">
              <pdfaProperty:name>Name</pdfaProperty:name>
              <pdfaProperty:valueType>Text</pdfaProperty:valueType>
              <pdfaProperty:category>external</pdfaProperty:category>
              <pdfaProperty:description>Name of person</pdfaProperty:description>
            </rdf:li>

            <rdf:li rdf:parseType="Resource">
              <pdfaProperty:name>Address</pdfaProperty:name>
              <pdfaProperty:valueType>Text</pdfaProperty:valueType>
              <pdfaProperty:category>external</pdfaProperty:category>
              <pdfaProperty:description>Full Address</pdfaProperty:description>
            </rdf:li>

            <rdf:li rdf:parseType="Resource">
              <pdfaProperty:name>UniqueNumber</pdfaProperty:name>
              <pdfaProperty:valueType>Text</pdfaProperty:valueType>
              <pdfaProperty:category>external</pdfaProperty:category>
              <pdfaProperty:description>Person ID</pdfaProperty:description>
            </rdf:li>

          </rdf:Seq>
        </pdfaSchema:property>
      </rdf:li>
    </rdf:Bag>
  </pdfaExtension:schemas>
</rdf:Description>

<rdf:Description rdf:about=""  xmlns:fm="http://www.foobar.com/ns/testMetada/1/">
  <fm:Name>Tim Halroyd</fm:Name>
  <fm:Address>6666 High Street</fm:Address>
  <fm:UniqueNumber>61524363</fm:UniqueNumber>
</rdf:Description>
</rdf:RDF>

EOT


    my $xml1 = $pdf->xmpMetadata( $xml );
    p $xml1;

    $pdf->update;



    $pdf->end;
}
