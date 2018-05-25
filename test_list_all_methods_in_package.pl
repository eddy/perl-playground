#!/usr/bin/env perl

use strict;
use warnings;
use XML::Simple;
use Data::Dumper::Simple;


#
# All the symbols in Foo's symbol table is stored in %XML::Simple::
# then check if the symbol is a method by calling it &{$_}
# 
# Alternative: use Class::Inspector
#
no strict 'refs';
my @methods = grep { defined &{$_} } keys %XML::Simple::;
use strict 'refs';

print Dumper @methods;

exit 0;


