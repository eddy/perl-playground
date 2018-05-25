#! /usr/bin/env perl
use v5.14;
use warnings;

package MyRenderer {
    use base 'CAM::PDF::GS';
    sub new {
        my ($pkg, @args) = @_;
        my $self = $pkg->SUPER::new(@args);
        $self->{refs}->{text} = [];
        return $self;
    }

    sub getTextBlocks {
        my ($self) = @_;
        return @{$self->{refs}->{text}};
    }

    sub renderText {
        my ($self, $string, $width) = @_;
        my ($x, $y) = $self->textToDevice(0,0);
        push @{$self->{refs}->{text}}, {
                                    str       => $string,
                                    left      => $x,
                                    bottom    => $y,
                                    right     => $x + ($width * $self->{Tfs}),
                                    font      => $self->{Tf},
                                    font_size => $self->{Tfs},
                                };
        return;
    }

    1;
}

######################################################################

package main {
    use Carp;
    use Data::Printer;
    use CAM::PDF;

    # my $pdf = CAM::PDF->new('AGLCON.pdf');  # existing document
    my $pdf = CAM::PDF->new('AGLCON.pdf');  # existing document
    my $page = $pdf->getPageContent(5);

    # $page now holds the uncompressed page content as a string
    # p $page;

    my $pagetree    = $pdf->getPageContentTree(5);
    my $page_string = $pagetree->toString();
    my @text        = $pagetree->traverse('MyRenderer')->getTextBlocks;

#     p $pagetree;
    p @text;
#     p $page_string;


    # replace the text part
    $page =~ s/Tj 14 0 Td \(D\)/Tj 14 0 Td \(U\)/;

    $pdf->setPageContent(5, $page);
    $pdf->cleanoutput('Test.pdf');
}

