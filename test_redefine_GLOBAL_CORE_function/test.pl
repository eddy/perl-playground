#! /usr/bin/env perl

use v5.14;
use warnings;

#
# NOTE: BEGIN block must be the first one in the package if we want to 
# modify the default exit() inside our own package MYMAIN
#
BEGIN {
    say "di sini";
    *CORE::GLOBAL::exit = sub {
        print "inside modified CORE::GLOBAL::exit @_ \n";
        0;
    };
    say 'selesai di sini';
}

use IPC::Run3;
use Try::Tiny;
use lib '.';
use MYMAIN;

#
# NOTE: use this "use subs" if we want to modify exit only locally within 
# this package
#
# use subs 'exit';
# 
# sub exit(;$) {
#     my $val = shift;
#     say "inside modified CORE::GLOBAL::exit : $val";
# 
#     CORE::exit $val;
# };


exit(2);

try {
    say "inside try block";
    # run_command( './main.pl' );
    MYMAIN::main();
}
catch {
    say "inside catch block";
    print $_;
    die "end of catch block -------\n";
};

say "finish ok";


################################################################################
sub run_command
{
   my ($command,$dieWoutRpt) = @_;
   my ($result,$errMsg);

   say($command."...");
   run3($command,undef,\$result,\$errMsg,{return_if_system_error => 1});

   if ($? == -1) {
      $errMsg = "failed to execute command: $command\nReason: $!" ;
   } elsif ($? & 127) {
      $errMsg = sprintf("command died with signal %d, %s coredump: $command\n Error Message: %s",
         ($? & 127),  ($? & 128) ? 'with' : 'without',$errMsg);
   } elsif ($? >> 8) {
      $errMsg = "command: $command died with return code ".($? >> 8)."\nError Message: ".$errMsg;
   }
   if ($errMsg) {
      die($errMsg) if ($dieWoutRpt);
      die($errMsg);
   }
  return $result;
}


