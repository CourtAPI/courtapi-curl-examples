#!/bin/sh
#
# Show docket entries for a case
#
# e.g.: show-case-docket.sh orbtrain 3:14-bk-35575
#
# This will show the first page of the docket
#

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

. $(dirname $0)/../config.sh

court="$1"
case="$2"

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case/dockets?sort_order=desc
