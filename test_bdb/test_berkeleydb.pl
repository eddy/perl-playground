#!/opt/perl/bin/perl

use common::sense;
use AnyDBM_File;
use Fcntl ':seek', 'O_RDWR', 'O_CREAT';

# Use BerkeleyDB, create a file called pw_aux
tie my %password, 'AnyDBM_File', "./pw_aux", O_CREAT|O_RDWR, 0666
    or die $!;

# Open password file
open PASSWD, "<", "/etc/passwd" or die $!;

# Make index (run only once, until the password file changes again)
make_index( \*PASSWD, \%password, 
            sub { (split /:/, $_[0], 2)[0] },
          );

# Find a username very quick
print find( \*PASSWD, \%password, "et6339" );
print find( \*PASSWD, \%password, "www-data" );
print find( \*PASSWD, \%password, "invalid_user" );
print find( \*PASSWD, \%password, "news" );

exit 0;


sub make_index {
    my ( $fh, $dbm, $key_function ) = @_;

    seek $fh, 0, SEEK_SET;
    %$dbm   = (); 
    my $pos = 0;

    while (<$fh>) {
        chomp;
        my $key      = $key_function->($_);
        $dbm->{$key} = $pos;
        $pos         = tell $fh;
    }
}

sub find {
    my ( $fh, $dbm, $key ) = @_;

    return "User not found: $key\n" unless $dbm->{$key};

    my $offset = $dbm->{$key};
    seek $fh, $offset, SEEK_SET;
    my $rec = <$fh>;

    return $rec;
}

