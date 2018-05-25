#!/usr/bin/env perl
use v5.16;
use warnings;

say <<'END';
You will notice in here that EncyclopediaSalesman uses the _WRONG_ role when meta->make_immutable is being
commented.
END

# The Class
{
    package MontyPerl;

    use Moose;

    has sketch => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    sub info {
        my $self = shift;

        with 'MontyPerl::'.$self->sketch;
        return $self->sketch .': '. $self->quote;
    };

    #
    # TODO: commented out to make it work correctly
    #
    #__PACKAGE__->meta->make_immutable;
}

# Role 1
{
    package MontyPerl::Lumberjack;

    use Moose::Role;

    sub quote { 'I cut down trees, I skip and jump, I like to press wildflowers.'; }
}

# Role 2
{
    package MontyPerl::EncyclopediaSalesman;

    use Moose::Role;

    sub quote { 'No madam, Im a burglar, I burgle people.'; }
}

# Script
{
    use strict; use warnings; use feature qw/say/;

    say MontyPerl->new(  sketch => 'Lumberjack' )->info;
    say MontyPerl->new(  sketch => 'EncyclopediaSalesman' )->info;
}

