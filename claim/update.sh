#!/bin/sh

if [ $# -lt 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

. $(dirname $0)/../config.sh

court="$1"
case="$2"

if [ ! -z "$3" ]; then
  include_documents="$3"
else
  include_documents="0"
fi

curl -s -F include_documents="$include_documents" \
    -XPOST $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/update
