#!/usr/bin/env perl

use YAML;
use English;
use Data::Dumper;

local $INPUT_RECORD_SEPARATOR;

print Dumper(Load(<>));


