#!/bin/bash
if [[ "$1" == "" ]]; then
echo "Usage: $0 <module-name>"
  exit 1
fi

perl -MDevel::EndStats=verbose,1 -M$1 -e1

