#!/usr/bin/perl

use strict;
use warnings;
use 5.10.1;

use XML::LibXML;

my $xml_string = do { local $/; <DATA> };

my $parser = XML::LibXML->new( no_blanks => 1 );
my $dom    = XML::LibXML->load_xml( string => $xml_string );

foreach my $sentence ( $dom->findnodes('//sentence') ) {
    say $sentence->findvalue( "./text()" );
}

exit 0;

__DATA__
<response>
  <paragraph>
    <sentence id="1">    Hey   </sentence>
    <sentence id="2">Hello          </sentence>
  </paragraph>
</response>
