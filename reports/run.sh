#!/bin/sh

export ORACLE_HOME='/users/oracle/product/9.2.0'
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/users/oracle/product/9.2.0/lib"
export PATH="/users/oracle/product/9.2.0/bin:$PATH"

cd /users/bd6338/files/wip/reports

SCRIPT=$1
shift

sqlplus -SILENT clink/clink07@clink @$SCRIPT $* | perl -p -e 's/\s*,\s*/,/g'
