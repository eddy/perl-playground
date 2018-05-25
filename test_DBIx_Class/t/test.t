#!/prod/share/perls/perl-5.14.1/bin/perl -I/prod/share/perls/cpan-5.14.1/lib/perl5
use v5.14;
use warnings;

use Test::More;
use Data::GUID;
use My::Schema;

sub run_tests {
    my ( $db ) = @_;

    my $guid   = Data::GUID->new;
    my $string = $guid->as_string;
    ok $db->resultset('Test')->create( { uuid => $string, filename => 'testme.txt' } );
}

ok my $schema = My::Schema->connect(
        'dbi:Oracle:VPROD', 'EMAILIN', 'emailin', 
        { RaiseError => 1, 
          PrintError => 1, 
        }
);


run_tests( $schema );
done_testing;



