#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments

#!/usr/bin/perl
use strict;
use warnings;

use PDF::API2;

# Create a blank PDF file
my $pdf = PDF::API2->new();

# Add a blank page
my $page = $pdf->page();

my $font = $pdf->ttfont('seguisym.ttf');
# my $font = $pdf->ttfont('DejaVuSans.ttf');

# my $ustring = "\x{1F385}  Ho ho ho!";
my $ustring = "\N{FATHER CHRISTMAS}  Ho! ho! ho!";

# Add some text to the page
my $text = $page->text();

$text->font($font, 20);
$text->translate(80, 710);
$text->text($ustring);

# Save the PDF
$pdf->saveas('test.pdf');
