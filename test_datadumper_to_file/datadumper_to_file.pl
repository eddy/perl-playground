#!/usr/bin/perl 

use strict;
use warnings;

use Data::Dumper;

my @aoh = ( { a => 1 } );
my $file = 'diskstats.perldata';

out( $file, \@aoh );
undef @aoh;
@aoh = in( $file );

print Dumper \@aoh;

sub out {
    my ( $file, $aoh_ref ) = @_;
    open my $fh, '>', $file
        or die "Can't write '$file': $!";
    local $Data::Dumper::Terse = 1;   # no '$VAR1 = '
    local $Data::Dumper::Useqq = 1;   # double quoted strings
    print $fh Dumper $aoh_ref;
    close $fh or die "Can't close '$file': $!";
}

sub in {
    my ( $file ) = @_;

    open my $fh, '<', $file
        or die "Can't read '$file': $!";
    local $/ = undef;  # read whole file
    my $dumped = <$fh>;
    close $fh or die "Can't close '$file': $!";
    return @{ eval $dumped };
}
