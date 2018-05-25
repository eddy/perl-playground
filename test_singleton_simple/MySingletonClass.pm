package MySingletonClass;

use warnings;
use strict;
use Moose;

#
# Just a quick note: if you plan to use MooseX::Singleton, beware ! It is easy to use and it implements properly what
# it claims, however it is QUITE SLOW. 
#
# If my profilings are corrects, each call to ->instance() calls meta(), get_metaclass_by_name() one time, and blessed()
# two times.
#

use version; our $VERSION = qv('0.0.1');

my $singleton;

sub instance {
    return $singleton //= __PACKAGE__->new();
}

# to protect against people using new() instead of instance()
around 'new' => sub {
    my $orig = shift;
    my $self = shift;
    return $singleton //= $self->$orig(@_);
};

sub initialize {
    defined $singleton
      and croak __PACKAGE__ . ' singleton has already been instanciated'; 
    shift;
    return __PACKAGE__->new(@_);
}


1; # Magic true value required at end of module
