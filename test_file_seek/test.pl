use common::sense;

use Fcntl qw(:seek);

while (<DATA>) {
    my $pos = tell DATA;
    print $pos . "-------\n";
    
    print $_;
}

exit 0;

sub find {
    my ($fh, $key) = @_;

    seek $fh, 0, SEEK_SET;
    my $pos = 0;

    while (<$fh>) {
        chomp;

        if ( index($_, $key) == 0 ) {
            seek $fh, $pos, SEEK_SET;
            return $_;
        }

        $pos = tell $fh;
    }
    return;
}


__DATA__
eddy001
thanh002
greg003
