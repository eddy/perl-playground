#!/usr/bin/perl -w

use strict;

use XML::Simple;
use Data::Dumper;

my $text_file_input = 'SeptemberInvoice_001.csv';
open(FOP, $text_file_input) || die "cannot open file: $!";

my @output = ();
while (<FOP>) {
    my $hash = {};
    chomp;
    ($hash->{JobSeqNo}, $hash->{BatchNo} ) = split(/,/, $_);
    $hash->{Status} = 'Completed';
    $hash->{DateProcessed} = '11/10/06';
    push @output, $hash;
}
close FOP || die "cannot close file: $!";

# print Data::Dumper::Dumper(\@output);

my $output_hash = { Job => \@output };
my $xl = new XML::Simple( RootName => 'Jobs',
                          NoAttr => 1,
                          KeyAttr => [],
                          XMLDecl => 1,
                          SuppressEmpty => '' );

eval { $xl->XMLout($output_hash, OutputFile => '/home/et6339/stars2mips_input.xml') };
if ($@) {
    die "BLAAAAHHHHHHH BLAHHHHHHHH\n";
}



# my @output = ();
# for my $job (@{$xml->{Job}}) {
#     if (
#         $job->{Printing}->{FormName} eq 'BLA OMR'
#         && $job->{Printing}->{Location} eq 'Sydney' 
#     ) {
#         push @output, $job;
#     }
# }
# 
# my $output_hash = { Job => \@output };
# my $xl = new XML::Simple( RootName => 'Jobs',
#                           NoAttr => 1,
#                           KeyAttr => [],
#                           XMLDecl => 1,
#                           SuppressEmpty => '' );
# 
# eval { $xl->XMLout($output_hash, OutputFile => '/home/et6339/fubar.txt') };
# if ($@) {
#     die "BLAAAAHHHHHHH BLAHHHHHHHH\n";
# }


exit 0;

