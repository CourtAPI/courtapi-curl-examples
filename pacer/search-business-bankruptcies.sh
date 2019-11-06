#!/bin/sh
#
# Advanced Search Filings: Business Bankruptcies
#
# e.g.: search-business-cases.sh
#       search-business-cases.sh 10/15/2019
#

if [ $# -gt 1 ]; then
 echo "Usage: $0 [<date_filed_from>]"
 exit 1
fi

. $(dirname $0)/../config.sh

FILTERS='template=case_lookup&court_type=bankruptcy&business_cases=limit'
if [ "$1" ] ; then
  FILTERS="$FILTERS&date_filed_from=$1"
fi

# This will list the most recently updated business bankruptcies (optionally filed after the given date).
curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/search-filings?"$FILTERS"
