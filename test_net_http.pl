#! /usr/bin/env perl

use v5.14;
use warnings;
use Carp;
use Data::Printer;
use autodie qw(:all);

# use IO::Prompt;
# use Perl6::Slurp;
# use Perl6::Say;
# use Smart::Comments

use Net::HTTP;

my %headers = ( 
    'User-Agent' => "Net::HTTP/$Net::HTTP::VERSION",
    'proxy-authorization'  => 'user:password',
);

my $client  = Net::HTTP->new(
    Host                   => 'www.google.com',
    Proto                  => 'http',
    'PeerAddr'             => 'proxy.test.net',
    'PeerPort'             => 8080,
    'Proxy-Authentication' =>  1,
) || die $@;

$client->write_request(GET => '/', %headers);

my ($code, $mess, %h) = $client->read_response_headers;

if ($code =~ /^2/) {
    print "Status: $code\n";
    while (1) {
        my $buf;
        my $nread = $client->read_entity_body($buf, 1024);
        die "read failed: $!" unless defined $nread;
        last unless $nread;
        print $buf;
    }
} else {
    print "Request failed\n";
    print "Status:   $code\n";
    print "Response: $mess\n";
}
