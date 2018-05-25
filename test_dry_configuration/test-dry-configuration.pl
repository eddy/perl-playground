#! /usr/bin/env perl

#
# http://www.effectiveperlprogramming.com/blog/407
#

use v5.14;
use warnings;
use Carp;

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments

use DirHandle;
use Data::Printer;

my @input_files = map { { 
    queue    => shift @{$_},
    filename => shift @{$_},
    @{$_}
} } (
    [ SAL01 => qr<\A MLC509\.(?:PROD|TEST)\.RVH.*.pdf \z>xm ],
    [ SAL03 => qr<\A MLC509\.(?:PROD|TEST)\.(?:TST|PRT)SAL03.*pdf \z>xm ],
);

p @input_files;

foreach my $file (@input_files) {
    my $d = DirHandle->new('.')
        or croak "Failed opening dir: $!";

    my @foo = grep { /$file->{filename}/ } $d->read;
    say $file->{queue};
    p @foo;
}


# my %input_files = (
#     sal01 => qr<\A MLC509\.(?:PROD|TEST)\.RVH.*.pdf \z>xm,
#     sal03 => qr<\A MLC509\.(?:PROD|TEST)\.(?:TST|PRT)SAL03.*pdf \z>xm,
# );
# p %input_files;
# my @foos;
# INPUT: while (my ($k, $v) = each %input_files ) {
#     my $d = DirHandle->new('.')
#         or croak "Failed opening dir: $!";
# 
#     p $k;
# 
#     my @foo = grep { /$v/ } $d->read;
#     push @foos, @foo;
#     last INPUT if @foos;
# }
# 
# p @foos;



