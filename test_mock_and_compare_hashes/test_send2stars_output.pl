#!/opt/perl/bin/perl

use strict;
use warnings;
use 5.010;

# Modules.
use XML::Simple qw(:strict);
use Try::Tiny;

# Test suites
use Test::More;
use Test::Deep;

# XML files to compare.
my $old_file = 'clink.starsactuals.20091208.145732.xml';
my $new_file = 'clink.starsactuals.20091208.150058.xml';

my $ref = XML::Simple->new(
              KeepRoot       => 0,
              NoAttr         => 1,
              KeyAttr        => [],
              ForceArray     => [ qw( Job Insert ) ],
              SuppressEmpty  => '',
              NormaliseSpace => 2 
          );

# hash references to store the xml structure
my ( $old_data, $new_data);

try { 
    $old_data = $ref->XMLin( $old_file );
} catch {
    die "ERROR: parsing XML file: $_";
};

try { 
    $new_data = $ref->XMLin( $new_file );
} catch {
    die "ERROR: parsing XML file: $_";
};

# restructured hashes, i.e. $old{BatchNo}{JobSeqNo} so we can compare them
my ( %old, %new);
foreach my $o ( @{ $old_data->{Job} } ) {
    $old{ $o->{Key}->{BatchNo} }{ $o->{Key}->{JobSeqNo} } = $o;
}

foreach my $n ( @{ $new_data->{Job} } ) {
    $new{ $n->{Key}->{BatchNo} }{ $n->{Key}->{JobSeqNo} } = $n;
}

cmp_deeply( \%old, \%new, 'Compared both hashes' );
done_testing( 1 );

exit 0;
