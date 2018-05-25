package My::Schema::Result::Test;
use strict;
use warnings;

use parent qw/DBIx::Class::Core/;

__PACKAGE__->table('test');
__PACKAGE__->add_columns(qw/ uuid filename datetime env /);
__PACKAGE__->set_primary_key('uuid');

1;

