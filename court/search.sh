#!/bin/sh

. $(dirname $0)/../config.sh

# show test courts
curl -s -XGET $COURTAPI_BASE_URL/courts/pacer?test=true

# Other examples:
# ---------------
# list all courts:
#   curl -s -XGET $COURTAPI_BASE_URL/courts/pacer
#
# Only bankruptcy test courts:
#   curl -s -XGET $COURTAPI_BASE_URL/courts/pacer?test=true&type=bankruptcy
#   "type" must be one of [district,national,bankruptcy,appellate]
