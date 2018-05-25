######################################################################
# $Id: Sendmail.pm,v 1.8 2004/06/17 00:02:15 danial Exp $
# $Source: /cvs/web/perl/IX/Sendmail.pm,v $
#
# Send an email
#
# Note: whilst this stuff has something to do with
# apache/mod_perl, it should be fine to run outside of
# apache/mod_perl.
#
# We jump through hoops (creating a child process which
# disassociates itself from us before piping into sendmail) to
# make sure the sendmail process gets the full email.  Without
# doing this, we've seen the situation where we get killed by an
# apache reload or restart after starting the sendmail but
# before piping the message into it.  When that happens sendmail
# will complain about "no recipients" and somebody will get odd
# looking bounce messages, and somebody else will have to waste
# time trying to work out what went wrong.  So we try to do it
# right, even though it's a "once in a blue moon" thing.
#
#
# ...then again, rather than the child needing to be
# disassociated from the parent, extensive testing suggests it
# may be sufficient to simply fork twice to prevent sendmail
# getting an empty message, because it looks like the children
# of this process don't get killed when we get killed (i.e. the
# signal doesn't propagate to the childern).  I.e.  this:
#
#   apache/mod_perl
#          |
#        fork ----------+
#          |            |
#          |           exec
#          |            |
#         pipe >>>>> sendmail
#          |            |
#          |           exit
#          |
#      continues...
#
# causes the error when the apache/mod_perl process is killed
# after the fork but before the pipe output, because sendmail
# doesn't receive any input from the pipe.  However this:
#
#   apache/mod_perl
#          |
#        fork ---+
#          |     |
#          |   fork ----------+
#          |     |            |
#          |     |           exec
#          |     |            |
#          |    pipe >>>>> sendmail
#          |     |            |
#          |    exit         exit
#          |
#      continues...
#
# seems to be ok because whilst the parent apache/mod_perl
# may be killed, the child continues to pipe the input to
# sendmail.
#
# But we'll do disassociation stuff anyway, seeing as I've
# already put it in...
#
# $Log: Sendmail.pm,v $
# Revision 1.8  2004/06/17 00:02:15  danial
# Remove duplicate @sendmail_opts declaration.
# Environment variable for from field still applies to non-hash arg calls.
#
# Revision 1.7  2004/05/12 02:00:05  chris
# Allow for hash ref as argument, to allow more flexibility with envelope,
# headers, text, attachments etc.  And hey, it's even got pod docs!
#
# Revision 1.6  2004/05/12 00:54:29  chris
# Change $ENV{IX_Sendmail_Envelope} to $ENV{IX_Sendmail_Envelope_From} to
# be more explicit about which part of the envelope it's setting.
#
# Revision 1.5  2004/05/11 23:34:10  danial
# Restore the environment before we leave.
#
# Revision 1.4  2004/05/07 13:04:45  danial
# Allow for an envelope address to be used.
#
# Revision 1.3  2004/05/07 06:01:39  danial
# %ENV is possible tainted, and we don't need it anyway.
#
# Revision 1.2  2004/04/29 02:13:00  danial
# Try and find the true executable rather than assuming it is in /bin, as
# Apple OS X doesn't believe in putting things in /bin.
#
# Revision 1.1  2004/04/27 06:28:54  chris
# New
#
######################################################################
package IX::Sendmail;

######################################################################
use strict;
use POSIX 'setsid';
require Exporter;

