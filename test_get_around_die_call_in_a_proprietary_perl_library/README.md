From: http://stackoverflow.com/questions/451227/how-can-i-get-around-a-die-call-in-a-perl-library-i-cant-modify
---------------------------------------------------------------------------------------------------------------

* Use eval block

  Usually we can trap any exception raised using an eval block as:

     # warn if routine calls die
     eval { routine_might_die }; warn $@ if $@;

  However if somebody has trapped $SIG{__DIE__} from within a proprietary module that we can't modify, a simple eval
  will NOT work because the DIE handler will be invoked first. Thus the next method comes in handy...

*  Does the module traps $SIG{__DIE__}? If it does, then it's more local than you are. But there are a couple
   strategies:

   - You can evoke its package and override die:

     package Library::Dumb::Dyer;
     use subs 'die';
     sub die {
         my ( $package, $file, $line ) = caller();
         unless ( $decider->decide( $file, $package, $line ) eq 'DUMB' ) {
             say "It's a good death.";
             die @_;
        }
     }


   - If not, can trap it. (look for $SIG on the page, markdown is not handling the full link.)

     my $old_die_handler = $SIG{__DIE__};
     sub _death_handler {
         my ( $package, $file, $line ) = caller();
         unless ( $decider->decide( $file, $package, $line ) eq 'DUMB DIE' ) {
             say "It's a good death.";
             goto &$old_die_handler;
         }
     }

     local $SIG{__DIE__} = \&_death_handler;

   - You might have to scan the library, find a sub that it always calls, and use that to load your $SIG handler by overriding that.

     my $dumb_package_do_something_dumb = \&Dumb::do_something_dumb;
     *Dumb::do_something_dumb = sub {
         $SIG{__DIE__} = ...
         goto &$dumb_package_do_something_dumb;
     };

   - Or override a builtin that it always calls...

     package Dumb;
     use subs 'chdir';
     sub chdir {
         $SIG{__DIE__} = ...
         CORE::chdir @_;
     };

   - If all else fails, you can whip the horse's eyes with this:

     package CORE::GLOBAL;
     use subs 'die';
     sub die {
         ...
         CORE::die @_;
     }

   - from Brian D Foy - you can always override subroutines in other packages. You don't change the original source at all.

     BEGIN {
           use Original::Lib;
           no warnings 'redefine';

           sub Original::Lib::some_sub { ... }
     }


