package MyTest;

use 5.014;
use Moose;

has name => (
    is => 'ro',
    required => 1,
    trigger => sub {
        my ($self) = @_;
        $self->clear_packId;
    },
);

has packId => (
    is => 'rw',
    required => 1,
    lazy_build => 1,
);

sub _build_packId {
    my $self = shift;

    say "builder packId";
    $self->packId(100);
    
}

no Moose;
__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

