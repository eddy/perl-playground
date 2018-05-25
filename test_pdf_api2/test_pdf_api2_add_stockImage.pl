#!/usr/bin/env perl

use v5.22;
use warnings;

use Benchmark;
use Memory::Stats;
use PDF::API2;

my $start = Benchmark->new;
{
    my $stats = Memory::Stats->new;
    $stats->start;
    $stats->checkpoint("before my big method");
    {
        # big method
        # my $pdf = PDF::API2->open('For_POC/Test1000.pdf');
        my $pdf = PDF::API2->open('For_POC/newfile.pdf');
        my $first_image  = $pdf->image_tiff('For_POC/FX1400_AGL0017_Bill_Business_Paper.tif');
        my $second_image = $pdf->image_tiff('For_POC/Useful_Information.tif');
        my $third_image  = $pdf->image_tiff('For_POC/Important_Information.tif');

        for my $index (1 .. $pdf->pages) {
            my $page = $pdf->openpage($index);
            my $gfx = $page->gfx;
            if ($index % 2 == 0) {
                # reverse page
                $gfx->image($third_image, 28, 480, 0.25);
            }
            else {
                $gfx->image($first_image, 10, 10, 0.26);
                $gfx->image($second_image, 377, 124, 0.27);
            }
        }

        $pdf->saveas('output.pdf');
        $pdf->end;
    }
    $stats->checkpoint("after my big method");
    $stats->stop;
    $stats->report;
}
my $stop = Benchmark->new;
my $diff = timediff( $stop, $start );
say "--> Process running time "  . timestr($diff, 'all');

exit 0;
