# $Id: PKI.pm,v 1.21 2006/02/17 01:41:54 eddy Exp $
# $Source: /cvs/web/referral/site_perl/S2S/Send/PKI.pm,v $
#
# This package handles all referral PKI capability
#
# $Log: PKI.pm,v $
# Revision 1.21  2006/02/17 01:41:54  eddy
# We now have all pki-services from serviceseeker, not internal s2s, so
# replace all sid with iss_sid
#
# Revision 1.20  2006/02/15 00:39:49  eddy
# Move parse_xml() out from here; it's now in S2S::Send::Format
#
# Revision 1.19  2006/01/17 08:35:03  chris
# Eddy's PKI update
#
# Revision 1.18  2006/01/17 07:08:15  chris
# save_crl(): fix error handling: '||' binds very tightly!
#
# Revision 1.17  2005/11/23 07:43:04  eddy
# Adding attachment information on sending email
#
# Revision 1.16  2005/11/22 08:57:44  eddy
# More error trapping:
# - s/croak/carp/g
# - return undef on appropriate error so the user will get system error page
#
# Revision 1.15  2005/10/18 06:26:35  eddy
# sub save_user_certificate: return 0 (instead of undef) if no cert found
#
# Revision 1.14  2005/10/18 03:37:23  eddy
# RT #32145: redirect to system_error when there's a problem on adding pki
# service
#
# Revision 1.13  2005/10/17 06:42:31  eddy
# Removed sub quoted_printable entirely and replaced with MIME::QuotedPrint
#
# Revision 1.12  2005/10/17 02:53:47  eddy
# o Now using IX::Sendmail
# o Wrap quoted-printable to 76 chars using soft-line-break ("=" equal sign)
#
# Revision 1.11  2005/10/05 05:52:37  eddy
# Added subroutine quoted_printable
#
# Revision 1.10  2005/09/13 04:22:08  eddy
# o Moved out CA path from webwrite
# o Altered PKI folder sturcture to webwrite/pki/
#
# Revision 1.9  2005/09/09 04:07:03  eddy
# o save_user_cert: return undef when ldap searching returns nothing
# o s/die/croak/g
#
# Revision 1.8  2005/09/08 07:52:24  eddy
# parse_xml(): IX::General::xmldecode($stylesheet->output_string($results);
#
# Revision 1.7  2005/09/08 06:46:53  eddy
# Reflect to D/B changes: service.emailaddress -> certificates.email
#     o s#\$certificate->{emailaddress}#\$certificate->{email}#g
#     o Added more error checking on return value
#
# Revision 1.6  2005/09/07 08:22:19  eddy
# Modified to reflect on the changes on table
#     certificates.ok -> certificates.revoked
#
# Revision 1.5  2005/09/02 07:11:57  chris
# IMPORTANT: BIG MOVE!  All packages go into the S2S:: name space.
#
# Revision 1.4  2005/08/11 02:48:34  eddy
# Fix bug: the date part of $nextUpdate is in the format of \d{1,2}
#
# Revision 1.3  2005/07/26 00:07:18  eddy
# Some more code clean up:
# o consistently use $fubar={} instead of %fubar=() then pass as reference
#   to subroutine
# o removed emailaddress from S2S::Send::PKI::get_certificate()
#
# Revision 1.2  2005/05/27 09:08:51  eddy
# o Clean up code:
#   Removed redundant use of table service_certificate. move the sid into
#   table certificates as one to one relation to cid (certificate id).
# o Don't download issuer's CRL if $nextUpdate is less then current time
#
# Revision 1.1  2005/05/12 02:08:06  eddy
# Initial entry
#

package S2S::Send::PKI;

use strict;
use warnings;
use Net::LDAP;
use IX::DB;
use IX::General(qw(carp croak));
use XML::LibXSLT;
use XML::LibXML;
use Time::Local; 
use MIME::Base64;
use MIME::QuotedPrint();

