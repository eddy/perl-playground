#!/usr/bin/env perl

use YAML;
use English;

local $INPUT_RECORD_SEPARATOR;

print Dump(eval(<>));
