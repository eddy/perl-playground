#!/usr/bin/env perl

use strict;
use warnings;

######### System initialization section ###
use Log::Log4perl qw(get_logger :levels);

my $food_logger = get_logger("Groceries::Food");
$food_logger->level($INFO); 

# Appenders
my $appender = Log::Log4perl::Appender->new(
    "Log::Dispatch::File",
    filename => "test.log",
    mode     => "append",
);

$food_logger->add_appender($appender);

# Layouts
my $layout = 
  Log::Log4perl::Layout::PatternLayout->new(
                 "%d %p> %F{1}:%L %M - %m%n");
$appender->layout($layout);

######### Run it ##########################
my $food = Groceries::Food->new("Sushi");
$food->consume();

$food_logger->info("Test me here");



######################################################################
######### Application section #############
package Groceries::Food;

use Log::Log4perl qw(get_logger);

sub new {
    my($class, $what) = @_;
    
    my $logger = get_logger("Groceries::Food");
    
    if(defined $what) {
        $logger->debug("New food: $what");
        return bless { what => $what }, $class;
    }

    $logger->error("No food defined");
    return undef;
}

sub consume {
    my($self) = @_;
    
    my $logger = get_logger("Groceries::Food");
    $logger->info("Eating $self->{what}");
}

