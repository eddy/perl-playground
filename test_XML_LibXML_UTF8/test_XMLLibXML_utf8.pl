#! /usr/bin/env perl

use strict;
use warnings;
use Carp;
use POSIX   qw(strftime);
use XML::LibXML ();


open my $fop, ">:encoding(iso-8859-1)", 'ooo.xml'
    or die "Failed to open output file: $!";


my $xml = '<?xml version="1.0" encoding="utf-8"?>' . "\n";
$xml .= '<pdf filename="testme.pdf" doctype="FOO">' . "\n";
$xml .= mysub_132();
$xml .= "</pdf>\n";

print {$fop} $xml;
close $fop
    or die "Failed to close file for writing: $!";

sub mysub_132
{
    open my $fip, "<:encoding(iso-8859-1)", 'test_latin1.udof'
        or die "Failed open input file : $!";

    my $xml = '';
    while ( my $line = <$fip> ) {
        chomp $line;
        my @fields = split( /\xA5/, $line );

        foreach my $f ( 0 .. ( scalar(@fields) - 1 ) ) {
            # make the values XML safe eg < > &
            $fields[$f] = XML::LibXML::Document->new('1.0', 'UTF-8')->createTextNode( $fields[$f] )->toString;
        }

        my $UniqueID            = $fields[0];
        my $PageTotalInDocument = int( $fields[1] );
        my $dummy1              = $fields[2];
        my $DocumentNumber      = $fields[3];
        my $ContractAcctNumber  = $fields[4];
        my $Contract            = $fields[5];
        my $Jurisdiction        = $fields[6];
        my $AddressRegion       = $fields[7];
        my $FuelType            = $fields[8];
        my $DunningActivity     = $fields[9];
        my $DunningProcedure    = $fields[10];
        my $TemplateId          = $fields[11];
        my $dummy2              = $fields[12];
        my $ReturnMailCode      = $fields[13];
        my $IssueDate           = $fields[14];
        my $DueDate             = $fields[15];
        my $AddressLine0        = $fields[16];
        my $CompanyCode         = $fields[17];
        my $EOL                 = $fields[18];

        my $uploadDate = strftime("%d/%m/%Y", localtime(time));
        my $uploadTime = strftime("%H:%M:%S", localtime(time));

        $xml .= <<"END";
        <document>
        <page span="$PageTotalInDocument">
            <index number="1">
            <field number="1">$DocumentNumber</field>
            <field number="2">$ContractAcctNumber</field>
            <field number="3">$Contract</field>
            <field number="4">$Jurisdiction</field>
            <field number="5">$AddressRegion</field>
            <field number="6">$FuelType</field>
            <field number="7">$DunningActivity</field>
            <field number="8">$TemplateId</field>
            <field number="9">$DunningProcedure</field>
            <field number="10"></field>
            <field number="11">$ReturnMailCode</field>
            <field number="12">$IssueDate</field>
            <field number="13">$DueDate</field>
            <field number="14">$AddressLine0</field>
            <field number="15">$uploadDate</field>
            <field number="16">$uploadTime</field>
            <field number="17">$CompanyCode</field>
            </index>
        </page>
        </document>
END
    }

    close $fip;
    return $xml;
}

