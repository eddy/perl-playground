#!/usr/bin/env perl

use 5.012;
use warnings;
use PDF::API2::Simple;

our $PageNo;

my $pdf = PDF::API2::Simple->new(
    file   => 'output1.pdf',
    header => \&header,
    footer => \&footer,
);

$pdf->add_font('Verdana');

for my $page (1..3) {
    $pdf->add_page;
#    $pdf->image( 'image.png', x => 300, y => 300 );
}
$pdf->save;  


sub header { shift->text( 'Header text here' ) }
sub footer { shift->text( 'page:  ' . ++$PageNo, x => 10, y => 10 ) }

