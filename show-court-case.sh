#!/bin/sh

. $(dirname $0)/config.sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

court="$1"
case="$2"

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case
