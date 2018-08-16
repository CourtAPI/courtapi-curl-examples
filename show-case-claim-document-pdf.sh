#!/bin/sh

if [ $# -ne 5 ]; then
  echo "Usage: $0 <court code> <case number> <claim number> <document number> <part number>"
  exit 1
fi

. $(dirname $0)/config.sh

court="$1"
case="$2"
claim_no="$3"
document_no="$4"
part_no="$5"

# XXX This payload is confusing. There sould be a 'pacer-update' link
# If pacer update is required, you get:

# {
#   "message": null,
#   "origin": "cache",
#   "part": {},
#   "status": "success"
# }

# Otherwise, you get:
curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/$claim_no/documents/$document_no/$part_no
