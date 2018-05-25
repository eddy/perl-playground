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

# Today's date...
my $today_date = localtime;

# 24 hour before today...
my $yesterday  = $today_date - (ONE_DAY * 2);
$yesterday     = $yesterday->strftime("%Y-%m-%d %H:%M:%S");

my $now        = $today_date - ONE_DAY;
$now           = $now->strftime("%Y-%m-%d %H:%M:%S");

# List all job processed overnight...
my @job_processed_overnight
    = Clink::CentrelinkDB::Client_Job->search_where(
          cj_created_datetime => { -between => [$yesterday, $now]},
          cj_status           => ['archived', 'processed', 'consumed'],
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
        my $form_id   = $file->qcs_form_id;
        if ( $JSN && $qcs_batch ) {
            print "Job: $form_id - $qcs_batch - $JSN \n";
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

