#!/usr/bin/env perl

use common::sense;



my $stream;
{
    my $previous = 0;
    $stream = sub { $previous++ };
}

my $limited_stream;
{
    my $previous = 0;
    $limited_stream = sub { return $previous if $previous++ < 10; return; };
}

my $limited_even_stream;
{
    my $previous = 0;
    $limited_even_stream = sub { return $previous if(($previous+=2) <= 10); return; };
}

sub say_numbers_in_stream
{
    my $stream = shift;
    while ( defined (my $val = $stream->() ) )
    {
        say "Weve reached number $val!";
    }
}


say_numbers_in_stream($limited_stream);
say_numbers_in_stream($limited_even_stream);
