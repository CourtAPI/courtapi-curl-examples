#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

. $(dirname $0)/config.sh

court="$1"
case="$2"

curl -s -XPOST $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/update
