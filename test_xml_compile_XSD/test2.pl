#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

use Data::Dumper;
use XML::Compile::Schema;
use XML::LibXML::Reader;

my $xsd = 'test2.XSD';

my $schema = XML::Compile::Schema->new($xsd);

# This will print a very basic description of what the schema describes
$schema->printIndex();

# this will print a hash template that will show you how to construct a 
# hash that will be used to construct a valid XML file.
#
# Note: the second argument must match the root-level element of the XML 
# document.  I'm not quite sure why it's required here.
warn $schema->template('PERL', 'addresses');

say "="x100;


my $data = {
    address => [
        {
            name => 'name 1',
            street => 'street 1',
        },
        {
            name => 'name 2',
            street => 'street 2',
        }
    ],
};

my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
my $write  = $schema->compile(WRITER => 'addresses');
my $xml    = $write->($doc, $data);

$doc->setDocumentElement($xml);

print $doc->toString(1); # 1 indicates "pretty print"


