#!/usr/bin/env perl

#
# Create a simple XML document
#

use strict;
use warnings;
use XML::LibXML;
use POSIX qw(strftime);

my $doc = XML::LibXML::Document->new('1.0', 'utf-8');

my $root = $doc->createElement("docload");
$root->setAttribute('xmlns:hub' => "http://hub.test.com.au");
$root->setAttribute('xmlns:xsi' => "http://www.w3.org/2001/XMLSchema");
$root->setAttribute('xmlns'     => "http://hub.test.com.au");
$root->setAttribute('timestamp' => strftime("%Y-%m-%dT%H:%M:%S", localtime()));
$root->setAttribute('version'   => "0.4");

my %tags = (
    color => 'blue',
    metal => 'steel',
);

for my $name (keys %tags) {
    my $tag = $doc->createElement($name);
    my $value = $tags{$name};
    $tag->appendTextNode($value);
    $root->appendChild($tag);
}

$doc->setDocumentElement($root);

my $format = 2;  # add indentation and newline
print $doc->toString( $format );

