#!/usr/bin/env perl

use common::sense;

use PDF::API2 qw();
use Text::PDF::TTFont;

my %A4_portrait = ( w => 595, h => 842 );

{
    # my $pdf = PDF::API2->open('blank.pdf');
    # my $pdf = PDF::API2->open('MLC509.PROD.authorised_consolidated_orders.pdf');
    my $pdf = PDF::API2->open('meta_mail_nor_a.app_apps_1.test.pdf');

    for my $index (1 .. $pdf->pages) {
        next if ( $index % 2 == 0 );    # only interested on odd page number

        my $page = $pdf->openpage($index);
        my $txt  = $page->text;    # for text on page
        my $gfx  = $page->gfx;     # for image on page, incl barcode
        
        #
        # Get the coordinates for the page corners to determine orientation
        #
        my $portrait = 1;
        my ($llx, $lly, $urx, $ury) = $page->get_mediabox();
        if ( ($urx >= $A4_portrait{h} - 10) && ($urx <= $A4_portrait{h} + 10)
                 && ($ury >= $A4_portrait{w} - 10) && ($ury <= $A4_portrait{w} + 10)
        ) {
            $portrait = 0;
        }

        #
        # TODO: Text::PDF does embedded subset font correctly. May be I can
        #
        # my $font = Text::PDF::TTFont->new($pdf, 'verdana.ttf', "testfont", -subset => 1);

        #
        # TTF font
        #
        my $font = $pdf->ttfont('fonts/verdana.ttf', -subset => 1);
        $txt->textlabel( 170, 170, $font, 20, 'TTF font (Verdana)');

        #
        # Core font
        #
        $txt->textlabel(300, 700, $pdf->corefont('Helvetica Bold'), 12, 'Corefont (Helvetica Bold)');

        #
        # PS font (for barcode image?) or TTF?
        #
        # my $font = $pdf->psfont('3of9.pfb', -afmfile => '3of9.afm');
        my $font = $pdf->ttfont('fonts/FRE3OF9X.TTF');   

        my $x_pos = 30;
        my $y_pos = 200;

        if ( $portrait) {
            $gfx->textlabel( $x_pos, $y_pos, 
                            $font, 22, 
                            '*00000' . $index . '00123N*', 
                            -rotate => 90 );
        }
        else {
            $gfx->textlabel( $y_pos, $A4_portrait{w} - $x_pos, 
                            $font, 22, 
                            '*00000' . $index . '00123N*', 
                            -rotate => 0 );
        }

        #
        # Interleave 2of5 barcode
        #
        my $font = $pdf->ttfont('fonts/i2of5txt.ttf');   
        $gfx->textlabel( 400, 50, 
                         $font, 22, 
                         '(N1G]8)',
                         -rotate => 0 );

        #
        # Added PNG image
        #
        # $gfx->image($pdf->image_png('Header_image.png'), 150, 700);
    }

    $pdf->saveas('output.pdf');
    $pdf->end;
}

