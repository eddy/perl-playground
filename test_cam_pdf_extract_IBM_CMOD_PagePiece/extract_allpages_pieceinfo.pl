#! /usr/bin/env perl

use 5.020;
use warnings;
use CAM::PDF;
use Carp;

my $pdf;                  # global CAM::PDF object
my $fn = shift or die;    # input PDF
get_compressed_data_fh( $fn );
exit 0;

####################################################################################################
sub _g { $pdf-> getValue( @_ )}

sub get_compressed_data_fh {
    my ( $fn ) = @_;

    if ( $fn =~ /pdf$/xi ) {
        $pdf = CAM::PDF-> new( $fn ) or die;
        my $total_pages = $pdf->numPages();
        say "Parsing PDF: $fn";
        say "Total pages: $total_pages";

        my $count = 0;
        PAGE: for my $pageNo (1 .. $total_pages) {
            my $page          = $pdf->getPage( $pageNo )->{PieceInfo} or next PAGE;
            my $ibm_ODindexes = _g( $page )->{'IBM-ODIndexes'}        or next PAGE;
            my $dict          = _g( _g( $ibm_ODindexes )->{Private} );

            say "* Document number [" . ++$count . "], start page number : $pageNo";
            for my $key (sort keys %$dict) {
                my $value =  _g( $dict->{ $key } );
                say sprintf("%4s %-20s : ", q[ ], $key) . $value;
            }
        }
    }
    else { croak 'Unsupported file type!' };
}


__END__
