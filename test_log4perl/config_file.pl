#!/usr/bin/env perl

use strict;
use warnings;
use Log::Log4perl;

#
# Note: please notice the content difference between eat1.conf and eat2.conf
#
# Log::Log4perl->init("eat.conf");
Log::Log4perl->init("eat2.conf");

my $food_logger = Log::Log4perl::get_logger("Groceries::Food");
my $root_logger = Log::Log4perl::get_logger();

$food_logger->error("Test me error");
$food_logger->fatal("Test me fatal");
$root_logger->fatal("This is root");

my $unknown = '';
$food_logger->debug("Is this causing crappy lines? : ", $unknown);

exit 0;