#
# Each new object holds/is a ldap connection
#
sub new($;$$)
{
	my ($that, $host, $port) = @_;
	my $class = ref($that) || $that;

	unless (defined $host && defined $port) {
		carp('No ldap server supplied');
		return undef;
	}

	#
	# we need this environment variable for openssl 
	# to supply random seed
	#
	$ENV{'RANDFILE'} = '/tmp/.openssl_random';
	
	my $this = {
		host    => $host,
		port    => $port,
		pki     => _bind($host, $port),
		openssl => _openssl(),
	};
	return undef unless $this->{pki} && $this->{openssl};
	return bless $this, $class;
}

#
# Unbind from LDAP server
#
sub DESTROY
{
	my ($this) = @_;
	return $this->{pki}->unbind() if defined $this->{pki};
}

#
# Bind to LDAP server
#
sub _bind($$)
{
	my ($host, $port) = @_;
	return undef unless (defined $host && defined $port);

	my $pki = Net::LDAP->new(
		$host,
		port    => $port,
		version => 3,
		timeout => 60,
		onerror => 'die'
	);

	unless (defined $pki) {
		carp("Could not connect to ldap server: $host:$port");
		return undef;
	}
	
	my $msg = $pki->bind();
	if ($msg->code) {
		carp('Could not bind to ldap server: ', ldap_error_name($msg));
		return undef;
	}
	
	return $pki;
}

#
# Return ldap connection
#
sub pki($)
{
	my ($this) = @_;
	return $this->{pki};
}

#
# Find executable openssl
#
sub _openssl()
{
	sub find_ssl_exe($)
	{
		my ($exe) = @_;
		my @OPENSSL_PATH = qw(/usr/bin);
		delete $ENV{'PATH'};

		foreach my $dir (@OPENSSL_PATH) {
				return "${dir}/${exe}" if -x "${dir}/${exe}";
		}
		return undef;
	}

	my $openssl = find_ssl_exe('openssl');
	unless (defined $openssl) {
		carp("Can't find executable openssl");
		return undef;
	}

	return $openssl;
}

#
# Find previously stored certificate; Return:
# 	undef: on error
# 	0 : to indicate the certificate is revoked, and need to renew
# 	1 : the certificate is still valid
#
sub get_certificate($$)
{
	my ($dbh, $iss_sid) = @_;

	unless ($iss_sid) {
		carp("Tried to call get_certificate() without a valid iss_sid");
		return undef;
  }
	
	my $sth = $dbh->select(<<END, $iss_sid);
		select cid, expiry
		from certificates
		where iss_sid = ?
		and revoked = 'f'
END

	unless ($sth) { warn('select failed'); return undef; }
	
	my ($cid, $exp) = $sth->fetchrow_array;
	return 0 unless (defined $cid && defined $exp);
	$sth->finish;
	
	my ($yy, $mm, $dd, $h, $m, $s) = $exp
			=~ m/^(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})$/;
	my $time = timegm($s, $m, $h, $dd, $mm-1, $yy-1900);

	#
	# The certificate in our database is still valid
	#
	return 1 if $time > time;
	
	#
	# Otherwise, revoke the certificate
	#
	my $autocommit = $dbh->dbh->{AutoCommit};
	$dbh->dbh->{AutoCommit} = 0;

	unless ($dbh->update({
			table    => 'certificates',
			att_list => [ qw(revoked) ],
			key_list => [ qw(cid iss_sid) ],
			fields   => {
					revoked	=> 't',
					cid => $cid,
					iss_sid => $iss_sid,
			}
	})) { carp('update table certificate failed'); goto error; }

commit:
	if ($autocommit) {
		$dbh->commit || goto error;
		$dbh->dbh->{AutoCommit} = 1;
	}
	#
	# We need to return 0 here to indicate that the certificate has been
	# revoked, thus we need to get the new one
	#
	return 0;

error:
	if ($autocommit) {
		$dbh->rollback;
		$dbh->dbh->{AutoCommit} = 1;
	}
	return undef;
}

