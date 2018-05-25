#!/bin/sh

BASE='/users/bd6338/files/wip/reports'

DATEARG=`date +%d-%m-%y -d yesterday`
DATE=`date +%d-%m-%Y -d yesterday`

REPORT="${BASE}/wip/sample_lodgement_report-${DATE}.csv"
RECIPIENTS="CentrelinkVICITSupport@hpa.com.au,Centrelink.Management.Support@hpa.com.au"

############################################################

cd "${BASE}"

./run.sh consolidated_jobs_daily_report \
         `date +%d-%m-%y -d yesterday` \
         > "${REPORT}"

cd

/usr/bin/mutt -a "${REPORT}" \
              -s "Centrelink - Sample lodgement report for ${DATE}" \
              "${RECIPIENTS}" \
              < /dev/null


