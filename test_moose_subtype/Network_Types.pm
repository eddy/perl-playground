package Network_Types;

use MooseX::Types -declare => [qw(IPAddress PublicIPAddress PortNumber)];
use MooseX::Types::Moose qw(Int Str);

subtype IPAddress, as Str, where {
    my @quads = split /\./;
    return unless 4 == @quads;

    for (@quads) {
        return if /[^0-9]/ or $_ > 255 or $_ < 0;
    }
    return 1;
};

subtype PublicIPAddress, as IPAddress, where {
    return !/\A127\./ and !/\A10\./;
};

1;