#
# Save user certificate to a file
# Get certificate from a supplied email
#
sub save_user_certificate($$$)
{
	my ($this, $dbh, $certificate, $search_args) = @_;
	
	unless (defined $this->{pki}) {
		carp('No pki object found');
		return undef;
	}

	unless ($dbh) {
		carp('No dbh');
		return undef;
	}
	
	unless (
		$certificate 
		&& $search_args
		&& ref($certificate) eq 'HASH'
		&& ref($search_args) eq 'HASH'
	) {
		carp('Error on arguments');
		return undef;
	}
	
	($certificate->{filename} = $certificate->{email}) =~ s/\@/_at_/g;
	$certificate->{filename}  = sprintf("%s/%s.%s", 
			$certificate->{path}, $certificate->{filename}, 'der');

	#
	# Browse ldap server
	#
	# $search_args->{filter} =~ s/\@/\\@/;
	my $browse = $this->{pki}->search(
			base       => $search_args->{base},
			scope      => $search_args->{scope},
			filter     => $search_args->{filter},
			attribute  => $search_args->{attr},
			sizelimit  => 0
	);
	
	$browse->code && (carp("Error browsing LDAP: $browse->error") && return undef);
	if ($browse->count == 0) {
		carp("Searching on LDAP returns nothing");
		return undef;
	}

	#
	# Save certificate to a local file
	#
	foreach my $entry ($browse->all_entries) {
			chomp($certificate->{dn} = $entry->dn);
			foreach my $find ($entry->attributes) {
					unless (open(OUTFILE, ">$certificate->{filename}")) {
						carp 'ERROR: cannot open file $certificate->{filename}';
						return undef;
					}
					print OUTFILE $entry->get_value($find);
					unless (close OUTFILE) {
						carp "ERROR: can't close file $certificate->{filename}: $!";
						return undef;
					}
			}
	}
	
	unless (defined $certificate->{dn}) {
		carp("Can't get the value of: $certificate->{dn}");
		return undef;
	}
		
	unless ($certificate->{filename} = _cert_der2pem(
			$this, 
			$certificate->{path}, 
			$certificate->{filename}
	)) {
		carp("Error converting certificate der to pem");
		return undef;
	}
	
  unless (_db_store_certificate($this, $dbh, $certificate)) {
			carp("Error while storing userCertificate to D/B: $!");
			return undef;
	}

	$certificate->{filename} =~ s/^$certificate->{path}\///;
	return $certificate->{filename};
}

