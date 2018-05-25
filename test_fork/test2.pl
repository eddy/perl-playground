#!/usr/bin/env perl

# In the child process $pid will be 0, and so not $pid will be true. The child process will execute the block of the
# if-statement and will exit at the end.
# 
# In the parent process $pid will contain the process id of the child which is a non-negative number and thus not $pid
# will be false. The parent process will skip the block of the if-statement and will execute the code after it. At one
# point the parent process will call wait(), that will only return after the child process exits.
# 
# There is also a variable called $name that had a value assigned before forking. If you look at the output below, you
# will see that the variable $name kept its value in both the parent and the child process after the fork, but we could
# change it in both processes independently.
#
# The above code also has two calls to sleep commented out. They are there so you can enable each one of them separately
# to observe two things:
# 
# If the sleep is enabled in the child process (inside the if block) then the parent will arrive to the wait call much
# sooner than the child finishes. You will see it really waits there and the last print line from the parent will only
# appear after the child process finished.
# 
# On the other hand, if you enable the sleep in the parent process only, then the child will exit long before the parent
# reaches the call to wait. So when the parent finally calls wait, it will return immediately and return the process id
# of the child that has finished earlier.
# 
# This is important, as this means the signal that the parent process received marking the end of the child process has
# also waited for the parent to "collect" it. This will be especially important in the next example, where we create
# several child processes and we want to make sure we wait for all of them.

use strict;
use warnings;
use 5.010;
 
my $name = 'Foo';
 
say "PID $$";
my $pid = fork();
die if not defined $pid;
if (not $pid) {
   say "In child  ($name) - PID $$ ($pid)";
   $name = 'Qux';
   # sleep 2;
   say "In child  ($name) - PID $$ ($pid)";
   exit;
}
 
say "In parent ($name) - PID $$ ($pid)";
$name = 'Bar';
# sleep 2;
say "In parent ($name) - PID $$ ($pid)";
 
my $finished = wait();
say "In parent ($name) - PID $$ finished $finished";

