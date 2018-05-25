#!/usr/bin/perl

use strict;
use warnings;

#
# helper subroutines
#
sub output_method {
  my ( $self, @args ) = @_;

  my $output_fh = $self->get_output_fh;

  print $output_fh @args;
}

sub get_output_fh {
  my ($self) = @_;

  return $self->{output_fh} || *STDOUT{IO};
}

sub set_output_fh {
  my ( $self, $fh ) = @_   ;

  $self->{output_fh} = $fh;
}


#
# Main testing...
#

$obj->output_method("Hello stdout!\n");

# capture the output in a string
open my ($str_fh), '>', \$string;
$obj->set_output_fh($str_fh);
$obj->output_method("Hello string!\n");

# send the data over the network
socket( my ($socket), ... );
$obj->set_output_fh($socket);
$obj->output_method("Hello socket!\n");

# output to a string and STDOUT at the same time
use IO::Tee;
my $tee =
  IO::Tee->new( $str_fh, *STDOUT{IO} );
$obj->set_output_fh($tee);
$obj->output_method("Hello all of you!\n");

# send the data nowhere
use IO::Null;
my $null_fh = IO::Null->new;
$obj->set_output_fh($null_fh);
$obj->output_method("Hello? Anyone there?\n");

# decide at run time: interactive sessions use stdout,
# non-interactive session use a null filehandle
use IO::Interactive;
$obj->set_output_fh( interactive() );
$obj->output_method("Hello, maybe!\n");

# dev/null
$obj->set_output_fh( IO::Null->new )
  if $config->{be_quiet};


