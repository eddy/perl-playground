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

        my $dict = _g(
            _g(
                _g( $pdf->getPage(1)
                    ->{PieceInfo}       or croak 'No private PieceInfo dictionary!' 
                )   ->{'IBM-ODIndexes'} or croak 'No IBM-ODIndexes dictionary!'
            )->{Private}
        );

        for my $key (sort keys %$dict) {
            my $value =  _g( $dict->{ $key } );
            say sprintf("%-20s : ", $key) . $value;
        }


    }
    else { croak 'Unsupported file type!' };
}


__END__
