#!/usr/bin/env perl
use v5.14;
use warnings;

package BrokenModule;
{
    sub broken_print_eddy {
        say "Not Eddy!\n";
        return;
    }
}

package main;
{
    BrokenModule::broken_print_eddy();    # print "Not Eddy"

    {
        no warnings 'redefine';
        local *BrokenModule::broken_print_eddy = sub {
            say "This is Eddy";
            return;
        };

        BrokenModule::broken_print_eddy();    # print "This is Eddy"
    }
    
    BrokenModule::broken_print_eddy();    # print "Not Eddy"

    exit 0;
}