#
# Convert userCertificate from DER to PEM format
#
sub _cert_der2pem($$)
{
	my ($this, $location, $infilename) = @_;
	return undef unless (defined $this->{pki} && defined $this->{openssl});

	(my $outfilename = $infilename) =~ s/^$location//;
	$outfilename     =~ s/\.der$/\.pem/;
	$outfilename     = sprintf("%s/%s", $location, $outfilename);

	my $pipe = open(CMD, '-|');
	unless (defined $pipe) {
		carp("ERROR: can't open pipe to subprocess: $!");
		return undef;
	}

	$pipe == 0 && exec(
			$this->{openssl}, 
			'x509', 
			'-inform', 'DER', 
			'-outform', 'PEM',
			'-in', $infilename, 
			'-out', $outfilename
	);

	close CMD || ((
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")
		&& return undef
	);

	unlink $infilename if (-f $infilename);

	$outfilename =~ s#^$location\/##;
	return $outfilename;
}

#
# Verify certificate
#
sub verify($$$)
{
	my ($this, $ca_path, $crl_path, $certificate) = @_;
	return undef unless (defined $this->{pki} && defined $this->{openssl});

	unless (
		$ca_path 
		&& $crl_path 
		&& $certificate
		&& ref($certificate) eq 'HASH'
	) {
		carp('arguments error in sub verify()');
		return undef;
	}

	my $cert = sprintf("%s/%s", $certificate->{path}, $certificate->{pem});
	
	#
	# Create a hash symlink of CRL (CApath is on default openssl
	# installation, i.e. /etc/ssl/private and set on vhost)
	#
	_c_rehash($this, $crl_path)
		|| (carp('Create hash symlink failed'), return undef);

	my $pipe = open(CMD, '-|');
	unless (defined $pipe) {
			carp("can't open pipe to subprocess: $!");
			return undef;
	}

	#
	# verify againts issuer and root certificate
	#
	my $err = 0;
	$pipe == 0 && exec(
		$this->{openssl}, 
		'verify', 
		'-CApath', $ca_path, 
		$cert
	);

	while (<CMD>) {
			$err++ unless ($_ =~ m/^$cert\:\s+OK$/);
	}

	close CMD || ((
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")
		&& return undef
	);

	if ($? || $err) {
			carp("certificate not verified: $!");
			return undef;
	}
	
	return 1;
}

#
# Helper subroutine - used by sub verify
#
sub _c_rehash($$)
{
	my ($this, $crl_path) = @_;
	my %hashlist = ();
	
	return undef unless defined $this->{openssl};
	unless ($crl_path) { carp('No CRL path'); return undef; }

  opendir(DIR, $crl_path) 
		|| (carp("ERROR: open directory: exit code $?: $!"), return undef);
	my @flist = readdir(DIR);

	unless (@flist) {
		carp('readdir failed');
		return undef;
	}

  #
  # Delete any existing hash symbolic link
  #
  foreach (grep {/^[\da-f]+\.r{0,1}\d+$/} @flist) {
		if (readlink($crl_path . '/' . $_)) { 
			my $deleted = unlink $crl_path . '/' . $_;
			if ($deleted == 0) {
				carp('Delete existing hash link failed');
				return undef;
			}
		}
  }
  
	closedir(DIR) || (carp('closedir failed'), return undef);

  #
  # Check to see if certificates and/or CRLs present.
  #
  foreach (grep {/\.pem$/} @flist) {
		$this->{fname} = $_;
    my $crl = _check_file($crl_path, $this->{fname});
		
		unless (defined $crl) {
			carp('Checking CRL failed');
			return undef;
		}
		
    if ($crl == 0) {
    	carp("WARN: $this->{fname} contains no certificate nor CRL: skipping");
   		next;
    } else {
			# FIXME: 
			# No need to hash symlink the issuer/root cert as we did it
			# manually before hand on the openssl default folder i.e.
			# /etc/ssl/private
			#
			# We only need to create a hash symlink on CRL 
			#
			_link_hash_crl($this, $crl_path, \%hashlist)
				|| (carp('Create hash symlink failed'), return undef);
		}
  }

	return 1;
}

#
# Helper subroutine called within _c_rehash()
#
sub _check_file($$)
{
	my ($path, $fname)  = @_;
	my $is_crl = 0;

	open(IN, "$path/$fname") 
		|| (carp("ERROR: can't open file: $!"), return undef);

	while (<IN>) {
		if(/^[\-]+BEGIN\s+([^\-]+)/) {
		 	if ($1 eq "X509 CRL") {
		 		$is_crl = 1;
		 		last;
		 	}
		}
	}
	
	close IN || ((
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")
		&& return undef
	);

	return  $is_crl;
}

#
# Helper subroutine - called within _c_rehash()
#
sub _link_hash_crl($$$)
{
	my ($this, $crl_path, $hashlist) = @_;
	unless (defined $this->{openssl} && ref($hashlist) eq 'HASH') {
		carp("sub _link_hash_crl(): error on arguments");
		return undef;
	}

  $this->{fname} = sprintf("%s/%s", $crl_path, $this->{fname});
  $this->{fname} =~ s/'/'\\''/g;

  my $pipe = open(OPENSSL, '-|');
  unless (defined $pipe) {
  	carp("ERROR: can't open pipe to subprocess: $!");
		return undef;
	}

  $pipe == 0 && exec(
		$this->{openssl}, 
		'crl', 
		'-md5',
		'-hash', 
		'-fingerprint',
		'-in', $this->{fname}
	);

  my ($hash, $fprint);
	my $count = 0;

  while (<OPENSSL>) {
		$count++ if /BEGIN X509 CRL/;
		next if $count;
		if (m/^MD5\s+Fingerprint\=(.*)/) {
			($fprint = $1) =~ tr/://d;
		} else {
			chomp($hash = $_);
		}
  }

	close OPENSSL || ((
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")
		&& return undef
	);

	unless ($hash && $fprint) {
		carp('Create hash symlink failed');
		return undef;
	}

  #
  # Search for an unused hash filename
  #
  my $suffix = 0;

	while(exists $hashlist->{"$hash.r$suffix"}) {
		#
		# Hash matches: if fingerprint matches its a duplicate cert
		#
		if($hashlist->{"$hash.r$suffix"} eq $fprint) {
			carp "WARNING: Skipping duplicate CRL $this->{fname}\n";
			return 1;
		}
		$suffix++;
	}

  $hash .= ".r$suffix";
 	unless(symlink $this->{fname}, "$crl_path/$hash") {
		carp('Create hash symlink failed');
		return undef;
	}

  $hashlist->{$hash} = $fprint;
	return 1;
}

#
# Format message to s/mime and send it
#
sub smime($$$$)
{
	my ($this, $certificate, $message, $admin) = @_;
	return undef unless (defined $this->{openssl} && defined $this->{pki});
	
	unless (
		$certificate
		&& ref($certificate) eq 'HASH'
		&& $message
	) {
		carp('sub smime(): invalid arguments'); 
		return undef;
	}
	
	(my $encrypted_file  = $message) =~ s#\.clear$#\.enc#;
	$certificate->{pem} = sprintf("%s/%s", $certificate->{path}, $certificate->{pem});
	
	#
	# Untaint email address
	#
	unless ($certificate->{email}	=~ m/^([[:print:]]{1,128})$/) {
		carp("$certificate->{email}: email too long");
		return undef;
	}
	$certificate->{email} =~ s/"/'/g;
	$certificate->{email} =~ s/\<\>/[]/g;
	
	#
	# Create s/mime message with DES3 encryption
	#
	my $pipe = open(SMIME, '-|');
	unless (defined $pipe) {
		carp("ERROR: can't open pipe to subprocess: $!");
		return undef;
	}

	$pipe == 0 && exec(
		$this->{openssl}, 
		'smime', 
		'-encrypt', 
		'-des3',
		'-in', $message,
		'-out', $encrypted_file,
		$certificate->{pem}
	);
	
	close SMIME || ((
		carp $! ? "Error closing smime pipe: $!" : "Exit status $? from smime")
		&& return undef
	);

	#
	# Now send the real s/mime referral
	#
	open(FOP, $encrypted_file) || (carp("can't open file: $!") && return undef);
	my @email_contents = <FOP>;
	close FOP || (carp("can't close file: $!") && return undef);
	my $blob = join('', @email_contents);
	
	require IX::Sendmail;
	IX::Sendmail::sendmail({
		env => {
			'from'    => 'pki-referral@infoxchange.net.au',
		},
		headers => {
			'To'      => $certificate->{email},
			'From'    => '"IX Referral System" <pki-referral@infoxchange.net.au>',
			'Subject' => 'Referral PKI Testing',
		},
		text => $blob,
	}) || return undef;
	
	unlink $encrypted_file if (-f $encrypted_file);
	return 1;
}

#
# Store new certificate to database
#
sub _db_store_certificate($$)
{
	my ($this, $dbh, $certificate) = @_;
	return undef unless (defined $this->{pki} && defined $this->{openssl});

	unless ($dbh) {
		carp('No dbh');
		return undef;
	}

	unless (exists $certificate->{email} && $certificate->{email}) {
			carp("Try to store certificate without a valid email");
			return undef;
	}

	$certificate->{filename} = sprintf("%s/%s", 
			$certificate->{path}, $certificate->{filename});

	my $pipe = open(OPENSSL, '-|');
	unless (defined $pipe) {
		carp("ERROR: can't open pipe to subprocess: $!");
		return undef;
	}
	
	$pipe == 0 && exec(
			$this->{openssl}, 
			'x509', 
			'-noout', 
			'-enddate',
			'-serial', 
			'-in', $certificate->{filename}
	);

	while (<OPENSSL>) {
		$certificate->{expiry} = $1 if /^notAfter=(.*)$/;
		$certificate->{serial} = $1 if /^serial=(.*)$/;
	}

	close OPENSSL || ((
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")
		&& return undef
	);

  my $sth = $dbh->select(<<END, $certificate->{iss_sid});
			select count(*) 
			from certificates 
			where iss_sid = ? 
			and revoked = 'f'
END

	unless ($sth) {
		carp('select failed');
		return undef;
	}

	$sth->execute() || (carp('execute sql failed'), return undef);
	my ($count) = $sth->fetchrow_array();
	$sth->finish;
	defined $count || (carp("select failed") && return undef);

	my $autocommit = $dbh->dbh->{AutoCommit};
	$dbh->dbh->{AutoCommit} = 0;

	if ($count) {
		carp("Trying to insert duplicated email, that email exists and is not revoked yet");
		return undef;
	}

	unless ($dbh->insert({
		table   => 'certificates',
		fields  => {
			iss_sid => $certificate->{iss_sid},
			serial => $certificate->{serial},
			expiry => $certificate->{expiry},
			email  => $certificate->{email},
		},
	})) { carp('ERROR: insert to table certificates failed'); goto error; }

commit:
	if ($autocommit) {
		$dbh->commit || goto error;
		$dbh->dbh->{AutoCommit} = 1;
	}
	return 1;

error:
	if ($autocommit) {
		$dbh->rollback;
		$dbh->dbh->{AutoCommit} = 1;
	}
	return undef;
}

#
# Get issuer's CRL
#
sub save_crl($$$)
{
	my ($this, $location, $search_args) = @_;
	return undef unless (defined $this->{pki} && defined $this->{openssl});

	my $month = {
			Jan => '01', Feb => '02', Mar => '03', Apr => '04', May	=> '05',
			Jun => '06', Jul => '07', Aug => '08', Sep => '09', Oct => '10',
			Nov => '11', Dec => '12'
	};

	my %fields;
	map { $fields{$_} = $search_args->{$_}} keys %{$search_args};
	
	# while(my($k,$v) = each %fields){warn("\t$k => $v $/");}
	(my $outfile = $fields{filter}) =~ s/\s+//g;
	$outfile     =~ s/^.*=//;
	my $curfile  = sprintf("%s/%s\_%s.%s", $location, $outfile, 'crl', 'pem');
	$outfile     = sprintf("%s/%s\_%s.%s", $location, $outfile, 'crl', 'der');

	#
	# Check CRL expiry date
	#
	if (-f $curfile) {
			my $nextUpdate;
			my $sleep_count = 0;
			my $pid;

			do {
				$pid = open(OPENSSL, "-|");
				unless (defined $pid) {
					carp("cannot fork openssl: $!");
					croak("bailing out") if $sleep_count++ > 6;
					sleep 10;
				}
			} until defined $pid;

			$pid == 0 && exec(
				$this->{openssl}, 
				'crl', 
				'-nextupdate', 
				'-in', $curfile
			);
			
			while(<OPENSSL>) {
				next unless /^nextUpdate.*GMT$/;
				($nextUpdate = $_) =~ s/^nextUpdate=(.*)$/$1/;
			}
			
			close	OPENSSL || (
				(  	
					carp $! ? "Error closing openssl pipe: $!"
						: "Exit status $? from openssl"
				)  	
				&& return undef
			);   	
			       	
			unless (
				$nextUpdate =~ m#^(\w+)\s+(\d{1,2})\s+(\d{2}):(\d{2}):(\d{2})\s+(\d{4})\s+GMT$#
			) {
				carp('Error finding nextUpdate status on the current CRL');
				return undef;
			}

			my ($mm, $dd, $h, $m, $s, $yy) = $nextUpdate
					=~ m#^(\w+)\s+(\d{1,2})\s+(\d{2}):(\d{2}):(\d{2})\s+(\d{4})\s+GMT$#;
			$nextUpdate = timegm($s, $m, $h, $dd, $month->{$mm}-1, $yy-1900);
			return 1 if ($nextUpdate > time);
	}
	
	#
	# we need to add this * to ensure we get the whole CRL,
	# i.e. not only the first line of it from the ldap server
	#
	($fields{filter} .= '*') =~ s/\@/\\@/;

	my $browse = $this->{pki}->search(
			base       => $fields{base},
			scope      => $fields{scope},
			filter     => $fields{filter},
			attribute  => $fields{attr},
			sizelimit  => 0
	);
	
	if ($browse->code) {
			carp $browse->error;
			return undef;
	}

	#
	# Save CRL to a local file
	#
	my $dn = qw{};
	foreach my $entry ($browse->all_entries) {
			chomp($dn = $entry->dn);
			foreach my $find ($entry->attributes) {
					open(OUTFILE, ">$outfile") 
						|| (carp("ERROR: can't open file $outfile: $!") && return undef);
					print OUTFILE $entry->get_value($find);
					close OUTFILE 
						|| (carp("ERROR: can't close file $outfile: $!") && return undef);
			}
	}

	#
	# Convert into PEM then unlink its DER counterpart
	#
	(my $outfilename = $outfile) =~ s/\.der$/\.pem/;
	my $pipe = open(CMD, '-|');
	unless (defined $pipe) {
		carp("Can't pipe openssl: $!");
		return undef;
	}

	$pipe == 0 && exec(
		$this->{openssl}, 
		'crl',
		'-inform', 'DER',
		'-outform', 'PEM',
		'-in', $outfile,
		'-out', $outfilename
	);
	
	close	CMD || ((  	
		carp $! ? "Error closing openssl pipe: $!" : "Exit status $? from openssl")  	
		&& return undef
	);   	

	if ($?) {
		carp("ERROR: failed formatting CRL to PEM");
		unlink $outfile if (-f $outfile);
		return undef;
	}

	unlink $outfile if (-f $outfile);
	return 1;
}

#
# Compose clear text email (with attachment)
#
sub compose_email($$$$;$$)
{
	my ($dbh, $docid, $body, $is_attachment, $filename, $base) = @_;	
	
	unless (defined $dbh) {
		carp('No dbh found: ' . __PACKAGE__);
		return undef;
	}
	
	unless (@_ >= 4) {
		carp('Error on arguments: ' . __PACKAGE__);
		return undef;
	}
	
	$base = defined $base ? ('http://' . $base . '/') : ' ';
	
	#
	# If $filename (contains print.html) exists we want to sent it,
	# otherwise $body will contain our XML data
	#
	my $type = 'text/plain';
	if (-e $filename) {
		$type = 'text/html';
		open(FOP, $filename) || (carp("can't open file: $!") && return undef);
		my @email_contents = <FOP>;
		close FOP || (carp("can't close file: $!") && return undef);
		$body = join(' ', @email_contents);
	}

	#
	# Fix encoding for quoted-printable
	#
	$body =	MIME::QuotedPrint::encode($body);

	open(OF, ">$filename") 
		|| (carp("can't open file to write: $!") && return undef);

	if ($is_attachment) {
			my $boundary = sprintf("_%04x%04x.%04x%04x:%04x%04x",
												rand(65535), rand(65535),
												rand(65535), rand(65535),
												rand(65535), rand(65535)
			);

			print OF <<END;
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"$boundary\"
MIME encoding and base64 data starts here

--$boundary
MIME-Version: 1.0
Content-Type: $type; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Base: $base
Content-Location: $base

$body
END
			my $sth = $dbh->select(<<EDB, $docid);
						select filename, type, attachment
						from attachment
						join only referral_attachment using(seq)
						where docid = ?
EDB

			unless ($sth) {
				carp('select failed');
				return undef;
			}
			
			while (my ($fname, $type, $attachment) = $sth->fetchrow_array) {
				$attachment = encode_base64($attachment);
				print OF <<EOF
--$boundary
Content-Type: $type; name="$fname"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="$fname"

$attachment
EOF
			} # end of while
						
			print OF "--$boundary--";
			close OF || (carp("can't close file: $!") && return undef);
			$sth->finish;
	} # end of if ($is_attachment)
  else {
		print OF <<END;
MIME-Version: 1.0
Content-Type: $type; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Base: $base
Content-Location: $base

$body		
END
		close OF || (carp("can't close file: $!") && return undef);
	}

	return 1;
}


######################################################################
1;

__END__

=pod
=head1 NAME

S2S::Send::PKI - handles PKI email for referral

=head1 SYNOPSIS

S2S::Send::PKI used by referral system to send a secure S/MIME email 
to external serviceseeker services.

	my $pki = new S2S::Send::PKI($ldap_host, $ldap_port)
		|| return undef;

=head1 EXPORTS

Nothing

=head1 DESCRIPTION

Act as a base class to manage all PKI capabilities, i.e. get certificate
from LDAP directory, verify certificates, compose email and send it as
S/MIME.


=head1 METHODS

=head2 Setup

	use S2S::Send::PKI
	my $pki = new S2S::Send::PKI($ldap_host, $ldap_port)
		|| return undef;

The constructor (subroutine new) takes 2 arguments: the certificate LDAP
server and its port number.

=head2 Save CRL (Certificate Revocation List)

This is used to get the CRL from HESA LDAP server. It will check for the
expiration date of the current CRL first and get the newer one if
necessary. This CRL will be saved in the first argument of the function,
e.g. in /webwrite/pki/crl/ directory.

	$pki->save_crl(
		'/webwrite/pki/crl',
		{
			base	 => 'c=au',
			scope  => 'sub',
			filter => 'cn=SecureNet Health OCA',
			attr   => 'certificateRevocationList',
		}
	) || return undef;


=head2 Get certificate 

This is used to get a service's certificate from our own internal
database. The certificate is added to the database from the ixadmin
menu. It takes 2 argumentrs: the dbh and service's iss_sid.

	my $result = S2S::Send::PKI::get_certificate(
		$this->dbh,
		$receive_iss_sid,
	);
	
	unless (defined $result) {
		...error message...
	}
	
Its return value can be either:

=over

=item - 0:
When the certificate is invalid/revoked and needs to be renewed

=item - 1:
The certificate in our database is still valid

=item - undef:
When an error occurs during calling this function

=back

=head2 Save certificate

It's used to save a service's certificate when the current one in our
own database is revoked (checked by get_certificate() above). It grabs 
the newest certificate from HESA LDAP server and store the details in
our own database; The "actual" certificate will be saved in 
/webwrite/pki/cert/ directory. Returning the correct certificate
in PEM format (see openssl man page).

	if (defined $result) {
		unless ($result) {
			my $certificate_pem = $pki->save_user_certificate(
				$dbh,
				$certificate_filename,
				{
					base   => 'c=au',
					scope  => 'sub',
					filter => 'mail=pki-referral@infoxchange.net.au',
					attr   => 'userCertificate',
				}
			) || return undef;
		}
	}

=head2 Verify certificate

Sub verify() is used to verify a service's certificate againsts the
current CRL and CA (Certificate Authority) from HESA LDAP server.
The CA is normally stored under /etc/ssl/private/ and the certificate
_has_ to be in PEM format (see Save certificate above).

	unless ($pki->verify(
		$CA_path,
		$CRL_path,
		$certificate_pem
	)) {
		...error message...
	}

=head2 Compose email

It is used to compose email in mime quoted-printable format.

	S2S::Send::PKI::compose_email(
		$this->dbh,
		$this->docid,
		$xml_data,
		$is_attachment,
		$cleartext
	) || return undef;

It takes several arguments:

=over
=item - $this->dbh

I think it's clear anough.

=item - $this->docid

The document docid that is going to be sent

=item - $xml_data

This is the xml data of the current docid; So it consists of the xml
tags, etc:

=back

	<xml>
		<referral create_sid=......>
		....
		<ini ....>
			.....
		</ini>
		</referral>
	</xml>

=over

=item - $is_attachment

Set to "1" if the docid has any attachment and "0" otherwise.

=item - $cleartext

This is where we're going to save the final clear text message of the 
email going to be sent.

=back

=head2 Send S/MIME message

	$pki->($certificate, $cleartext) || return undef;

It sends an encrypted S/MIME email. It takes 2 arguments, i.e. the
certificate of the receipient and the clear text message.

=cut


