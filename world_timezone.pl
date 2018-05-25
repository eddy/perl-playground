#!/usr/bin/env perl

use warnings;
use strict;
use DateTime;
use Text::Table;

my $tb = Text::Table->new("TIMEZONE", "\t", "LOCALTIME");

print $tb->load(
    map { [ $_->time_zone->name, "\t", $_->strftime("%F %T %Z") ] }
    map { DateTime->now->set_time_zone($_) }
    qw{
        Europe/London
        Asia/Jakarta
        America/Los_Angeles
        US/Pacific
        America/New_York
        Australia/Melbourne
        Australia/Adelaide
        Australia/Perth
        Australia/Sydney
        Australia/Brisbane
    }
);


exit 0;

