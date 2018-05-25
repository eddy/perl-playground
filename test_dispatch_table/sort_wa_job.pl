#!/usr/bin/perl

use strict;
use warnings;

my %job_details_info;
my @files;

# Dispatch table, an alternative to the cascading if-elsif below...
my %dispatch = ( Job   => \&job,
                 File  => \&file,
                 Image => \&image, 
               );

LINE:
while (my $line = <>) {
#
# DON'T USE THIS Tabular Ternaries METHOD...
# This is WRONG and perl will complain with:
# Useless use of a constant in void context at ...
#    
#     $line =~ m{\A Job:  }xms ? $job_details_info{Job}   = $line
#   : $line =~ m{\A Image }xms ? $job_details_info{Image} = $line
#   : $line =~ m{\A File: }xms ? push(@files, $line)
#                              : q{} ;
# 
# Actually, as an alternative to the if-elsif-else below, if the conditions
# become more and more, it's better to use the dispatch table below...
#    
#     my $re = join( '|', keys %dispatch );
#     if( $line =~ m/($re)/ ) {
#         $dispatch{$1}->($line);
#     }
    
    if ($line =~ m{\A Job:  }xms) {
        $job_details_info{Job}  = $line;
    }
    elsif ($line =~ m{\A File: }xms) {
        push @files, $line;
    }
    elsif ($line =~ m{\A Image }xms) {
        $job_details_info{Image} = $line;
    }
    
    # print to STDOUT...
    if ( $line =~ m{\A [-]+ }xms
         && $job_details_info{Job} 
         && scalar @files
         && $job_details_info{Image}
    ) {
        for my $type (qw{Job Image}) {
            print "$job_details_info{$type}";
        }

        for my $file ( @files ) {
            print "$file";
        }

        # print dash line...
        print '-'x70 . "\n\n";
        
        # Reset the files array...
        undef @files;
    }
}

exit 0;


######################################################################
# Helper subroutines for the dispatch table method...
#

sub job {
    my ($line) = @_;
    $job_details_info{Job} = $line;
}

sub image {
    my ($line) = @_;
    $job_details_info{Image} = $line;
}

sub file {
    my ($line) = @_;
    push @files, $line;
}
