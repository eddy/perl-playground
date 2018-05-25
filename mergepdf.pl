#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use CAM::PDF;
use Getopt::Long;
use Pod::Usage;

our $VERSION = '1.00';

my %opts = ( verbose    => 0,
             prepend    => 0,
             forms      => 0,
             order      => 0,
             help       => 0,
             version    => 0,
           );

Getopt::Long::Configure('bundling');
GetOptions( 'f|forms'    => \$opts{forms},
            'v|verbose'  => \$opts{verbose},
            'p|prepend'  => \$opts{prepend},
            'o|order'    => \$opts{order},
            'h|help'     => \$opts{help},
            'V|version'  => \$opts{version},
          ) or pod2usage(1);

if ($opts{version}) {
   print "merge_pdf v$VERSION\n";
   print "CAM::PDF v$CAM::PDF::VERSION\n";
   exit 0;
}

$opts{help}
  and pod2usage(-exitstatus => 0, -verbose => 2);

my $verbose = sub() { };
$opts{verbose}
  and $verbose = sub { print @_ };

@ARGV < 2
  and pod2usage(1);

@ARGV == 2
  and push @ARGV, '-';

my $outfile = pop @ARGV;

my @docs = map { CAM::PDF->new($_) or die "$CAM::PDF::errstr\n"; } @ARGV;

$opts{prepend}
  and @docs = reverse @docs;

my $master_doc = shift @docs;
foreach my $doc (@docs) {
    $verbose->('Merging ' . $doc->numPages() . ' page(s) to original ' . $master_doc->numPages() . " page(s)\n");
    $master_doc->appendPDF($doc);
}

$opts{forms}
 or $master_doc->clearAnnotations();

$opts{order}
  and $master_doc->preserveOrder();

$master_doc->canModify()
  or die "This PDF forbids modification\n";

$master_doc->cleanoutput($outfile);

__END__

=for stopwords appendpdf.pl

=head1 NAME

appendpdf.pl - Append one PDF to another

=head1 SYNOPSIS

 appendpdf.pl [options] file1.pdf file2.pdf ... fileN.pdf outfile.pdf

 Options:
   -p --prepend        prepend the document instead of appending it
   -f --forms          wipe all forms and annotations from the PDF
   -o --order          preserve the internal PDF ordering for output
   -v --verbose        print diagnostic messages
   -h --help           verbose help message
   -V --version        print CAM::PDF version

=head1 DESCRIPTION

Copy the contents of C<file2.pdf> to the end of C<file1.pdf>.  This may
break complex PDFs which include forms, so the C<--forms> option is
provided to eliminate those elements from the resulting PDF.

=head1 SEE ALSO

CAM::PDF

F<deletepdfpage.pl>

=head1 AUTHOR

See L<CAM::PDF>
Modified by Damien "dams" Krotkine

=cut
