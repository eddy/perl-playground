#!/usr/bin/perl -w

use strict;

use XML::Simple;
use Data::Dumper;

my $text_file_input = 'catchup_feed_to_mips_qld_20061030_1400.csv';
open(FOP, $text_file_input) || die "cannot open file: $!";

my @output = ();
while (<FOP>) {
    my $hash = {};
    chomp;
    ($hash->{Status}, $hash->{MIPSNo} ) = split(/,/, $_);
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

eval { $xl->XMLout($output_hash, 
       OutputFile => '/home/et6339/clink.xxxSTATExxx.mipsconfirm.20061030_01.manual.xml') };

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

