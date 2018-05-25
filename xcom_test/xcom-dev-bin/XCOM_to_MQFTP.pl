#!/usr/local/bin/perl
#$Id: XCOM_to_MQFTP.pl,v 1.1 2006/08/08 02:31:05 et6339 Exp $
#$Source: /cvsroot/centrelink.solution/bin/XCOM_to_MQFTP.pl,v $
#$Revision: 1.1 $
#$Date: 2006/08/08 02:31:05 $

use strict;
use warnings;

################################################################################
# Modules
#
use Getopt::Long;
use Pod::Usage;
use Carp;
use Fatal qw( open close );
use Time::Local;
use Net::SMTP;
use File::Copy;
use Fcntl qw(:DEFAULT :flock);

################################################################################
# Configuration
#

# Static configuration (as required by usage these may become command-line
# parameters at some stage)

# Concurrent process threshold
my $MAX_PROCESSES   = 4;

# Processing age threshold (in minutes) - used to detect hung processes
my $MAX_PROCESS_AGE = 60;

# XCOM output spool (files are picked up from here)
my $XCOM_SPOOL_DIR  = "C:\\XCOM_TO_MQFTP_SPOOL";
my $SENDING_DIR     = "${XCOM_SPOOL_DIR}\\sending";
my $ERROR_DIR       = "${XCOM_SPOOL_DIR}\\error";
my $ARCHIVE_DIR     = "${XCOM_SPOOL_DIR}\\archive";
my $LOG_DIR         = "${XCOM_SPOOL_DIR}\\log";

# Log files
(my $timenow = _datefmt(time)) =~
    s/^(\d{2})\/(\d{2})\/(\d{4})\s+.*$/$3$2$1/;
my $PROCESS_LOG     = $LOG_DIR . "\\process.log";
my $CRON_LOG        = $LOG_DIR . "\\xcom_to_mqftp.log_" . $timenow;

# MQFTP send script
my $MQFTP_SEND      = "C:\\Xcomnt\\mqftp.pl";
my $PERL            = "C:\\Perl\\bin\\perl.exe";

# SMTP server to use in XCOM box 
my $MAIL_SERVER     = '10.6.250.2'; # mail.act.hpa
my $MAIL_FROM       = 'CentrelinkVICITSupport@hpa.com.au';
my @MAIL_RCPT       = qw( CentrelinkVICITSupport@hpa.com.au
                          Eddy.Tan@hpa.com.au
                          Bradley.Dean@hpa.com.au
                      );

# Set appropropriate new line
my $newline         = $^O =~ /^MSWin\d\d$/ ? "\r\n" : "\n";

# Command-line parameters
my $opt_help        = 0;
my $opt_man         = 0;

my %getopt_long_config = (
    'man'          => \$opt_man,
    'help|?'       => \$opt_help,
    );

######################################################################
# Function definition
#
sub transfer_files 
{
    # Command-line parameters
    GetOptions( %getopt_long_config ) || pod2usage(-verbose => 0);
    pod2usage(-verbose => 1) if ($opt_help);
    pod2usage(-verbose => 2) if ($opt_man);

    # Verify that required directories and scripts exist
    unless (-d $XCOM_SPOOL_DIR && -d $SENDING_DIR 
            && -d $ERROR_DIR   && -d $ARCHIVE_DIR 
            && -d $LOG_DIR
    ) {
        croak(<<END);
FATAL: Cannot find some or all of the following directories:
    $XCOM_SPOOL_DIR
    $SENDING_DIR
    $ERROR_DIR
    $ARCHIVE_DIR
    $LOG_DIR 
END
    }

    #Verify that mqftp_send and perl are ready
    croak "FATAL: Cannot find mqftp send script: $MQFTP_SEND"
        unless (-e $MQFTP_SEND && -e $PERL);
    
    # log a "START PROCESS" here
    _log('----- START PROCESS -----');

    # Check the number of processes running at this time
    # If there are processes running, also check if they have hung
    my @running_processes = _find_running_processes();

    for my $process ( @running_processes ) {
        if ( $process->{age} >= $MAX_PROCESS_AGE ) {
            _maillogdie("Hung process detected: $process->{file}");
        }
    }

    # Abort if there are too many processes running
    if ( scalar( @running_processes ) >= $MAX_PROCESSES ) {
        _logdie("Too many processes running, terminating");
    }

    # Check for files ready to transfer in the XCOM output spool
    # Abort if there are no files to send
    my $filename = _spool_file_for_sending();
    unless (defined $filename) {
        _log("No file ready to transfer");
        goto FINISH;
    }

    # MQFTP send the file from the sending directory
    my $return_code = _mqftp_send($filename);
    
    # If the MQFTP send was successful move the file into the archive
    # directory and log success
    if ( defined $return_code && $return_code == 0 ) {
        # Remove the id/file from the process log
        my @running_process = _find_running_processes();
        _remove_process(\@running_process, $filename);

        # Move file from sending directory to archive
        move("$SENDING_DIR\\$filename", $ARCHIVE_DIR)
        or _maillogdie("Cannot move file: $filename to archive directory: $!");
        
        # Log success
        _log("MQFTP succeed sending: $filename");
    }
    # If the MQFTP send failed, move the file into the error directory
    # and report incident
    else {
        # Move file from sending directory to error
        move("$SENDING_DIR\\$filename", $ERROR_DIR)
        or _maillogdie("Cannot move file: $filename to error directory: $!");

        # Remove the process from log to avoid hung process
        my @running_process = _find_running_processes();
        _remove_process(\@running_process, $filename);

        # Log error and terminate
        _maillogdie("MQFTP send failed on file: $filename");
    }

    FINISH:
    _log('----- FINISH -----');
    return;
}

