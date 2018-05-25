#!/usr/bin/perl

use strict;
use warnings;

############################################################
# Global variables
#

my $debug = 5; # debug level (0 to stop debug output)

# Declare and set global state/cache variables
my @current_position;
my $four_state_barcode_exists;
my $store_next_text_as_checkpoint;
my @text_locations;
my @line_locations;
reset_global_caches();

# Global variables which are not reset
my $current_checkpoint = "";

# Regular expression triggers
# These triggers define how command handlers are called
my $newpage_re    = qr/^<NP/;                   # New page
my $checkpoint_re = qr/^<CP>$/;                 # Checkpoint
my $absmove_re    = qr/^<(?:AC|AH|AP|AV)/;      # Position setting
my $linedraw_re   = qr/^<(?:AR)/;               # Line drawing
my $error_re      = qr/^<(CR|HP|VP|FP|HS|TB)/;  # Unsupported (die if found)

############################################################
# Main program
#

# Read each line of the input file
while (my $line = <>) {
  chomp($line);

  # For each line of input, split it up into ELF commands and text
  my @tokens
    = $line =~ /(<[^>]*?>|[^<>]+)/g;
  for my $token ( @tokens ) {
    $token =~ /^</  ? handle_command($token)
                    : handle_text($token);
  }
}

############################################################
# Miscellaneous functions
#

sub reset_global_caches {
  # resets the global state/cache variables
  @current_position = (0, 0);
  $four_state_barcode_exists = 0;
  $store_next_text_as_checkpoint = 0;
  @text_locations = ();
  @line_locations = ();
}

sub debug {
  my ($level, $message) = @_;

  if ( $debug >= $level ) {
    print STDERR "$message\n";
  }
}

############################################################
# Command-handlers
#

sub handle_command {
  my ($command_text) = @_;

  debug(10, "COMMAND: [$command_text]");


  # Handle known commands, ignore others
    $command_text =~ $newpage_re    ? cmd_newpage($command_text)
  : $command_text =~ $checkpoint_re ? cmd_checkpoint($command_text)
  : $command_text =~ $absmove_re    ? cmd_absolutemove($command_text)
  : $command_text =~ $linedraw_re   ? cmd_linedraw($command_text)
  : $command_text =~ $error_re      ? cmd_cannothandle($command_text)
  : 1;

  return;
}

sub cmd_newpage {
  my ($command_text) = @_;

  # If there was a 4state barcode in the previous page, search
  # for postcodes in the stored text
  if ( $four_state_barcode_exists ) {
    warn "Write logic to find barcodes when 4state barcode exists";
    # Take the position of the first line drawing command in the list
    # and check each potential postcode in the @text_locations list
    # for any positions that fall within 600 across and 250 down the page
    # (this is a reasonable size to cover a full address)
    my @top_left = @{ $line_locations[0]->{location} };
    my @bottom_right = ( $top_left[0] + 600, $top_left[1] + 250 );

    my @postcode_candidates = ();
    for my $text_location_ref ( @text_locations ) {
      my @text_loc = @{ $text_location_ref->{location} };
      if (    $text_loc[0] >= $top_left[0] && $text_loc[0] <= $bottom_right[0]
           && $text_loc[1] >= $top_left[1] && $text_loc[1] <= $bottom_right[1]
         ) {
          push @postcode_candidates, $text_location_ref;
      }
    }

    # Log the postcode candidates against the checkpoint (later
    # on this should fail on multiple postcodes)
    print "CHECKPOINT: $current_checkpoint ";
    print "POSTCODE: $_->{text} " for @postcode_candidates;
    print "\n";
  }

  # Clear buffers for next page
  reset_global_caches();
  debug(5, "New-page, resetting global caches");

  return;
}

sub cmd_checkpoint {
  my ($command_text) = @_;

  # Set the $store_next_text_as_checkpoint flag
  $store_next_text_as_checkpoint = 1;
  debug(7, "Checkpoint command, next text will be stored as checkpoint.");

  return;
}

