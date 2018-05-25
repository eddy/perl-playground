#!/usr/bin/perl

use strict;
use warnings;

######################################################################
# Modules...
#
use Time::Piece;
use Time::Seconds;
use FindBin;
use lib "$FindBin::Bin";
use Clink::CentrelinkDB;

# All WA jobs...
# Produced from: 
# select ca_job_id from client_application where ca_distibutution_state = 'WA'
my %wa_job_name = map { $_ => 1 } qw(
    B_BLP3B4 B_BLP3C4 B_PYND03 B_PYNT03 P_BL02C1
    P_BL02T1 P_BLP1A1 P_BLP1A2 P_BLP1B1 P_BLP1D1
    P_BLP1L1 P_BLP1M1 P_BLP1Q1 P_BLP1R1 P_BLP1V1
    P_BLP1W1 P_BLP1Y1 P_BLP2A2 P_BLP2A3 P_BLP2A5
    P_BLP2B2 P_BLP2B5 P_BLP2C1 P_BLP2C2 P_PYCH39
    P_PYCH40 P_PYDA45 P_TXDA2 P_TXDAC6 P_TXDAC8
    P_TXDAC9 P_TXFY05 P_TXFY06
);       

# Today's date...
my $today_date = localtime;

# 24 hour before today...
my $yesterday  = $today_date - ONE_DAY;
$yesterday     = $yesterday->strftime("%Y-%m-%d %H:%M:%S");

# List all job processed overnight...
my @job_processed_overnight
    = Clink::CentrelinkDB::Client_Job->search_where(
          cj_created_datetime => { '>', $yesterday},
          cj_status           => ['processed', 'consumed'],
      );

# Grab only WA jobs from overnight files...
my @wa_overnight_files = useful_overnight_files(\@job_processed_overnight);
my $cj_job_ref_no      = q{};

# Now printout the details...
printjobs(\@wa_overnight_files);

exit 0;

######################################################################
# Helper Subroutines...
#

######################################################################
# Return only WA production files...
#
sub useful_overnight_files {
    my ($ref_job_processed) = @_;
    my @wa_overnight_files;
    my @files_processed;
    
    # Get all files received for this job...
    for my $job (@{$ref_job_processed}) {
        push @files_processed, $job->files();
    }
 
    FILE:
    for my $file ( @files_processed ) {
        # Skip test file...
        next FILE if $file->cfr_name =~ m{\A TCLK\. }xms;
    
        # Grep the jobname from the filename...
        (my $jobname 
            =  $file->cfr_name ) 
            =~ s{\A PCLK           # production file starts with a PCLK
                    [.]            # a dot
                    [A-Z][0-9]     # a capital letter and a digit
                    [.]            # a dot
                    ([^.]+)        # group everything after the dot
                    [.J] \p{Any}+  # a dot followed by "J"
                }
                {$1}xms;           # grab only the jobname
    
        # Substitute the 'Q' in QCS jobname into '_'...
        if ( substr($jobname, 1, 1) eq 'Q' ) {
            substr($jobname, 1, 1, q{_});
        }

        # Substitute "#" into "_" in the jobname...
        $jobname =~ tr{#}{_};
       
        # Skip if it's not WA job...
        next FILE if ! $wa_job_name{$jobname};
        
        # Push all relevant WA files...
        push @wa_overnight_files, $file;
    }

    return @wa_overnight_files;
}

######################################################################
# Return the time difference between WA and VIC
#
sub wa_time_difference {
    my $tz_row = Clink::CentrelinkDB::Time_Zones->retrieve('WA');
    return $tz_row->htz_time_diff();
}

######################################################################
# print to STDOUT
#
sub printjobs {
    my ($ref_jobs) = @_;
    my $image_time;
    
    for my $file ( @{$ref_jobs} ) {
        if ($file->cj_job_ref_no ne $cj_job_ref_no) {
            # print image received time for Stars...
            if ($image_time) {
                print "Image received time (WA time): $image_time\n";
            }
    
            # print dash line...
            print '-'x70 . "\n\n"; 
        }
        
        my $JSN       = $file->qcs_sequence_no;
        my $qcs_batch = $file->qcs_batch_no;
        if ( $JSN && $qcs_batch ) {
            print "Job: $qcs_batch - $JSN \n";
        }
    
        print 'File: ' 
              . $file->cfr_name 
              . ' : ' 
              . $file->cfr_created_datetime 
              . ' (EST) ' 
              . '(' 
              . $file->cfr_type 
              . ')' 
              . "\n";
        
        my $datetime = $file->cfr_created_datetime;
        $datetime   += ONE_MINUTE
                     * wa_time_difference();
        $image_time = $datetime->strftime('%d/%m/%Y %H:%M:%S');
    
        # reset the cj_job_ref_no...
        $cj_job_ref_no = $file->cj_job_ref_no;
    }
    
    # Print the image time for the last job (out of the loop above)
    if ($image_time) {
        print "Image received time (WA time): $image_time\n";
        print '-'x70 . "\n\n"; 
    }
    
}

__END__

