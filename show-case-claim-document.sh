#!/bin/sh

if [ $# -ne 4 ]; then
  echo "Usage: $0 <court code> <case number> <claim number> <document number>"
  exit 1
fi

. $(dirname $0)/config.sh

court="$1"
case="$2"
claim_no="$3"
document_no="$4"

# Note, if PACER update is required, you will get the following payload (no parts):
# {
#   "links": {
#     "pacer-update": {
#       "href": "http://courtapi.inforuptcy.dev.azk.io/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
#       "method": "POST"
#     }
#   },
#   "parts": []
# }

# Otherwise you get something like this:
# {
#   "links": {
#     "pacer-update": {
#       "href": "http://courtapi.inforuptcy.dev.azk.io/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
#       "method": "POST"
#     }
#   },
#   "parts": [
#     {
#       "cost": null,
#       "description_html": "Claim 51742-0",
#       "docket_no": null,
#       "filename": null,
#       "free": null,
#       "friendly_name": null,
#       "links": {
#         "order_pdf": {
#           "href": "http://courtapi.inforuptcy.dev.azk.io/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
#         }
#       },
#       "number": 1,
#       "pages": 3
#     }
#   ]
# }

curl -s -XGET $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/$claim_no/documents/$document_no
