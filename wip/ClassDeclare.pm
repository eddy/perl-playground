package ClassDeclare;

use warnings;
use strict;
use base qw( Class::Declare );


#my $inline = __PACKAGE__->_test2("Inline text");
#print $inline . "\n";

sub new
{
    my $class = shift;
    
    my $self = {};
    bless $self, $class;
    return $self;
}

sub test1
{
    my ($self, $string) = @_;

    my $extra = $self->_test2(" extra extra extra");
    $string .= $self->{extra_text};
    $self->{string} = $string;
}

sub _test2
{
    my $self = __PACKAGE__->private( shift );
    my ($text) = @_;
    # $self->{extra_text} = ' extra text';
    $self->{extra_text} = $text;
}

1;


