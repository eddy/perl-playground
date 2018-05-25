#!/usr/bin/env perl

use strict;
use warnings;
use Test::More 'no_plan'; # I'm lazy.
use Test::Exception;

use_ok 'MyClass';

use MyBar;

{
    # ideal case
    my $bar = MyBar->new;
    my $c;
    lives_ok { $c = MyClass->new( bar => $bar ) };
        

    isa_ok $c, 'MyClass', '$c';
    isa_ok $c->bar, 'MyBar', '$c->bar';
}

{
    # not a bar
    my $bar = 42;
    throws_ok 
        { MyClass->new( bar => $bar ) }
        qr/bar must be a MyBar/;

}

# test for bar == ref but not blessed
# test for bar blessed, but not isa My::Bar
# test get
# test set (like above, but for bar insead of new)

