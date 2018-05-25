#!/usr/bin/perl -w

use strict;

use Net::Time qw(inet_time);
use Time::Piece;
use Time::Seconds;
use File::Basename;
use File::Copy;
use XML::Simple;
use Data::Dumper;

use Clink::CentrelinkDB;
use Clink::InFile;
use HPA::LockProcess;
use HPA::Carp;
use HPA::MQFTP::Send;

my $now = localtime();
my $xml_filename = '/cmsdata/prod/client/data/mips_stars/clink.starsactuals.20060814.132352.xml';

my $batch_send = $now->strftime('%Y%m%d').$now->strftime('%H%M%S');
my %config = (
  job_name     => 'MQFTP_SEND',
  file_list    => [ $xml_filename ],
  batch_no     => $batch_send,
  server       => 'cldomino'
);

my $mqs = HPA::MQFTP::Send->new(%config);
$mqs->send() or die(
    "Failed to create barr distribution for file $xml_filename  Reason: ".$mqs->error_str() 
);
 
