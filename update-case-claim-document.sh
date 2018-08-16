#!/bin/sh

if [ $# -ne 4 ]; then
  echo "Usage: $0 <court code> <case number> <claim number> <document number>"
  exit 1
fi

. $(dirname $0)/config.sh

court="$1"
case="$2"
claim_no="$3"
document_no="$4"

curl -s -XPOST $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/$claim_no/documents/$document_no
