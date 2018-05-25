package Animal;
use Moose;
has 'name'  => (is => 'rw');
has 'color' => (is => 'rw');

sub speak {
  my $self = shift;
  print $self->name, " goes ", $self->sound, "\n";
}

sub sound { 
    confess shift, " should have defined sound!"
}

1;

######################################################################
# Horse is a sub-class of Animal
#
package Horse;
use Moose;
extends 'Animal';
sub sound { "neigh" }
1;


