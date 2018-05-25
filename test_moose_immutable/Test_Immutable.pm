#!/usr/bin/env perl
use v5.16;
use warnings;

say <<'END';
You will notice in here that the code won't compile with error "The 'add_method' method cannot 
be called on an immutable instance" because we activate meta->make_immutable() and we have two 
different roles with the same method name.

We have to use either Moose::Util 'apply_all_roles' or implement "alias".

END

# The Class
{
    package MontyPerl;

    use metaclass (
        metaclass   => "Moose::Meta::Class",
        error_class => "Moose::Error::Croak",
    );
    use Moose;

    has sketch => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );


    #
    # TODO: with meta->make_immutable() being activated below, this code won't compile because we consume
    # two different roles with the same method name.
    #
    sub info {
        my $self = shift;

        with 'MontyPerl::'.$self->sketch;
        return $self->sketch .': '. $self->quote;
    };

    #
    # TODO: commented this so that this code will compile correctly, but the output will be WRONG.
    #
    __PACKAGE__->meta->make_immutable;
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
    use XXX;

    say MontyPerl->new(  sketch => 'Lumberjack' )->info;
    say MontyPerl->new(  sketch => 'EncyclopediaSalesman' )->info;
}

