package Eddy;
use common::sense;
use Carp qw( carp croak );

use vars qw( @ISA @EXPORT_OK );
@ISA = qw( Exporter );
@EXPORT_OK = qw( yell );

sub yell {
    carp "die here\n";
}


1;    # true to end package - do NOT remove this line.
