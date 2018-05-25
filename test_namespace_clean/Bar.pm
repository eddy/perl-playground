package Bar;
use common::sense;

# Without this, calling Bar->yell() works which is wrong.
use namespace::autoclean;

use Eddy qw( yell );

sub barrr {
    yell();
}


1;    # true to end package - do NOT remove this line.
