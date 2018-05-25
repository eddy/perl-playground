#! /usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::Basename;
use File::Spec::Functions;
use File::Path qw(make_path);

my $pdftk = 'pdftk';


my $file = $ARGV[0];
print("\n$0 <FILENAME>\n") && exit 1 unless $file;

my $dir        = dirname($file) || '.';
my $output_dir = $ARGV[1]       || $dir;

unless ( -e $output_dir ) {
    make_path $output_dir, { mode => 0755 } unless -e $output_dir;
    die "mkdir failed: $!" unless -e $output_dir;
}

# dump pdftk output to a scalar
my $string = `$pdftk @{[quotemeta($file)]} dump_data output -`;

# need the last page in the last step below
my ($last_page) = $string =~ m/NumberOfPages: (\d+)/;
print "last page is $last_page\n";

# pdftk's (as of version 1.41) static structure for bookmarks
my $regex = qr/
                 BookmarkTitle:      \s+ (?<title>.*?) \s+
                 BookmarkLevel:      \s+ (?<level>\d+) \s+
                 BookmarkPageNumber: \s+ (?<page>\d+)
              /x;

#
# The following two "while" loops is to create the below list-of-list structure:
# [
#   [
#     '527: 00031165',    # BookmarkTitle
#     1053,               # Start page
#     1054                # End page
#   ],
# ]
#
my @page_numbers;
while ( $string =~ /$regex/g ) {
    next unless $+{level} == 1;                  # only interested in the top-level bookmark
    push @page_numbers, [ @+{qw(title page)} ];  # push Title and PageNumber
}

# this loop is to calculate the number of page for each mail pack
my $index = 0;
foreach my $elem (@page_numbers) {
    last if $index == $#page_numbers;
    # push @$elem, $page_numbers[ $index + 1 ]->[-1] - 1;
    push @$elem, $page_numbers[ $index + 1 ]->[-1] - $page_numbers[ $index ]->[-1];
    $index++;
}

# last document needs total pages too
push @{ $page_numbers[-1] }, $last_page - $page_numbers[-1]->[-1] + 1;

print Dumper( \@page_numbers );

