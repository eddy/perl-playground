#!/usr/bin/env perl
use v5.16;
use warnings;

say <<'END';
You will notice in here that the code works correctly after we replace "with" to apply_all_roles() and
activate meta->make_immutable().
END

# The Class
{
    package MontyPerl;

    use Moose;
    use Moose::Util 'apply_all_roles';

    has sketch => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    #
    # TODO: with meta->make_immutable() being activated below and apply_all_roles() from Moose::Util,
    # two different roles with the same method name will get it correctly.
    #
    sub info {
        my $self = shift;

        #
        # TODO: Note that we change "with" statement here with apply_all_roles();
        #
        # with 'MontyPerl::'.$self->sketch;
        apply_all_roles($self, 'MontyPerl::'.$self->sketch);
        return $self->sketch .': '. $self->quote;
    };

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

    say MontyPerl->new(  sketch => 'Lumberjack' )->info;
    say MontyPerl->new(  sketch => 'EncyclopediaSalesman' )->info;
}

