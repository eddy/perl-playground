package MyBar;
use strict;
use warnings;

sub new { 
    my ($class) = @_; # crappy error message if %args is odd
    return bless {} => $class;
}

1;
