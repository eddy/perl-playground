#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use Browser::Open qw/open_browser/;
use Path::Tiny;
use Pod::Simple::XHTML;

my $file = shift @ARGV
    or die "Usage: $0 <file>";
$file = path($file);

my $psx = Pod::Simple::XHTML->new;
$psx->output_string        ( \my $html                     );
$psx->html_charset         ( 'UTF-8'                       );
$psx->html_encode_chars    ( '&<>">'                       );
$psx->perldoc_url_prefix   ( "https://metacpan.org/module/");
$psx->html_header          ( my_header()                   );
$psx->html_footer          ( my_footer()                   );
$psx->parse_string_document( $file->slurp_utf8             );

my $temp = path( $ENV{TMPDIR} ? $ENV{TMPDIR} : '/tmp', 'podpreview', $file->relative . '.html' );
$temp->touchpath;
$temp->spew_utf8($html);
open_browser("file:///$temp");

sub my_css {
    return <<'CSS';
body { background: snow; font-family: sans-serif; }
div#main { width: 70%; margin: 5% auto; }
h1 { font-size: 1.5em; margin: .83em 0 }
h2 { font-size: 1.17em; margin: 1em 0 }
h3 { margin: 1.33em 0 }
h4 { font-size: .83em; line-height: 1.17em; margin: 1.67em 0 }
h5 { font-size: .67em; margin: 2.33em 0 }
h1, h2, h3, h4, h5 { font-weight: bolder; color: #36c }
a:link { color: #36c }
code { font-size: 1.2em }
CSS
}

sub my_header {
    my $css = my_css();
    return <<"HEADER";
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style>
$css
</style>
</head>
<body>
<div id="main">
HEADER
}

sub my_footer {
    return <<'FOOTER';
</div>
</body>
</head>
FOOTER
}