######################################################################
# Return a list of hashes describing other current running XCOM_to_MQFTP.pl
# processes
sub _find_running_processes {
    my @process  = ();
    my $cur_proc = {};

    # file does not exist, return empty array to indicate new process
    return @process unless -e $PROCESS_LOG;
    open(FOP, $PROCESS_LOG)
        or die "Cannot open process log file: $!";

    while (<FOP>) {
        chomp;
        next if /^\s*$/;
        if (/^id\s*=\s*(\d{1})$/) {
            $cur_proc = {};
            # Note: we push the reference of $cur_proc into an array 
            push @process, $cur_proc;
            $cur_proc->{id} = $1;
        }
        elsif (/^file\s*=\s*(.*)$/) {
            $cur_proc->{file} = $1;
        }
        elsif (/^start\s*=\s*(.*)$/) {
            $cur_proc->{start} = $1;
        }

        if ($cur_proc->{start}) {
            $cur_proc->{age} = _diff_date(time - _epoch($cur_proc->{start}));
        }    
    }
    close(FOP);
    return @process;
}

######################################################################
# Check xcom spool for ready file, if one is found move it to the
# sending directory to avoid collision (and return the name of the file).
# If no ready file is found, croak with "No files to send"
sub _spool_file_for_sending 
{
    opendir(DH, $XCOM_SPOOL_DIR) 
    or _logdie("Couldn't open $XCOM_SPOOL_DIR for reading: $!");

    #
    # Grab all files in the C:\XCOM_to_MQFTP_SPOOL
    # Return undef value to the caller on empty dir
    #
    my @files = ();
    while ( defined (my $file = readdir(DH)) ) {
        next if $file =~ /^\.\.?$/;
        next if $file =~ /^(sending|error|archive|log)$/;
        my $filename = "$XCOM_SPOOL_DIR\\$file";
        push(@files, $filename) if -e $filename;
    }
    return undef unless scalar @files;
    closedir(DH)
    or _logdie("Couldn't close directory: $XCOM_SPOOL_DIR: $!");

    # Files found, sorted by timestamp, oldest first
    my @sorted = map { $_->[0] }
                 sort { $b->[1] <=> $a->[1] }
                 map { [ $_, -M $_ ] }
                 @files;

    # Check sending directory for duplicate file.
    # If there's any, just logdie to avoid the previous file being
    # overridden
    opendir(SEND, $SENDING_DIR)
    or _logdie("Couldn't open $SENDING_DIR for reading: $!");
    (my $sendfile = $sorted[0]) =~ s!.*\\!!;
    while (defined (my $file = readdir(SEND)) ) {
        next if $file =~ /^\.\.?$/;
        next if $file =~ /^(sending|error|archive|log)$/;
        _logdie("Trying to move duplicate file: $file to $SENDING_DIR") 
            if $file eq $sendfile;
    }
    closedir(SEND);
    
    # Update the process log file...
    # We need to call _find_running_processes() again in here rather than
    # pass it as an argument cos we need to have the latest logs
    my @running_process = _find_running_processes();
    _add_process(\@running_process, $sendfile);

    # Move one oldest file to the sending directory
    move($sorted[0], $SENDING_DIR) 
    or _logdie("Cannot move file: $sorted[0] to sending directory: $!");

    # Return the filename to the caller
    return $sendfile;
}

