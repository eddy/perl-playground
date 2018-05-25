#!/usr/bin/perl

while (<>) {
  chomp;
  $output .= $_ . " ";
}

$output =~ s/'//g;

`/bin/mail -s 'Tan,Eddy|NONE|NONE|$output' pager\@dingo.melb.hpa </dev/null`
    && print STDERR "/users/et6339/sourcebin/pager_me.pl: email sent\n";


