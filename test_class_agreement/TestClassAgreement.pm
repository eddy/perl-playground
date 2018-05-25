package TestClassAgreement;

use strict;
use warnings;
use Class::Agreement;
use Data::Validate qw(:math :string);

sub new {
    my ($class) = @_;
    my $self    = {};

    $self->{TEST}    = "Eddy is my name";
    $self->{count}   = _calculate(20, 115);
    $self->{initial} = 11;

    return bless $self, $class;
}

sub test {
    my ($self) = @_;
    return $self->{TEST};
}

sub count {
    my ($self) = @_;
    return $self->{count};
}

sub _calculate {
    my ($one, $two) = @_;
    return $one + $two;
}   

sub addone {
    my ($self) = @_;
    return $self->{initial} += 1;
}

######################################################################
# Contract/Agreement...
# 

precondition test => sub {
    my ($self) = @_;
    return ( $self->{TEST} eq 'Eddy is my name' );
};

precondition _calculate => sub {
    my ($val1, $val2) = @_;
    return ($val1 >= 0);
};

precondition _calculate => sub {
    my ($val1, $val2) = @_;
    # return ($val2 >= 100);
    return ( is_greater_than($val2, 100) );
};

postcondition _calculate => sub {
    # return ( result == 135 );
    return ( is_equal_to(result, 135) );
};

dependent addone => sub {
    my ($self)  = @_;
    my $old_val = $self->{initial};

    return sub { $self->{initial} == $old_val + 1 };
};

######################################################################
1;


