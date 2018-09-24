#!/bin/sh
#
# Update a docket entry document part from PACER
#

if [ $# -ne 4 ]; then
  echo "Usage: $0 <court code> <case number> <docket seq> <document part>"
  exit 1
fi

. $(dirname $0)/../config.sh

court="$1"
case="$2"
docket_no="$3"
part="$4"

curl -s -XPOST $COURTAPI_BASE_URL/cases/pacer/$court/$case/dockets/$docket_no/documents/$part
