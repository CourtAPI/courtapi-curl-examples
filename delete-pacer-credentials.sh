#!/bin/sh

. $(dirname $0)/config.sh

curl -s -XDELETE $COURTAPI_BASE_URL/pacer/credentials