######################################################################
# Attept to MQFTP send the file
# The file should be found in the sending directory
sub _mqftp_send {
    my $filename = shift;
    $filename = "$SENDING_DIR\\$filename";
    my $ret = system (
	    $PERL, $MQFTP_SEND, '-v',
	    '-s', '3',
	    '-d', 'E',
	    '-r', '/cmsdata/prod/hpa/bin/mqftp_rc.pl',
	    '-f', $filename
    );    
    # Return the return code of the script
    return $ret;
}

######################################################################
sub _remove_process
{
    my ($running_process, $filename) = @_;
    open(PROCESS, "> $PROCESS_LOG") or die("Cannot open process log file: $!");
    flock(PROCESS, LOCK_EX);
    seek(PROCESS, 0, 2) or die("Cannot seek proess log file: $!");
    my $count = 1;
    for my $process (@{$running_process}) {
        unless ($process->{file} eq $filename) {
            print PROCESS <<"END";
id    = $count
file  = $process->{file}
start = $process->{start}

END
        }
        $count++;
    }
    close(PROCESS);
}

######################################################################
sub _add_process
{
    my ($running_process, $filename) = @_;

    # Write to process log, with this format:
    #   id    = 1
    #   file  = PCLK.S1.A#BLP1J1.J10977.CO.FGSIM.D0000114
    #   start = 01/08/2006 17:00:00
    my $count = scalar(@{$running_process}) + 1;
    my $startdate = _datefmt(time);
    open(PROCESS, ">> $PROCESS_LOG") or die("Cannot open process log file: $!");
    flock(PROCESS, LOCK_EX);
    seek(PROCESS, 0, 2) or die("Cannot seek proess log file: $!");
    print PROCESS <<"END";
id    = $count
file  = $filename
start = $startdate

END
    close(PROCESS);
}


######################################################################
# Write a log message
sub _log 
{
    my ($error_msg, $package, $line) = @_;
    $error_msg ||= 'Unknown error';
    ($package, my $filename, $line) = caller unless ($package && $line);
    open(LOG, ">> $CRON_LOG") || die "Failed to open $CRON_LOG: $!";
    $error_msg = _datefmt(time) 
               . ' [' . $package . ' at line: ' . $line . '] '
               . $error_msg
               . $newline;
    print LOG $error_msg;
    close(LOG) or die "Failed to close $CRON_LOG:$!";
}

######################################################################
# Write message to log file and croak
sub _logdie 
{
    my $error_msg = shift || 'Unknown error';
    my ($package, $filename, $line) = caller;
    _log($error_msg, $package, $line);
    croak "Calling _lodie() at: $package, line: $line";
}

######################################################################
# Mail and log this message and croak
# Shamelessly stolen from C:\XCOMNT\smtp_newfiles.pl
sub _maillogdie {
    my $error_msg = shift || 'Unknown error';
    my ($package, $filename, $line) = caller;
    _log($error_msg, $package, $line);

    # timestamp now...
    my $timestamp = _datefmt(time);
    
    # open and validate smtp connection...
    my $smtp = Net::SMTP->new($MAIL_SERVER);
    unless (defined $smtp
       and $smtp->mail($MAIL_FROM)
       and $smtp->to(@MAIL_RCPT)
       and $smtp->data()
    ) {
        _log("SMTP failed for $MAIL_SERVER: $!");
        $smtp->quit() if $smtp;
        return 0;
    }
    # send email...
    $smtp->datasend("To: $_ $newline") for @MAIL_RCPT;
    $smtp->datasend("From: $MAIL_FROM $newline");
    $smtp->datasend("Subject: Error Report from XCOM_to_MQFTP.pl at XCOM box"
                     . $timestamp
                     . $newline
                   );
    $smtp->datasend($newline);
    # Compose body of the email...
    my $body = qq{
XCOM_to_MQFTP at XCOM box recorded the following error:\n
        Timestamp: $timestamp
        Caller   : $package
        Line     : $line
        Error    : $error_msg
    };
    
    $smtp->datasend($body);
    $smtp->dataend();
    $smtp->quit();
    croak "Calling _maillogdie() at: $package, line: $line";
}

