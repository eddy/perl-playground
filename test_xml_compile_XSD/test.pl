#! /usr/bin/env perl

use v5.14;
use warnings;
use Data::Printer;
use XML::Compile::Schema;
use XML::LibXML::Reader;

warn "THIS DOES NOT WORK -- SOMETHING IS NOT RIGHT WITH THE XSD SCHEMA"
     . "PLEASE LOOK INTO test2.pl INSTEAD";

my $xsd = 'test.XSD';
my $schema = XML::Compile::Schema->new();
$schema->importDefinitions($xsd);


# This will print a very basic description of what the schema describes
$schema->printIndex();

# this will print a hash template that will show you how to construct a
# hash that will be used to construct a valid XML file.
#
# Note: the second argument must match the root-level element of the XML
# document.  I'm not quite sure why it's required here.
warn $schema->template('PERL', 'VacExtension');

say '='x100;

# the above warn will generate a Perl data structure like below that we can use 
# as a starting point
#
#      # is an unnamed complex
#      # VacExtension has a mixed content
#
#      { # is a xs:anyType
#        # attribute name is required
#        name => "anything",
#
#        # mixed content cannot be processed automatically
#        _ => XML::LibXML::Element->new('VacExtension'),
#      }

#
# Look at the above output, it says "mixed content..." so we need to use XML::LibXML::Element
#

my $data = {
    VacExtension => [
        {
            name => 'startdate',
            _    => get_element('2013-05-26'),
        },
        {
            name => 'bullet_point_one',
            _    => get_element('Great opportunity to progress'),
        }
    ],
};

sub get_element {
    my $element = XML::LibXML::Element->new('VacExtension');
    $element->appendText(shift);
    return $element;
}


#
# And use XML::LibXML::Document to generate the final XML output
#
my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
my $write  = $schema->compile(WRITER => "VacExtension");
my $xml    = $write->($doc, $data);
p $xml;
$doc->setDocumentElement($xml);

# show result
print $doc->toString(1); # 1 indicates "pretty print"

exit 0;

