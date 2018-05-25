#!/bin/bash

# Find WA jobs processed overnight...
# Sort it...
# Then store in file: wa_jobs_yyyymmdd.txt
/users/et6339/centrelink.solution/bin/wa_overnight_job_list.pl  \
    | /users/et6339/centrelink.solution/bin/sort_wa_job.pl      \
    > /users/et6339/centrelink.solution/bin/wa_jobs_`date +%Y%m%d`.txt

# Convert to DOS format...    
unix2dos /users/et6339/centrelink.solution/bin/wa_jobs_`date +%Y%m%d`.txt



