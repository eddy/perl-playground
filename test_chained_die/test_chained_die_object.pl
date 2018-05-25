#! /usr/bin/env perl
use v5.14;
use warnings;

################################################################################
#
package Local::Error {
    sub new { bless $_[1], $_[0] }

    sub PROPAGATE {
        my ( $self, $file, $line ) = @_;

        $self->{chain} = [] unless ref $self->{chain};
        push @{ $self->{chain} }, [ $file, $line ];

        $self;
    }
}

################################################################################
#
package main {
    my $result = eval {
        eval {
            my $file = "/etc/passwd";

            eval {
                # start here
                unless ( open my $fh, '>', $file ) {
                    die Local::Error->new( { errno => $! } );
                }
            };
            if ( defined $@ and length $@ ) {
                die;    # first catch
            }
        };

        if ( defined $@ and length $@ ) {
            die;        # second catch
        }
        else {
            print "Here I am!\n";
        }
    };

    if ( defined $@ and length $@ ) {
        use Data::Dumper;
        print "I got " . Dumper($@) . "\n";    # finally
    }
}

