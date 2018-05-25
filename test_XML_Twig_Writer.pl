#! /usr/bin/env perl

use v5.14;
use warnings;
use XML::Twig;

my %camelid_links = (
    one => {
        url         => ' http://www.online.discovery.com/news/picture/may99/photo20.html',
        description => 'Bactrian Camel in front of Great ' . 'Pyramids in Giza, Egypt.'
    },
    two => {
        url         => 'http://www.fotos-online.de/english/m/09/9532.htm',
        description => 'Dromedary Camel illustrates the ' . 'importance of accessorizing.'
    },
    three => {
        url         => 'http://www.eskimo.com/~wallama/funny.htm',
        description => 'Charlie - biography of a narcissistic llama.'
    },
    four => {
        url         => 'http://arrow.colorado.edu/travels/other/turkey.html',
        description => 'A visual metaphor for the perl5-porters ' . 'list?'
    },
    five => {
        url         => 'http://www.galaonline.org/pics.htm',
        description => 'Many cool alpacas.'
    },
    six => {
        url         => 'http://www.thpf.de/suedamerikareise/galerie/vicunas.htm',
        description => 'Wild Vicunas in a scenic landscape.'
    }
);


my $root = XML::Twig::Elt->new('html');
my $body = XML::Twig::Elt->new('body');
$body->paste($root);

foreach my $item ( keys(%camelid_links) ) {
    my $link = XML::Twig::Elt->new('a');
    $link->set_att( 'href', $camelid_links{$item}->{url} );
    $link->set_text( $camelid_links{$item}->{description} );
    $link->paste( 'last_child', $body );
}

print qq|<?xml version="1.0"?>|;
$root->set_pretty_print('indented');
$root->print();

