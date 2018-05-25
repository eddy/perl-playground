#! /usr/bin/env perl

use v5.14;
use warnings;

use Data::Dumper;
use File::Basename;
use File::Spec::Functions;
use File::Path qw(make_path);

my $pdftk = 'pdftk';


my $file = $ARGV[0];
say("\n$0 <FILENAME>") && exit 1 unless $file;

my $dir        = dirname($file) || '.';
my $output_dir = $ARGV[1]       || $dir;

unless ( -e $output_dir ) {
    make_path $output_dir, { mode => 0755 } unless -e $output_dir;
    die "mkdir failed: $!" unless -e $output_dir;
}


my $string = `$pdftk @{[quotemeta($file)]} dump_data output -`;

my ($last_page) = $string =~ m/NumberOfPages: (\d+)/;
say "last page is $last_page";

my $regex = qr/
    BookmarkTitle:      \s+ (?<title>.*?) \s+
    BookmarkLevel:      \s+ (?<level>\d+) \s+
    BookmarkPageNumber: \s+ (?<page>\d+)
    /x;

my @page_numbers;
while ( $string =~ /$regex/g ) {
    next unless $+{level} == 1;
    push @page_numbers, [ @+{qw(title page)} ];
}

say "Last index is $#page_numbers";

# Chapter&#160;1.&#160;Introduction
while ( my ( $index, $elem ) = each @page_numbers ) {
    last if $index == $#page_numbers;
    $page_numbers[$index]->[0] =~ s/&#160;/ /g;
    unshift @$elem, $page_numbers[$index]->[0] =~ s/(?:Chapter|Appendix)\s+(\d+|[ABC]|).?\s+//g

        ? $1
        : 'XX';
    last if $index == $#page_numbers;

    push @$elem, $page_numbers[ $index + 1 ]->[-1] - 1;
}
unshift @{ $page_numbers[-1] }, 'XX';
push @{ $page_numbers[-1] }, $last_page;

print Dumper( \@page_numbers );

#### # pdftk A=one.pdf B=two.pdf cat A1-7 B1-5 A8 output combined.pdf
#### foreach my $elem (@page_numbers) {
####     my $chapter = $elem->[1] =~ s/\s+/_/rg;
####     my $filename = catfile( $output_dir, "$elem->[0].$chapter.pdf" );
####     say "Splitting Chapter $elem->[0] $elem->[1]";
####     print "Running ", join ' ', $pdftk, $file, 'cat', "$elem->[2]-$elem->[3]", 'output', $filename, "\n";
#### 
####     # comment out this section... dunnot want to create individual PDF file output
####     # system $pdftk, $file, 'cat', "$elem->[2]-$elem->[3]", 'output', $filename;
#### }
