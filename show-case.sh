#!/bin/sh

. $(dirname $0)/config.sh

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court id> <case number>"
  exit 1
fi

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$1/$2
