#!/bin/sh

if [ $# -ne 3 ]; then
  echo "Usage: $0 <court code> <case number> <claim number>"
  exit 1
fi

. $(dirname $0)/../config.sh

court="$1"
case="$2"
claim_no="$3"

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/$claim_no
