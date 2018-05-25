#!/usr/bin/perl -w

use strict;

use XML::Simple;
use Data::Dumper;

my @check = (
{ JobSeqNo => 'M08.40'  ,      Batch =>   '40225'   }   ,
{ JobSeqNo => 'P08.39'  ,      Batch =>   '39607'   },
{ JobSeqNo => 'G07.40'  ,      Batch =>   '40951'   },
{ JobSeqNo => 'K07.38'  ,      Batch =>   '40141'   },
{ JobSeqNo => 'R07.38'  ,      Batch =>   '39438'   },
{ JobSeqNo => 'M07.39'  ,      Batch =>   '40205'   },
{ JobSeqNo => 'S07.419' ,      Batch =>   '40217'   },
{ JobSeqNo => 'J07.38'  ,      Batch =>   '40391'   },
{ JobSeqNo => 'A07.38'  ,      Batch =>   '39645'   },
{ JobSeqNo => 'A07.43'  ,      Batch =>   'H69011'  },
{ JobSeqNo => 'G09.19'  ,      Batch =>   '40979'   },
{ JobSeqNo => 'G09.22'  ,      Batch =>   '40981'   },
{ JobSeqNo => 'B09.20'  ,      Batch =>   '41095'   },
{ JobSeqNo => 'B09.23'  ,      Batch =>   '41097'   },
{ JobSeqNo => 'A09.19'  ,      Batch =>   '39673'   },
{ JobSeqNo => 'A09.22'  ,      Batch =>   '39675'   },
{ JobSeqNo => 'H09.19'  ,      Batch =>   '36344'   },
{ JobSeqNo => 'S09.400' ,      Batch =>   '40247'   },
{ JobSeqNo => 'J09.19'  ,      Batch =>   '40422'   },
{ JobSeqNo => 'M09.19'  ,      Batch =>   '40233'   },
{ JobSeqNo => 'M09.22'  ,      Batch =>   '40235'   },
{ JobSeqNo => 'K09.22'  ,      Batch =>   '40172'   },
{ JobSeqNo => 'R09.19'  ,      Batch =>   '39464'   },
{ JobSeqNo => 'P09.20'  ,      Batch =>   '39614'   },
{ JobSeqNo => 'P09.23'  ,      Batch =>   '39616'   },
{ JobSeqNo => 'K08.21'  ,      Batch =>   '40150'   },
{ JobSeqNo => 'S07.406' ,      Batch =>   'H67821'  },
{ JobSeqNo => 'M09.39'  ,      Batch =>   '40246'   },
{ JobSeqNo => 'B08.33'  ,      Batch =>   '41075'   },
{ JobSeqNo => 'B08.36'  ,      Batch =>   '41077'   },
{ JobSeqNo => 'P08.23'  ,      Batch =>   '39596'   },
{ JobSeqNo => 'J07.22'  ,      Batch =>   '40381'   },
{ JobSeqNo => 'G07.23'  ,      Batch =>   '40940'   },
{ JobSeqNo => 'K07.22'  ,      Batch =>   '40131'   },
{ JobSeqNo => 'K07.19'  ,      Batch =>   '40129'   },
{ JobSeqNo => 'H08.38'  ,      Batch =>   '36338'   },
{ JobSeqNo => 'S08.421' ,      Batch =>   '40237'   },
{ JobSeqNo => 'C02.14'  ,      Batch =>   'H67711'  },
{ JobSeqNo => 'C02.18'  ,      Batch =>   'H67751'  },
{ JobSeqNo => 'I09.24'  ,      Batch =>   '5286'    },
{ JobSeqNo => 'H09.38'  ,      Batch =>   '36354'   },
{ JobSeqNo => 'R09.38'  ,      Batch =>   '39476'   },
{ JobSeqNo => 'J09.38'  ,      Batch =>   '40435'   },
{ JobSeqNo => 'A09.38'  ,      Batch =>   '39685'   },
{ JobSeqNo => 'S06.352' ,      Batch =>   'H65401'  },
{ JobSeqNo => 'I06.24'  ,      Batch =>   '5268'    },
{ JobSeqNo => 'A06.38'  ,      Batch =>   '39627'   },
{ JobSeqNo => 'C02.2'   ,      Batch =>   'H67591'  },
{ JobSeqNo => 'C02.41'  ,      Batch =>   'H67631'  },
{ JobSeqNo => 'C02.10'  ,      Batch =>   'H67691'  },
{ JobSeqNo => 'C02.40'  ,      Batch =>   'H67811'  },
{ JobSeqNo => 'I07.24'  ,      Batch =>   '5274'    },
{ JobSeqNo => 'P07.38'  ,      Batch =>   '39587'   },
{ JobSeqNo => 'P07.28'  ,      Batch =>   '39579'   },
{ JobSeqNo => 'R06.39'  ,      Batch =>   '39419'   },
{ JobSeqNo => 'B06.44'  ,      Batch =>   '41040'   },
{ JobSeqNo => 'P06.38'  ,      Batch =>   '39569'   },
{ JobSeqNo => 'S07.398' ,      Batch =>   '40205'   },
{ JobSeqNo => 'H07.19'  ,      Batch =>   '36311'   },
{ JobSeqNo => 'B07.23'  ,      Batch =>   '41047'   },
{ JobSeqNo => 'C02.5'   ,      Batch =>   'H67641'  },
{ JobSeqNo => 'C02.6'   ,      Batch =>   'H67651'  },
{ JobSeqNo => 'C02.11'  ,      Batch =>   'H67701'  },
{ JobSeqNo => 'C02.12'  ,      Batch =>   'H67721'  },
{ JobSeqNo => 'C02.19'  ,      Batch =>   'H67761'  },
{ JobSeqNo => 'G08.18'  ,      Batch =>   '40959'   },
{ JobSeqNo => 'M08.21'  ,      Batch =>   '40214'   },
{ JobSeqNo => 'M08.24'  ,      Batch =>   '40216'   },
{ JobSeqNo => 'A08.20'  ,      Batch =>   '39654'   },
{ JobSeqNo => 'C02.3'   ,      Batch =>   'H67611'  },
{ JobSeqNo => 'C02.9'   ,      Batch =>   'H67681'  },
{ JobSeqNo => 'C02.20'  ,      Batch =>   'H67771'  },
{ JobSeqNo => 'J08.41'  ,      Batch =>   '40415'   },
{ JobSeqNo => 'S07.401' ,      Batch =>   '40207'   },
{ JobSeqNo => 'G07.20'  ,      Batch =>   '40938'   },
{ JobSeqNo => 'H06.39'  ,      Batch =>   '36304'   },
{ JobSeqNo => 'C02.21'  ,      Batch =>   'H67781'  },
{ JobSeqNo => 'H08.22'  ,      Batch =>   '36329'   },
{ JobSeqNo => 'S08.403' ,      Batch =>   '40228'   },
{ JobSeqNo => 'R08.20'  ,      Batch =>   '39447'   },
{ JobSeqNo => 'R08.23'  ,      Batch =>   '39448'   },
{ JobSeqNo => 'J08.25'  ,      Batch =>   '40404'   },
{ JobSeqNo => 'S09.397' ,      Batch =>   '40245'   },
{ JobSeqNo => 'J09.22'  ,      Batch =>   '40424'   },
{ JobSeqNo => 'G08.21'  ,      Batch =>   '40961'   },
{ JobSeqNo => 'H08.19'  ,      Batch =>   '36328'   },
{ JobSeqNo => 'A08.23'  ,      Batch =>   '39656'   },
{ JobSeqNo => 'J08.22'  ,      Batch =>   '40402'   },
{ JobSeqNo => 'I08.24'  ,      Batch =>   '5280'    },
{ JobSeqNo => 'S09.418' ,      Batch =>   '40257'   },
{ JobSeqNo => 'G06.36'  ,      Batch =>   '40930'   },
{ JobSeqNo => 'J06.38'  ,      Batch =>   '40372'   },
{ JobSeqNo => 'K06.38'  ,      Batch =>   '40122'   },
{ JobSeqNo => 'M06.40'  ,      Batch =>   '40185'   },
{ JobSeqNo => 'A07.19'  ,      Batch =>   '39633'   },
{ JobSeqNo => 'A07.22'  ,      Batch =>   '39635'   },
{ JobSeqNo => 'J07.19'  ,      Batch =>   '40379'   },
{ JobSeqNo => 'H07.22'  ,      Batch =>   '36312'   },
{ JobSeqNo => 'P08.20'  ,      Batch =>   '39595'   },
{ JobSeqNo => 'H09.22'  ,      Batch =>   '36345'   },
{ JobSeqNo => 'R09.22'  ,      Batch =>   '39466'   },
{ JobSeqNo => 'K09.19'  ,      Batch =>   '40170'   },
{ JobSeqNo => 'K09.38'  ,      Batch =>   '40183'   }
);

