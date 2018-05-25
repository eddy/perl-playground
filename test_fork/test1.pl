#! /usr/bin/env perl
# When we call fork() it can return 3 different values: undef, 0, or some other number.
# 
# It will return undef if the fork did not succeed. For example because we reach the maximum number of processes in the
# operating system. In that case we don't have much to do. We might report it and we might wait a bit, but that's about
# what we can do.
# 
# If the fork() succeeds, from that point there are two processes doing the same thing. The difference is that in
# original process, that we also call parent process, the fork() call will return the process ID of the newly created
# process. In the newly created (or cloned) process, that we also call child process, fork() will return 0.
# 
# Before calling fork, we got a PID (63778), after forking we got two lines, both printed by the last line in the code.
# The first printed line came from the same process as the first print (it has the same PID), the second printed line
# came from the child process (with PID 63779). The first one received a $pid from fork containing the number of the
# child process. The second, the child process got the number 0.
#

use strict;
use warnings;
use 5.010;
 
say "PID $$";
my $pid = fork();
die if not defined $pid;
say "PID $$ ($pid)";

