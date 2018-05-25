#!/usr/bin/perl

use strict;
use warnings;

use Scope::Guard;
use Data::Dumper;

my $e = while_error({ error => 'Connection refused' });
print 'return code: '. Dumper $e;
print "\n";

$e =  while_error({ error => 'unknown local index' });
print 'return code: ' . Dumper $e;
print "\n";

$e =  while_error({ error => 'no error!' });
print 'return code: ' . Dumper $e;
print "\n";


sub while_error {
    my ( $ret ) = @_;
    
    print '@_ : ' . Dumper $ret;    

    my $use_db = { use_db_please => 1 };

    my $sg = Scope::Guard->new( sub {
        print STDERR "$ret->{error} : THROW BY Scope::Guard\n";
    } );

    # 1, connection to {localhost}:{3312} failed: Connection refused
    if ($ret->{error} =~ /Connection refused/is) {
        print "in 1st if\n"; 
        return $use_db;
    }
    # 2, received zero-sized searchd response
    elsif ($ret->{error} =~ /zero-sized searchd/) {
        print "in 2nd if\n"; 
        return $use_db;
    }
    # 3, unknown local index
    elsif ( $ret->{error} =~ /unknown local index/ ) {
        print "in 3rd if\n"; 
        return $use_db;
    }
    # 4, recv: Connection reset by peer
    elsif ( $ret->{error} =~ /Connection reset by peer/ ) {
        print "in 4th if\n"; 
        return $use_db;
    }
    
    print "Ahoy there... before calling dismiss()\n";

    $sg->dismiss();
    
    print "Ahoy there... end of the sub\n";

    return $ret;
}
