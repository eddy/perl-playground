#! /usr/bin/env perl

use v5.14;
use warnings;

my $result = eval {
    eval {
        my $file = "/etc/passwd";

        eval {
            # start here
            open my $fh, '>', $file or die { errno => $! };
        };

        if ( defined $@ and length $@ ) {
            use Storable qw(dclone);
            my $error = dclone($@);
            @{$error}{qw( user file mode time )} = ( scalar getpwuid($<), $file, ( stat $file )[2], time, );

            die $error;    # first catch
        }
    };

    if ( defined $@ and length $@ ) {
        die;               # second catch
    }
};

if ( defined $@ and length $@ ) {
    use Data::Dumper;
    print "I got " . Dumper($@) . "\n";    # finally
}