######################################################################
# Convert epoch seconds into DD/MM/YY hh:mi:ss with hour in 24H format
#
sub _datefmt
{
    my ($s, $min, $h, $d, $mon, $y) = localtime($_[0]);
    ++$mon; $y += 1900;
    sprintf('%02d/%02d/%04d %02d:%02d:%02d', $d, $mon, $y, $h, $min, $s);
}

######################################################################
# Convert date format DD/MM/YY hh::mi:ss into epoch seconds
#
sub _epoch
{
    my ($dd, $mm, $yy, $hh, $mi, $ss) = (
        $_[0] =~  m!(\d{2})\/(\d{2})\/(\d{4})\s+(\d{2}):(\d{2}):(\d{2})!
    );
    return timelocal($ss, $mi, $hh, $dd, $mm-1, $yy-1900);
}

######################################################################
# Return epoch seconds difference in readable minutes format
#
sub _diff_date
{
    my $diff = shift;
    my ($ss, $mi, $hh, $dd);

    $ss   = $diff % 60;
    $diff = int(($diff - $ss) / 60);
    $mi   = $diff % 60;
    $diff = int(($diff - $mi) / 60);
    $hh   = $diff % 24;
    $diff = int(($diff - $hh) / 24);
    $dd   = $diff % 7;

    # Convert into minutes format
    return ($dd * 24 * 60) + ($hh * 60) + $mi + ($ss / 60);
}


######################################################################
# Main program
#
transfer_files();
exit 0;

######################################################################
# POD
#
__END__
=head1 NAME
 
XCOM_to_MQFTP.pl - XCOM to MQFTP file transfer
 
=head1 VERSION
 
$Id: XCOM_to_MQFTP.pl,v 1.1 2006/08/08 02:31:05 et6339 Exp $
 
=head1 USAGE
 
Common usage:

 # Scheduled calls to script (once every 1/5/10 minutes) to transfer
 # files successfully received via XCOM through to the next server via
 # MQFTP.
 * * * * * /path/to/XCOM_to_MQFTP.pl

Or the equivalent in the microsoft windows task scheduler.

 
=head1 OPTIONS
 
 -h | --help        brief help message
 -m | --man         full documentation

=head1 DESCRIPTION
 
This script takes file received via XCOM and deposited in the XCOM output
spool directory (this will be done in the Xcompp.bat script) and transfers
those files onto the Centrelink Processing server via MQFTP.

The script self-limits itself to a certain number of concurrent processes to
avoid overloading the server with the expensive MQFTP send calls (which use
7zip to compress the data being sent).

The script also checks the currently running processes to make sure they
have not hung.

The MQFTP send process is tested for success.

Any failures are reported via email alerts.

All actions and errors are logged.
 
=head1 DIAGNOSTICS
 
=over 4

=item Too many processes running, terminating

There are already the maximim number of allowable concurrent processes
running.

The script will terminate without looking for any files.

=item Hung process detected

A (possibly) hung process has been detected (ie a very old transfer
process).

An error will be logged and an incident email sent.

=item MQFTP send failed

An error has been detected sending a file by MQFTP.

The file will be moved (if possible) into the error directory.

An error will be logged and an incident email sent.

=item No files to send

No files were found to send.

The process will abort.

=item Unexpected Error: <blah blah blah>

An unexpected error was detected.

An error will be logged and an incident email sent.

=back

 
=head1 CONFIGURATION AND ENVIRONMENT

The expected location of the XCOM spool directory and the MQFTP send script
is defined in the configuration section of this script.

=head1 DEPENDENCIES

There are no known dependacies for this application. 

 
=head1 INCOMPATIBILITIES
 
There are no known incompatibilities with this application. 


=head1 BUGS AND LIMITATIONS
 
There are no known bugs in this application. 

Please report problems to Centrelink Vic IT Support
(<centrelinkvicit@hpa.com.au>)
 

=head1 AUTHOR
 
Bradley Dean <bradley.dean@hpa.com.au>

Eddy Tan <eddy.tan@hpa.com.au>

Centrelink Vic IT Support <centrelinkvicit@hpa.com.au>


=head1 LICENCE AND COPYRIGHT
 
Copyright (c) 2006 HPA Australia. All rights reserved.