my $xs = new XML::Simple( KeepRoot => 0,
                          NoAttr => 1,
                          XMLDecl => 1,
                          ForceArray => [ qw(Job) ],
                          SuppressEmpty => '',
                          NormaliseSpace => 2 );

my $xml;
eval { $xml = $xs->XMLin('clink.starsactuals.20060814.132352.xml'); };
if($@) {
    die "ERROR ERROR ERROR ERROR\n";
}

# print Data::Dumper::Dumper($xml->{Job});

open(FOO, "> test_error_upload_to_stars.txt") or die "cannot open: $!";

my @output = ();
for my $job (@{$xml->{Job}}) {
    for my $error (@check) {
        if (
            $job->{Key}->{JobSeqNo} eq $error->{JobSeqNo}
             && $job->{Key}->{BatchNo} eq $error->{Batch}
        ) {
             push @output, $job->{Printing}->{FormName};
             my $msg = "JSN: $job->{Key}->{JobSeqNo}\tBatch: $job->{Key}->{BatchNo}\tForm: $job->{Printing}->{FormName}\n";
             print FOO $msg 
             
        }
    }        
}

close FOO || die "cannot close\n";

my $output_hash = { Job => \@output };
my $xl = new XML::Simple( RootName => '',
                          NoAttr => 1,
                          KeyAttr => [],
                          XMLDecl => 0,
                          SuppressEmpty => '' );

eval { $xl->XMLout($output_hash, OutputFile => 'test_error_upload_to_stars.xml') };
if ($@) {
    die "BLAAAAHHHHHHH BLAHHHHHHHH\n";
}


exit 0;

