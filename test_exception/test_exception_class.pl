#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Exception::Class (
    'X',
    'X::HTTP'     => { isa => 'X' },
    'X::Parse'    => { isa => 'X' },
    'X::File'     => {
        isa     => 'X',
        fields  => [qw(file)],
    },
);

sub test {
    open my $fip, '<', '/tmp/blah.txt';
}

$SIG{__DIE__} = sub {
    X->throw( join ' ',@_ );    
};

eval {
    test();
#     X::Parse->throw("Error thrown");
    die "famous last words";  
};

if ( my $e = X->caught('X::Parse') ) {
    warn  "Exception! ". $e->message . "\n";
    exit 1;
}
else {
    $e = X->caught();
    ref $e ? $e->rethrow : die $@;
}

print "everything went OK!\n";


