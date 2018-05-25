#!/bin/bash

######################################################################
# Config values
#
# TWEAK THIS BITS FOR THE CORRECT MONTH PLEASE....
#
DATE='01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30';
MONTH='09';                              # MOTNH - IN 2 DIGIT (MM) FORMAT 
 YEAR='2006';                            # YEAR
EMAIL='eddy.tan@hpa.com.au';             # EMAIL TO SEND REPORT
 TEMP='/users/et6339/temp_daily_report'; # TEMP LOCATION


######################################################################
#####                                                           ######  
#####     do NOT modify anything after this comment line        ######
#####                                                           ######   
######################################################################

######################################################################
# Variable declaration
APP='/cmsdata/prod/client/app/bin/daily_report.pl';
STATE='nsw vic sa qld wa';

 MO[1]=january
 MO[2]=february
 MO[3]=march
 MO[4]=april
 MO[5]=may
 MO[6]=june
 MO[7]=july
 MO[8]=august
 MO[9]=september
MO[10]=october
MO[11]=november
MO[12]=december

######################################################################
# Function helper
strip_leading_zero () #  Better to strip possible leading zero(s)
{                     #+ from day and/or month
  return ${1#0}       #+ since otherwise Bash will interpret them
}                     #+ as octal values (POSIX.2, sect 2.9.2.1).

######################################################################
# Processing...

# make temp dir
mkdir $TEMP;
for s in $STATE; do
    mkdir $TEMP/$s;
done    

# Invoke perl script
for s in $STATE; do
    for d in $DATE; do
        echo $d-$MONTH-$YEAR - $s;
        `$APP -e PROD -s $s -em $EMAIL -d $d-$MONTH-$YEAR -u centrelink`;
        cd /cmsdata/prod/client/app/bin/daily_reports/old_reports/;
        cp hpa_centrelink_report_$YEAR$MONTH$d.$s.csv $TEMP/$s/;
    done
    
    # copy the latest file 
    cd /cmsdata/prod/client/app/bin/daily_reports/;
    cp hpa_centrelink_report_$YEAR$MONTH*.$s.csv $TEMP/$s/;
done

# concat the report files
for s in $STATE; do
    cd $TEMP/$s/;
    ALLREPORT=$( ls -1rt hpa_centrelink_report_$YEAR$MONTH*);
    strip_leading_zero $MONTH;
    MONTH=$?;
    cat $ALLREPORT > ${MO[$MONTH]}.$s.csv;
done

exit 0;
