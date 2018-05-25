#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use XML::LibXML;
use Data::Printer;

my $dom = XML::LibXML->load_xml( string => <<'EOT' );
<dom>
  <info>
     <bar info="do not match it">111</bar>
  </info>
  <foo>
    <bar>123</bar>
  </foo>
  <foo>
    <bar>111</bar>
  </foo>
  <foo>
    <bar>456</bar>
  </foo>
  <foo>
    <bar info="match">111</bar>
  </foo>
  <foo>
    <bar>789</bar>
  </foo>
</dom>
EOT


# match all element bar under element foo where its value is 111
my $testMe = $dom->findnodes("//foo/bar[text()='111']");
say ">>>>> $testMe" if $testMe;

p $testMe;

__END__