use vars qw(@ISA @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT_OK = qw(
	sendmail
);


######################################################################
# Function to send an email. The headers should be part of the
# message passed in.
#
sub sendmail($)
{
	my ($arg) = @_;

	my $message;
	my %env;
	my @to;
	my @sendmail_opts = ('-oi');

	#
	# For testing... the child will need our pid
	#
	# my $parent_pid = $$;
	#

	if (ref($arg) eq 'HASH') {
		#
		# Message
		#
		if (exists $arg->{full_message} && defined $arg->{full_message}) {
			if (exists $arg->{text} || exists $arg->{headers}) {
				warn("bad args to sendmail: full_message + text||headers");
				return 0;
			}
			$message = $arg->{full_message};
		}

		if (exists $arg->{headers}) {
			$message = join("\n",
				map { "$_: $arg->{headers}->{$_}" } keys %{$arg->{headers}},
			);
		}

		if (exists $arg->{text}) {
			$message .= "\n" . $arg->{text};
		}

		#
		# Envelope
		#
		if (exists $arg->{env}) {
			my $env = $arg->{env};

			#
			# Arguments override environment
			#
			if (exists $env->{from} && length $env->{from}) {
				push(@sendmail_opts, '-f', $env->{from});
			}
			elsif (exists $ENV{IX_Sendmail_Envelope_From}
				&& $ENV{IX_Sendmail_Envelope_From} =~ /^(.+\@.+\..+)$/
			) {
				push(@sendmail_opts, '-f', $1);
			}

			if (exists $env->{to}) {
				if (ref($env->{to}) eq '') {
					push(@to, $env->{to});
				}
				elsif (ref($env->{to}) eq 'ARRAY') {
					push(@to, @{$env->{to}});
				}
			}
		}
	}
	else {
		#
		# Simple arg: complete email message including headers
		#
		$message = $arg;

		#
		# Envelope from field in environment still applies here
		#
		if (exists $ENV{IX_Sendmail_Envelope_From}
			&& $ENV{IX_Sendmail_Envelope_From} =~ /^(.+\@.+\..+)$/
		) {
			push(@sendmail_opts, '-f', $1);
		}
	}

	if (@to) {
		push(@sendmail_opts, @to);
	}
	else {
		#
		# Possibly expensive check, but it's worth it because it's a real
		# pain in the arse trying to track down "no recipients in message"
		# bounces from sendmail
		#
		unless ($message =~ /^To: .+/m) {
			warn("sendmail: no recipients in message!");
			return 0;
		}
		push(@sendmail_opts, '-t');
	}

	###################
	#
	# OK, that's our argument handling, now to the guts of sending...
	#
	# Start a child process to handle sending the email
	#
  my $sleep_count = 0;
	my $pid;
	do {
		$pid = fork();
		unless (defined $pid) {
			warn("cannot fork: $!");
			die("bailing out") if $sleep_count++ > 6;
		}
	} until defined $pid;


	if ($pid == 0) {
		#
		# We're the child: disassociate ourselves so we don't get
		# killed by the parent.  See perlipc.
		#
		chdir '/' || die "Can't chdir to /: $!";
		open(STDIN, '/dev/null') || die "Can't read /dev/null: $!";
		open(STDOUT, '>/dev/null') || die "Can't write /dev/null: $!";
		setsid() || die "Can't start new session: $!";
		#
		# If we dup STDERR per perlipc, error messages disappear
		# into the never-never.
		#
		# open(STDERR, '>&STDOUT') || die "Can't dup stdout: $!";

		#
		# Remove possible tainted variables
		#
		%ENV = ( );

		#
		# Start up sendmail
		#
		$sleep_count = 0;
		do {
			$pid = open(SENDMAIL, "|-");
			unless (defined $pid) {
				warn("cannot fork: $!");
				die("bailing out") if $sleep_count++ > 6;
				sleep 10;
			}
		} until defined $pid;

		$pid == 0 && exec '/usr/sbin/sendmail', @sendmail_opts;

		#
		# For testing... kill our own parent
		#
		# sleep 2; warn("$$: killing $parent_pid");
		# kill 15, $parent_pid;
		# sleep 2; warn("$$: killed $parent_pid");
		#

		#
		# send the message to sendmail
		#
		print SENDMAIL $message || die("Write sendmail failed: $!");
		close SENDMAIL || die("Close sendmail failed: exit code $?: $!");

		#
		# return success: if we just "exit(0)" we end up as just
		# another apache process... mod_perl must be trapping the
		# exit.  So we resort to trickery...
		#
		my $true;
		foreach (qw(/bin/true /usr/bin/true)) {
			$true = $_ if -x $_;
		}
		die 'No true executable' unless defined $true;
		exec($true);
	}

	#
	# We're the parent: wait for our disassociated child to exit,
	# and return success or error
	#
	waitpid($pid, 0);

	return $? ? 0 : 1;
}

######################################################################
1;
__END__

=head1 NAME

IX::Sendmail - send emails

=head1 SYNOPSIS

use IX::Sendmail;

$ENV{IX_Sendmail_Envelope_From} = $env_from;

my $result = IX::Sendmail::sendmail($full_message};

my $result = IX::Sendmail::sendmail({
	[ full_message => $full_message, ]
	[ text => $text,
	[ attach => $attach,
	[ headers => {
			'From'    => $from,
			'To'      => $to,
			'Subject' => $subject,
			...etc.
		}, ]
	[ env => {
			[ from => $env_from, ]
			[ to => $env_to, ]
		}, ]
}};

=head1 DETAILS

=head2 Parameters

=over 4

=item $full_message

The full message including headers.

=item $text

Message text excluding headers.

=item $attach

A non-functional place holder for the moment.  The idea would be to
allow the caller to specify attachments in various ways e.g.:

	attach => [
		{
			# attach from a file
			filename => $filename,
			'mime-type' => $mime_type,
		},
		{
			# attach from a passed-in scalar
			filename => $filename,
			'mime-type' => $mime_type,
			body => $attachment_body
		},
	],

=item $headers

A reference to a hash containing arbitrary message headers.

=item $env_from

The envelope "from" address.  Errors and bounces etc. will be returned
to this address.  If this parameter is not supplied the envelope will
typically be the web server, which means the webmaster is likely to get
all your bounces.  This is generally a bad idea.

=item $env_to

The envelope "to" address[es].  You can use a scalar for a single
address e.g.:

	to => 'foo@foo.bar',

Or you can use a reference to an array for multiple addresses e.g.:

	to => [ qw(foo@foo.bar bar@bar.foo baz@foo.bar) ],

If this parameter is not supplied the "to" address[es] will be taken
from the "From" header, which must be supplied either in $full_text or
using the $headers hash.

=item $ENV{IX_Sendmail_Envelope_From}

The default envelope "from" address, overridden by the arguments if
supplied.

=back
