#
# You can create an array of all the objects and then weaken those references so
# that the object will still be cleaned up upon going out of scope.  You then want
# to make sure that you handle holes in your array.  For example:

# Weak.pm
package Weak;
use strict;
use warnings;
use Scalar::Util qw(weaken);

my @all_objects;

sub new {
        my ($class, $name) = @_;

        my $self = { name => $name };
        $self = bless $self, $class;

        # Add reference to object to array
        push @all_objects, $self;

        # Weaken reference so that it doesn't count for garbage
        # collection
        weaken $all_objects[-1];

        return $self;
}

sub update_all {
        my ($class, @args) = @_;

        foreach my $self (@all_objects) {
            # Skip if it's empty or looks funny
            next unless ($self and ref $self eq $class);
            print $self->{name}, "\n";
        }
}

1;

######################################################################

# Test script
package main;
use strict;

my $object1 = Weak->new("obj1");
my $object2 = Weak->new("obj2");

{
    # Object 3 is only in this scope
    my $object3 = Weak->new("obj3");

    # Should print out 1 - 3.
    Weak->update_all();
}

# One last object
my $object4 = Weak->new("obj4");

print "\n\n";
Weak->update_all();


__END__

obj1
obj2
obj3


obj1
obj2
obj4

