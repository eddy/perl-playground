#!/usr/bin/perl

use strict;
use warnings;

my $ok = eval {
    my $trigger = RunAtBlockEnd->new(
        sub { warn "Exiting block!\n" },
    );

    die "Something important!\n";
    1;
};

if( $@ ) {
    warn "eval failed ($@)\n";
} 
elsif( $ok ) {
    warn "eval succeeded\n";
} 
else {
    warn "eval failed but \$@ was empty!\n";
}

# package...
{
    package RunAtBlockEnd;

    sub new { bless \$_[-1], $_[0] }

    sub DESTROY {
        my $self = shift @_;

        eval { ${$self}->(); 1 }
             or  warn "RunAtBlockEnd failed: $@\n";
    }
}

exit 0;

__END__

The moral message: Use eval correctly!

Some of the code in the eval created an object that had a DESTROY handler, and
it threw an exception without first localizing $@. This clobbered the real
exception, so by the time the eval block was exited, $@ was empty. 

Ugh!  Be careful, now, to make sure my *own* DESTROY methods localize $@,
because they can be invoked when I least expect it.

Or... use Devel::EvalError
----------------------------------------------------------------------


my $r = eval { 
            ...; 
            1;      # Note this trailing '1' in eval block
        };

my $error = $@;

# $error //= 'unknown error' if not $r;
if (! $r) {
    $error = defined $error ? $error : q{unknown error}
}

if ($error) { ... }


More talk on exception handling:
  http://domm.plix.at/talks/2008_vienna_die_perl_die/

