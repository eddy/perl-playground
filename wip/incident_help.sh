#!/bin/sh

#
# Temporary script on the path to enlightenment
# (or on the path to building the actual incident
# report process...
#

# column width for lists of values
COL_WIDTH=8

# Title column width
TITLE_WIDTH=22

echo --------------------------------------------------------------------------
echo

for JOB_NAME in $*
do
    # Gather data from QCS files
    QCS_FILES="*Q${JOB_NAME}*.txt"
    JSN_LIST=`perl -n -e '/JOB SEQUENCE NUMBER : (\S+)/ && print "$1 "' $QCS_FILES`
    NUM_LIST=`perl -n -e '/JOB NUMBER : (\S+)/ && print "$1 "' $QCS_FILES`
    BATCHNUM=`perl -n -e '/BATCH NUMBER : (\S+)/ && print "$1 "' $QCS_FILES`
    TOT_LIST=`perl -n -e '/HOST TOTAL : (\S+)/ && print "$1 "' $QCS_FILES`

    # Fail-over data gathering if the QCS files didn't help
    MSR_FILES="*#${JOB_NAME}*.txt"
    if [ "$JSN_LIST" = "" ]
    then
        JSN_LIST=`ls $MSR_FILES | cut -c 9 | xargs -i{} printf "{}?.? "`
    fi
    if [ "$NUM_LIST" = "" ]
    then
        NUM_LIST=`ls $MSR_FILES | cut -d . -f 4`
    fi
    if [ "$BATCHNUM" = "" ]
    then
        BATCHNUM=`perl -n -e '/ADVICES IN BATCH (\d+)/ && print "$1 "' $MSR_FILES`
    fi
    if [ "$TOT_LIST" = "" ]
    then
        TOT_LIST=`perl -n -e '/ADVICES IN BATCH \d+ =\s*(\d+)/
                                          && printf "%-8s", $1' $MSR_FILES`
    fi

    # Print a report
    printf "%-${TITLE_WIDTH}s : " Status
    echo Open

    printf "%-${TITLE_WIDTH}s : " "Job Sequence No"
    printf "%-${COL_WIDTH}s" $JSN_LIST
    echo

    printf "%-${TITLE_WIDTH}s : " "Job Name"
    echo $JOB_NAME

    printf "%-${TITLE_WIDTH}s : " "Job Number"
    printf "%-${COL_WIDTH}s"  $NUM_LIST
    echo

    printf "%-${TITLE_WIDTH}s : " "Batch Number"
    printf "%-${COL_WIDTH}s"  $BATCHNUM
    echo

    printf "%-${TITLE_WIDTH}s : " "Host Total"
    printf "%-${COL_WIDTH}s" $TOT_LIST
    echo

    printf "%-${TITLE_WIDTH}s : " "QCS required"
    echo 

    printf "%-${TITLE_WIDTH}s : " "Mailman Required"
    echo 

    printf "%-${TITLE_WIDTH}s : " "Data Required"
    echo 

    printf "%-${TITLE_WIDTH}s : " "Description of problem"
    echo

    printf "%-${TITLE_WIDTH}s : " "Files received"
    echo
    ls *${JOB_NAME}* | grep -v \.txt | sort -t . -k 4,3 \
        | while read FILENAME
          do
            printf "%-${TITLE_WIDTH}s   %s\n" " " "$FILENAME"
          done

    echo
    echo --------------------------------------------------------------------------
    echo
done
