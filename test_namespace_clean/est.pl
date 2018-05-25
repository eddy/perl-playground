#!/opt/perl/bin/perl

use common::sense;
use Bar;

Bar::barrr();

# this should fail with namespace::autoclean in Bar.pm, work otherwise.
Bar::yell();    

exit 0;

