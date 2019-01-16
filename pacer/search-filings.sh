#!/bin/sh
#
# Advanced Search Filings
#
# e.g.: search-filings.sh nysbke_247775
#

if [ $# -ne 1 ]; then
 echo "Usage: $0 <case_uuid>"
 exit 1
fi

. $(dirname $0)/../config.sh

case_uuid="$1"

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/search-filings?case_uuid=$case_uuid