sub cmd_absolutemove {
  my ($command_text) = @_;

  # Store current position for diagnostics
  my @before_move_position = (@current_position);

  # These commands cause the location to move, detect which move command and
  # ammend the current position
  if ( $command_text =~ /^<AP(\d+),(\d+)>$/ ) {
    # Absolute Postion : <APh,v>
    #  h = new horizonal position
    #  v = new vertical position
    my ($horizontal, $vertical) = ($1, $2);
    @current_position = ($horizontal, $vertical);
  }
  elsif ( $command_text =~ /^<AV(\d+)>$/ ) {
    # Absolute Vertical : <AVv>
    #  v = new vertical position
    my $vertical = $1;
    $current_position[1] = $vertical;
  }
  elsif ( $command_text =~ /^<AH(\d+)>$/ ) {
    # Absolute Horizontal : <AHh>
    #  h = new horizonal position
    my $horizontal = $1;
    $current_position[0] = $horizontal;
  }
  elsif ( $command_text =~ /^<AC(-?\d+)>$/ ) {
    # Absolute Carriage Return : <ACv>
    #  v = distance to move vertically (positive or negative)
    my $vertical_shift = $1;
    $current_position[1] += $vertical_shift;
  }
  else {
    die "Unknown move command [$command_text]";
  }

  debug(6, "Moving position from (@before_move_position) to "
         . "(@current_position) with command [$command_text]");
  
  return;
}

sub cmd_linedraw {
  my ($command_text) = @_;

  # These commands draw lines on the page, if the line being drawn is
  # of interest process it
  if ( $command_text =~ /^<AR(\d+),(\d+),([01]),([012])>$/ ) {
    # Absolute Rule : <ARh,v,o,l>
    #  h = length of line
    #  v = thickness of line
    #  o = orientation (0 horizontal, 1 vertical)
    #  l = line type (0 solid, 1 dashed, 2 dotted)
    my ($length, $thick, $orientation, $type) = ($1, $2, $3, $4);

    # To speed things up - we only care about finding these lines if we haven't
    # already found a 4state barcode so:
    return if $four_state_barcode_exists;

    # The two 4state barcodes START bars are drawn with three drawing commands
    #  Bar 1: <AR6,1,0,0>
    #         <AR40,6,1,0>
    #  Bar 2: <AR16,6,1,0>
    #
    # The two lines in bar one are adjacent:
    #  * The vertical bar is a thick as the horizontal bar is long
    #  * The horizontal position of both bars are equal
    #  * The vertical position of the vertical bar plus the length of the
    #    line should equal thge starting position of the horizontal bar
    #
    # Note: To avoid catching the centrelink 4state barcode only lines with
    #       a horizontal position less than 10,000 will be considered
    if ( $current_position[0] < 10_000 ) {
      # Decide if the line is of interest
      if (  ( $length == 6  && $thick == 1 && $orientation == 0 && $type == 0 )
         || ( $length == 40 && $thick == 6 && $orientation == 1 && $type == 0 )
         || ( $length == 16 && $thick == 6 && $orientation == 1 && $type == 0 )
         ) {
          # Found an interesting line - store it with the position
          push @line_locations, { 'length'    => $length,
                                  thickness   => $thick,
                                  orientation => $orientation,
                                  linetype    => $type,
                                  location    => [@current_position],
                                };

          debug(5, "Found interesting line [${command_text}]"
                 . " at (@current_position)");
         }
    }

    # Check the @line_locations list to see if we have the start of a 4state
    # barcode cached yet, if so - set the $four_state_barcode_exists flag
    if ( scalar @line_locations >= 3 ) {
      warn "Fudging the line finder - only reacting to finding three"
         . " interesting lines at the moment...";
      $four_state_barcode_exists = 1;
    }
  }
  else {
    die "Unknown line drawing command [$command_text]";
  }

  return;
}

sub cmd_cannothandle {
  my ($command_text) = @_;

  # These commands are not currently supported and should generate
  # fatal errors if encountered in the data
  die "Cannot handle command: $command_text\n";
}

############################################################
# Text-handlers
#
sub handle_text {
  my ($text) = @_;

  debug(10, "TEXT: [$text]");
  
  # Handle known text, ignore others
    $store_next_text_as_checkpoint ? text_checkpoint($text)
  : $text =~ /^\d{4}$/             ? text_postcode($text)
  : 1;

  return;
}

sub text_checkpoint {
  my ($text) = @_;

  # Store the checkpoint and reset the $store_next_text_as_checkpoint flag
  $current_checkpoint = $text;
  debug(4, "New checkpoint: $text");

  $store_next_text_as_checkpoint = 0;

  return;
}

sub text_postcode {
  my ($text) = @_;
  push @text_locations, { text => $text,
                          location => [@current_position],
                        };
  debug(5, "Found postcode-like text [${text}] at (@current_position)");

  return;
}
