#!/bin/sh
#
# Show dockets header for a case
#
# e.g.: show-dockets-docket.sh orbtrain 3:14-bk-35575
#

if [ $# -ne 2 ]; then
  echo "Usage: $0 <court code> <case number>"
  exit 1
fi

. $(dirname $0)/../config.sh

court="$1"
case="$2"

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case/dockets/header
