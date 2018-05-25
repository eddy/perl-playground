package Network_Socket;

use Moose;
use Network_Types qw(IPAddress PortNumber);

has address => (
    is => 'ro',
    isa => IPAddress,
    required => 1,
);

1;

