#!/usr/bin/perl

use strict;
use warnings;

package FileSet;

use DBI;

sub build {
  # Connect to database
  my $dbh = DBI->connect('dbi:Oracle:clink', 'clink', 'clink07');
  
  END { $dbh->disconnect; }
  
  # SQL statements
  my $VERSAMARK_SQL_SET   = q{ ('BLP1C1', 'BLP1J1', 'BLP1P1') };
  my $REVIEWFORMS_SQL_SET = q{ ('BLP1X1', 'BLP1X3', 'BLP2B3', 'BLP2B7', 'BLP2B8', 'BLP2B9') };
  
  my $JOB_QUERY           = q{ select cj.cj_job_ref_no,
                                      cj.hb_ref_no,
                                      cj.cj_status
                               from client_job cj join
                                    client_application ca
                                    on (cj.ca_job_id = ca.ca_job_id)
                               where 
                                     ca.ca_job_name in XXXSETXXX
                                 and cj.cj_created_datetime >= to_date('2006-12-10T18:00:00','YYYY-MM-DD"T"HH24:MI:SS')
                                 and cj.cj_created_datetime <= to_date('2006-12-15T09:00:00','YYYY-MM-DD"T"HH24:MI:SS')
                               order by cj.cj_created_datetime
                             };
  
  my $FILE_QUERY          = q{ select cfr.cfr_name
                               from client_file_receipt cfr
                               where cfr.cj_job_ref_no = ?
                             };
  
  # Get job list for versamark and review forms
  my %jobs = ( versamark    => {},
               review_forms => {},
             );
  
  my $versamark_job_query = $JOB_QUERY;
  $versamark_job_query =~ s/XXXSETXXX/$VERSAMARK_SQL_SET/;
  my $sth = $dbh->prepare($versamark_job_query);
  $sth->execute();
  map { $jobs{versamark}->{$_->[0]} = {};
        $jobs{versamark}->{$_->[0]}->{batch} = $_->[1];
        $jobs{versamark}->{$_->[0]}->{status} = $_->[2];
  
      } @{ $sth->fetchall_arrayref() };
  
  my $reviewforms_job_query = $JOB_QUERY;
  $reviewforms_job_query =~ s/XXXSETXXX/$REVIEWFORMS_SQL_SET/;
  $sth = $dbh->prepare($reviewforms_job_query);
  $sth->execute();
  map { $jobs{review_forms}->{$_->[0]} = {};
        $jobs{review_forms}->{$_->[0]}->{batch} = $_->[1];
        $jobs{review_forms}->{$_->[0]}->{status} = $_->[2];
      } @{ $sth->fetchall_arrayref() };
  
  # Build information set for each job
  for my $group_name ( keys %jobs ) {
    for my $cj_job_ref_no ( keys %{ $jobs{$group_name} } ) {
      # Build file list
      $sth = $dbh->prepare($FILE_QUERY);
      $sth->execute($cj_job_ref_no);
      map { push @{ $jobs{$group_name}->{$cj_job_ref_no}->{filelist} }, $_->[0] } @{ $sth->fetchall_arrayref() };
    }
  }

  return %jobs;
}

1;
