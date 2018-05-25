package Eddy {
    use warnings;
    use strict;
    use Carp;
    use selfvars;

    use version; our $VERSION = qv('0.0.1');

    use Class::Accessor "moose-like";

    has foo => ( is => 'rw' );

    sub testme {
        my %hash = ( one => 1, two => 2 );
        $self->foo( \%hash );

        return;
    }
}

package main {
    my $m = Eddy->new;
    $m->testme();

    use Data::Printer;
    p $m;

    p $m->foo;

    print ${$m->foo}{two} . "\n";
    print $m->foo->{two};
}

1; # Magic true value required at end of module
