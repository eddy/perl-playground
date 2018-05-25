package My::Class;
use Moose;
use MyBar;

has 'bar' => (
    is  => 'rw',
    isa => 'MyBar',
);

1;
        
