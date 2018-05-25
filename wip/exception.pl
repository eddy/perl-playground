#!/usr/bin/perl -w

use strict;
use Data::Dumper;

use Exception::Class ( 
        'MyException',

        'AnotherException' => { 
            isa => 'MyException' 
        },

        'YetAnotherException' => { 
            isa         => 'AnotherException',
            description => 'These exceptions are related to IPC' 
        },

        'ExceptionWithFields' => { 
            isa    => 'YetAnotherException',
            fields => [ 'grandiosity', 'quixotic' ],
            alias  => 'throw_fields',
        },
);

# try
eval { MyException->throw( error => 'I feel funny.' ) };

my $e;
# catch
# if ( $e = Exception::Class->caught('MyException') ) {
if ( $e = MyException->caught() ) {
   print Dumper($e);
   warn $e->error, " --- ", $e->trace->as_string, "\n";
   warn join '', $e->euid, $e->egid, $e->uid, $e->gid, $e->pid, $e->time;
}
elsif ( $e = Exception::Class->caught('ExceptionWithFields') ) {
   $e->quixotic ? do_something_wacky() : do_something_sane();
}
else {
   $e = Exception::Class->caught();
   ref $e ? $e->rethrow : die $e;
}

# use an alias - without parens subroutine name is checked at
# compile time
throw_fields error => "No strawberry", grandiosity => "quite a bit";

exit 0;
