#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);
use Data::Dumper;
use Data::Printer;

{ 
    package Address;
    use Scalar::Util qw(refaddr);

    my %surname;
    my %firstname;
    my %street;
    my %postal;

    sub new {
        my ($class, %args) = @_;

        my $self = bless \do{my $anon_scalar}, $class;

        $args{postal} //= $args{street};

        $surname{   refaddr $self } = $args{surname};
        $firstname{ refaddr $self } = $args{firstname};
        $street{    refaddr $self } = $args{street};
        $postal{    refaddr $self } = $args{postal};

        return $self;
    }

    sub get_surname {
        my ($self) = @_;
        return $surname{refaddr $self};
    }

    sub get_firstname {
        my ($self) = @_;
        return $firstname{refaddr $self};
    }

    sub get_street {
        my ($self) = @_;
        return $street{refaddr $self};
    }

    sub get_postal {
        my ($self) = @_;
        return $postal{refaddr $self};
    }

    sub get_name {
        my ($self) = @_;
        return $firstname{refaddr $self} . ' ' . $surname{refaddr $self};
    }


}

package main; 

my $list = Address->new(
               firstname => 'Eddy',
               surname   => 'Tan',
               street    => 'Railway Ave, Dandenong, VIC',
           );

say $list->get_name();           
say $list->get_postal;

say Dumper $list;
p $list;
