#!/bin/sh


. $(dirname $0)/config.sh

curl -s -XGET $COURTAPI_BASE_URL/pacer/credentials
