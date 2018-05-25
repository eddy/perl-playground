#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;

use Test::More tests => 1;

#
# Modern Perl Blog: use_ok() is Broken Because require() is Broken
# 
# Ovid's post on avoiding Test::More's use_ok() is good advice. There's almost
# no reason to use use_ok() from Test::More in existing code. It probably
# doesn't do what you think it does, and it doesn't really help against most of
# the failures you probably care about.
#
# TO REPLACE:
# -----------
#
# use Test::More tests => 5;
# 
# BEGIN {
#   use_ok( 'Test::Trap::Builder::TempFile' );
#   use_ok( 'Test::Trap::Builder::SystemSafe' );
# SKIP: {
#     skip 'Lacking PerlIO', 1 unless eval "use PerlIO; 1";
#     use_ok( 'Test::Trap::Builder::PerlIO' );
#   }
#   use_ok( 'Test::Trap::Builder' );
#   use_ok( 'Test::Trap' ) or BAIL_OUT( "Nothing to test without the Test::Trap class" );    
# }
# 
# diag( "Testing Test::Trap $Test::Trap::VERSION, Perl $], $^X" );
#
# USE THIS INSTEAD:
# -----------------
#

my $ok;
END { BAIL_OUT "Could not load all modules" unless $ok }

#
# known module name
#
use Test::Trap::Builder::TempFile;                                                                                                            
use Test::Trap::Builder::SystemSafe;
use Test::Trap::Builder;
use Test::Trap;
use if eval "use PerlIO; 1", 'Test::Trap::Builder::PerlIO';

#
# dynamically test module name
#
my $module = 'IO::File';
eval "use $module; 1"
  or BAIL_OUT $@ // "Zombie error";

#
# do nothing, just reporting when it reaches this point
#
ok 1, 'All modules loaded successfully';
$ok = 1;

exit 0;

