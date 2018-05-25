# This is a PSGI application file for Apache+Plack support
use CGI::PSGI;
use lib '/home/et6339/webapp';
use webapp;

use Dancer::Config 'setting';
setting apphandler  => 'PSGI';
Dancer::Config->load;

my $handler = sub {
    my $env = shift;
    Dancer->dance(CGI::PSGI->new($env));
};
