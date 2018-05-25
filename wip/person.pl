#!/usr/bin/perl -w
use strict;

#
# The initialization and setters worked OK, and then salute() worked as expected.
# When we tried to trick the object with another method, by adding to the supposed
# table of methods, it didn't work, because we explicitely know which attributes
# we manage (in the normal approach, you can never know). This approach makes
# lifes easier to maintain (just add a new attribute to the array!) and allows us
# to be very paranoid about access... and by being a lexical, only the code inside
# the scope of @attributes can change it, but it never does, and so you cannot
# trick the object. Of course, there's always a way, you can work on perl guts and
# add a new attribute to the *attributes table, maybe.
#

package Person;
use Carp;
use Data::Dumper;
{
   my @attributes = (qw/NAME AGE/);

   sub new
   {
      my $class = shift;
      confess("new() called not from a Class constructor")
        if ref($class);

      my %self = map { $_ => undef } @attributes;
      my $access = sub
      {
         my ($name, $arg) = @_;
         croak "Method '$name' unknown for class Person"
            unless exists $self{$name};
         $arg and $self{$name} = $arg;
         return $self{$name};
      };

      #### convenience methods are denied here...
      print Dumper(\%self);
      for my $method ( keys %self )
      {
         no strict 'refs';
         *$method = sub {
            my $self = shift;
            $access->( $method, @_ ); };

      }

      bless $access, $class;
      return $access;
   }
}

sub salute
{
   my $self = shift;
   print "Hello, I'm ",
         $self->NAME,
         " and I'm ", 
         $self->AGE, "!\n";
}          


package main;

my $person = Person->new();
# nice interface
$person->NAME( 'John Doe' );
$person->AGE( 23 );
$person->salute;
# this also works, of course
$person->('AGE', 24);
$person->salute;

# this doesn't
$person->('TOES', 12);

exit 0;
