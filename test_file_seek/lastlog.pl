#!/opt/perl/bin/perl

#
# Usage: $ ./lastlog.pl et6339
#

use common::sense;
use Fcntl ':seek';

my $user = shift;
my ( $time, $tty, $host ) = get_lastlog_info($user);

if ( defined $time ) {
    print "$user on $tty from $host\n\tat ", scalar( localtime $time ), "\n";
}
else {
    print "$user never logged in\n";
}

exit 0;

sub get_lastlog_info {
    my $user = shift;

    $user = getpwnam($user) if $user =~ /\D/;
    return unless defined $user;

    open L, "<", "/var/log/lastlog" or return;
    seek L, 292 * $user, SEEK_SET;
    return unless read( L, my $buf, 292 ) == 292;

    my ( $time, $tty, $host ) = unpack "i a32 a256", $buf;
    return $time ? ( $time, $tty, $host ) : ();
}

