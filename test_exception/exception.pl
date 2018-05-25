#!/usr/bin/env perl

use 5.12.0;
use warnings;

use Try::Tiny;
use Data::Dumper::Simple;

eval {
    die { data        => 'test data',
          application => 'my application eval',
          type        => 'Fatal',
        };     
};

if ( my $error = $@ ) {
    print Dumper $error;
    print Dumper( $error->{application} );
}

try {
    die { data        => 'test data',
          application => 'my application Try::Tiny',
          type        => 'Fatal',
        };     
}
catch {
    print Dumper $_;
    print Dumper($_->{application});
};
