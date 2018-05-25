#!/usr/bin/env perl

use strict;
use warnings;

use PDF::API2;

my $banner_pdf = PDF::API2->new( -file => 'banner.pdf' );
my $page       = $banner_pdf->page();
my $gfx        = $page->gfx();
my $font       = $banner_pdf->corefont('Arial Bold');

$gfx->textlabel(120, 666, $font, 26, 'Client: MLC 509');
$gfx->textlabel(120, 620, $font, 26, 'Stream - PDF Printing');

my $date = localtime();
$gfx->textlabel(120, 500, $font, 26, $date);
$gfx->textlabel(120, 455, $font, 26, 'START');

$banner_pdf->saveas();
$banner_pdf->end();

exit 0;

