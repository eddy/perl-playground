use 5.010;

say even_unless(3);
say even_unless(4);

say even_if(3);
say even_if(4);

sub even_if {
    my $number = shift;

    if ( !( $number % 2 ) ) {    # not good code
        return 'even';
    }
}

sub even_unless {
    my $number = shift;

    unless ( $number % 2 ) {     # not good code
        return 'even';
    }
}
