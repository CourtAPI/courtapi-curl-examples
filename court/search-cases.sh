#!/bin/sh

. $(dirname $0)/../config.sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

court="$1"
case="$2"

# Lots of possibilities on what to search for.  This just shows cases filed a specific month
curl -s -XPOST $COURTAPI_BASE_URL/courts/pacer/$court/cases/search -d case_no="$case"
