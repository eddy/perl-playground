#!/bin/sh

BASE='/users/bd6338/files/wip/reports'

DATEARG=`date +%d-%m-%y -d yesterday`
DATE=`date +%d-%m-%Y -d yesterday`

REPORT="${BASE}/wip/spoils_report-${DATE}.csv"
RECIPIENTS="CentrelinkVICITSupport@hpa.com.au,Centrelink.Management.Support@hpa.com.au"

############################################################

cd "${BASE}"

./run.sh spoils_report \
         `date +%d-%m-%y -d yesterday` \
         > "${REPORT}"

/usr/bin/perl -p -i.PRE-SUBTOTAL -e '
  BEGIN { $filename = $ARGV[0]; }
  ($job_env_name, $host_total) = (split /,/)[2,4];
  ($job_env, $job_name) = split /#/, $job_env_name;
  if ( defined $last_job_name &&
       $last_job_name ne $job_name ) {
    print ARGVOUT "TOTAL,,,,${total},\n";
    $total = 0;
  }
  $total += $host_total;
  $last_job_name = $job_name;
  END { open $fh, ">>", $filename;
        print $fh "TOTAL,,,,${total},\n";
        close $fh; 
        print "Updated: $filename\n"; }
  ' "${REPORT}"

cd

/usr/bin/mutt -a "${REPORT}" \
              -s "Centrelink - Spoils report for ${DATE}" \
              "${RECIPIENTS}" \
              < /dev/null


