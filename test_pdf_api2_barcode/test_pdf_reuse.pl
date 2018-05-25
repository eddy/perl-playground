#!/usr/bin/env perl

use common::sense;

use PDF::Reuse;

prFile('new.pdf');
prDoc( 'test.pdf' );
prText(500,100, 'Hello World !');
prPage();
prEnd();
