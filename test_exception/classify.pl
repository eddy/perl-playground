#!/usr/bin/env perl

use common::sense;
use Getopt::Long;
use File::Copy;
use POSIX qw(strftime);
use IPC::System::Simple qw(run system);
use autodie qw(:all copy move);

use Const::Fast;
const my $PREFIX => 'D_1_BEN_AHS';
const my $DIR    => 'WIP';

my %days = map { $_ => 1 } qw( mon tue wed thu fri sat sun );

# 
# Parameters
#
GetOptions( 'day=s' => \my $day ) or usage();
usage() if ! $day;
$day = lc( substr( $day, 0, 3) );
usage() if ! exists $days{ $day };

#
# Main...
#
run(qq{rm -r $DIR}) if -e $DIR;
mkdir $DIR;

my @groups;

FILE: while ( my $file = glob( '*.txt' ) ) {
    next FILE unless $file =~ m{ $day [.]txt \z }xmsi;

    if ( $file =~ m{ \A control }xmsi ) {
        my $ctl = handle_control( $file, $day);   
        copy( $file, qq{./$DIR/$ctl} );
        
        push @groups, qq{./$DIR/$ctl};
        next FILE;
    }

    my $data = handle_data( $file, $day );
    copy( $file, qq{./$DIR/$data});
    push @groups, qq{./$DIR/$data};
}

#
# TAR'ing
#
my $ts = strftime("%Y%m%d_%H%M%S", localtime(time));
run("tar -zcvf $PREFIX\_$ts.tar.Z -C $DIR .");

exit 0;

#
# Helper subroutines
#
#
sub usage {
    print <<"END";
Usage: 
    $0 --day [mon, tue, wed, thu, fri, sat, sun]

END
    exit 1;
}

sub handle_control {
    my ( $file, $day ) = @_;

    $file =~ s{ \A control}{}xmsi;
    $file =~ s{ $day [.]txt \z }{}xmsi;
    return trim( $file ) . q{.ref};
}

sub handle_data {
    my ( $file, $day ) = @_;

    $file =~ s{ $day [.]txt \z }{}xmsi;
    return trim( $file ) . q{.txt};
}

sub trim {
    my $char = shift;
    $char =~ s/(?:^\s+|\s+$)//g;
    return $char;
}
