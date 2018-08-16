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

curl -s -XPOST $COURTAPI_BASE_URL/cases/pacer/$court/$case/claims/$claim_no/documents/$document_no/$part_no

# Example Response:
# {
#   "origin": "PACER",
#   "part": {
#     "action": "https://ecf-test.azb.uscourts.gov/doc2/02418759",
#     "case_uuid": "azbtest_2644",
#     "description_html": "Claim 51742-0",
#     "docket_no": "1-1.00000",
#     "download_url": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer/azbtest/2644/claims/1/1.00000/1-EEF7FF38-94D5-11E8-8A98-914CBE923E94?response-content-disposition=attachment%3B+filename%3DBankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf&AWSAccessKeyId=courtapi_dummy_key&Expires=1848669919&Signature=Dcpy2nFkCpdVm3nz7EpDrorUGuc%3D",
#     "filename": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
#     "friendly_name": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
#     "history_number": "1",
#     "number": 1,
#     "ocr_link": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer-ocr/pacer/azbtest/2644/claims/1/1.00000/1-EEF7FF38-94D5-11E8-8A98-914CBE923E94.txt?response-content-disposition=attachment%3B+filename%3DBankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf.txt&AWSAccessKeyId=courtapi_dummy_key&Expires=1848669919&Signature=den6tfPmBtUfhBgB0m3%2B8fpMs0I%3D",
#     "pages": 3,
#     "raw_location": "s3://inforuptcy-storage/pacer/azbtest/2644/claims/1/1.00000/1-EEF7FF38-94D5-11E8-8A98-914CBE923E94"
#   },
#   "receipt": {
#     "meta": {
#       "case_uuid": null,
#       "filename": "ee0c54ca-94d5-11e8-8a98-914cbe923e94",
#       "timestamp": null
#     },
#     "text": {
#       "client_code": "",
#       "cost": "0.30",
#       "criteria": "2:07-bk-00012-BMW",
#       "datetime": "Tue Jul 31 08:25:17 2018",
#       "description": "Claim 51742-0",
#       "pages": "3",
#       "user_id": "in2117info:3611309:0"
#     }
#   },
#   "status": "success"
# }
# 
