#! /usr/bin/env perl

use v5.14;
use warnings;

use Benchmark 'cmpthese';
use File::Slurp 'read_file';

my $filename = shift or die "No argument given";
my $count = shift || 50000;

cmpthese($count, {
    'Local $/'    => sub { open my $fh, '<', $filename or die "Cannot open $filename: $!";
                           my $buffer = do { local $/; <$fh> }
                         },
    'Unix'        => sub { open my $fh, '<:unix', $filename or die "Couldn't open $filename: $!"; 
                           read $fh, my $buffer, -s $fh or die "Couldn't read $filename: $!"
                         },
    'File::Slurp' => sub { read_file($filename, buffer_ref => \my $buffer, binmode => ':raw') },
});


# cmpthese($count, {
#     'Local $/'    => sub { open my $fh, '<', $filename or die "Cannot open $filename: $!";
#                            my $buffer = do { local $/; <$fh> }
#                          },
#     'File::Slurp' => sub { read_file($filename, buffer_ref => \my $buffer, binmode => ':raw') },
# });
