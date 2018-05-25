#! /usr/bin/env perl

# we create several child processes and we want to make sure we wait for all of them.
#
# In the $fork variable we count how many times we managed to fork successfully. Normally it is the same number as we
# wanted to fork, but in case one of the forks is not successful we don't want to wait for too many child processes.
# 
# As the child processes exit, each one of them sends a signal to the parent. These signals wait in a queue (handled by
# the operating system) and the call to wait() will return then next item from that queue. IF the queue is empty it will
# wait for a new signal to arrive. So in the last part of the code we call wait exactly the same time as the number of
# successful forks.
# 
# In the for loop, we called fork $n times. In the part of the parent process (in the if-block), we just counted the
# forks. In the child process (in the else-block) we are supposed to do the real work. Here replaced by a call to sleep.


use strict;
use warnings;
use 5.010;
 
say "Process ID: $$";
 
 
my $n = 3;
my $forks = 0;
for (1 .. $n) {
  my $pid = fork;
  if (not defined $pid) {
     warn 'Could not fork';
     next;
  }
  if ($pid) {
    $forks++;
    say "In the parent process PID ($$), Child pid: $pid Num of fork child processes: $forks";
  } else {
    say "In the child process PID ($$)"; 
    sleep 2;
    say "Child ($$) exiting";
    exit;
  }
}
 
for (1 .. $forks) {
   my $pid = wait();
   say "Parent saw $pid exiting";
}
say "Parent ($$) ending";
