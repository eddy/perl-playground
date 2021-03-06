#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments


# Implementation here

for my $func (map { split } <DATA>) {
    my $proto;
    #skip functions not in this version of Perl
    next unless eval { $proto = prototype "CORE::$func"; 1 };
    if ($proto) {
        print "$func has a prototype of $proto\n";
    } else {
        print "$func cannot be overridden\n";
    }
}

__DATA__
abs          accept         alarm          atan2            bind          
binmode      bless          break          caller           chdir
chmod        chomp          chop           chown            chr
chroot       close          closedir       connect          continue
cos          crypt          dbmclose       defined          delete
die          do             dump           each             endgrent 
endhostent   endnetent      endprotoent    endpwent         endservent
eof          eval           exec           exists           exit
exp          fcntl          fileno         flock            fork
format       formline       getc           getgrent         getgrgid
getgrnam     gethostbyaddr  gethostbyname  gethostent       getlogin
getnetbyaddr getnetbyhost   getnetent      getpeername      getpgrp
getppid      getpriority    getprotobyname getprotobynumber getprotoent
getpwent     getpwnam       getpwuid       getservbyname    getservbyport
getservent   getsockname    getsockopt     glob             gmtime
goto         grep           hex            import           index
int          ioctl          join           keys             kill
last         lc             lcfirst        length           link
listen       local          localtime      lock             log
lstat        m              map            mkdir            msgctl
msgget       msgrcv         msgsnd         my               next
no           oct            open           opendir          ord
our          pack           package        pipe             pop
pos          print          printf         prototype        push
q            qq             qr             quotemeta        qw
qx           rand           read           readdir          readline
readlink     readpipe       recv           redo             ref
rename       require        reset          return           reverse
rewinddir    rindex         rmdir          s                say
scalar       seek           seekdir        select           semctl
semget       semop          send           setgrent         sethostent
setnetent    setpgrp        setpriority    setprotoent      setpwent
setservent   setsockopt     shift          shmctl           shmget
shmread      shmwrite       shutdown       sin              sleep
socket       socketpair     sort           splice           split
sprintf      sqrt           srand          stat             state
study        sub            substr         symlink          syscall
sysopen      sysread        sysseek        system           syswrite
tell         telldir        tie            tied             time
times        tr             truncate       uc               ucfirst
umask        undef          unlink         unpack           unshift
untie        use            utime          values           vec
wait         waitpid        wantarray      warn             write
y            -r             -w             -x               -o
-R           -W             -X             -O               -e
-z           -s             -f             -d               -l
-p           -S             -b             -c               -t
-u           -g             -k             -T               -B
-M           -A             -C
