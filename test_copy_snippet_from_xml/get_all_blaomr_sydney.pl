#!/usr/bin/perl -w

use strict;

use XML::Simple;
use Data::Dumper;

my $xs = new XML::Simple( KeepRoot => 0,
                          NoAttr => 1,
                          XMLDecl => 1,
                          ForceArray => [ qw(Job) ],
                          SuppressEmpty => '',
                          NormaliseSpace => 2 );

my $xml;
eval { $xml = $xs->XMLin('clink.starsactuals.20060707.113527.xml'); };
if($@) {
    die "ERROR ERROR ERROR ERROR\n";
}

# print Data::Dumper::Dumper($xml->{Job});

my @output = ();
for my $job (@{$xml->{Job}}) {
    if (
        $job->{Printing}->{FormName} eq 'BLA OMR'
        && $job->{Printing}->{Location} eq 'Sydney' 
    ) {
        push @output, $job;
    }
}

# print Data::Dumper::Dumper(\@output);

# open(FH, '> /home/et6339/foo.xml') || die "cannot open file\n";
# close FH || die "cannot close\n";

my $output_hash = { Job => \@output };
my $xl = new XML::Simple( RootName => 'Jobs',
                          NoAttr => 1,
                          KeyAttr => [],
                          XMLDecl => 1,
                          SuppressEmpty => '' );

eval { $xl->XMLout($output_hash, OutputFile => '/home/et6339/fubar.txt') };
if ($@) {
    die "BLAAAAHHHHHHH BLAHHHHHHHH\n";
}


exit 0;

