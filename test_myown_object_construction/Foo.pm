package Foo;

use warnings;
use strict;
use Data::Printer;
use Carp;

use version; our $VERSION = qv('0.0.1');

my %Attr = (
    name => {
        required => 1,
        validate => sub { defined $_[0] },
    },
    birth_date => {
        required => 0,
        validate => sub { defined $_[0] && $_[0] =~ /^\d\d\/\d\d\/\d\d\d\d$/ },
    },
    shirt_size => {
        required => 1,
        validate => sub { defined $_[0] && $_[0] =~ /^(?:s|m|l|xl|xxl)$/i },
    }
);

sub new {
    my $class = shift;
    my %p = ref $_[0] ? %{ $_[0] } : @_;

#     exists $p{name}
#         or confess 'name is a required attribute';
#     $class->_validate_name( $p{name} );
# 
#     exists $p{birth_date}
#         or confess 'birth_date is a required attribute';
# 
#     $p{birth_date} = $class->_coerce_birth_date( $p{birth_date} );
#     $class->_validate_birth_date( $p{birth_date} );
# 
#     $p{shirt_size} = 'l'
#         unless exists $p{shirt_size}:
# 
#     $class->_validate_shirt_size( $p{shirt_size} );

    for my $field (keys %Attr) {
        if ( $Attr{$field}{required} ) {
            die "Missing required attribute |$field = $p{$field}| in constructor.\n" unless $p{$field};
        }

        if ( exists $p{$field} ) {
            die "Invalid attribute |$field = $p{$field}| in constructor.\n" unless $Attr{$field}{validate}->($p{$field});
        }
    }


    return bless \%p, $class;
}

package main {
    my $t = Foo->new({
        name => 'Eddy Tan',
        birth_date => '18/05/1977',
        shirt_size => 'M',
        unknown => 'foobar',
    });

    p $t;
}

1; # Magic true value required at end of module
