package MyClass;
use strict;
use warnings;
use MyBar;
use Carp;
use Scalar::Util qw(blessed);

sub new { 
    my ($class, %args) = @_; # crappy error message if %args is odd

    croak 'bar must be a MyBar' 
        unless blessed $args{bar} && $args{bar}->isa('MyBar');

    my $self = { bar => $args{bra} };  # NOTE!!!: typo here undetected until we
                                       # write test
    return bless $self => $class;
}

sub bar {
    my $self = shift;
    my $setting = scalar @_ > 0;
    my $new_bar = shift;

    if($setting){
        croak 'bar must be a MyBar'
            unless blessed $new_bar && $new_bar->isa('MyBar');

        $self->{bar} = $new_bar;
    }

    return $self->{bar};
}


1;
