# Curl based CourtAPI Examples

This directory contains a set of Curl based scripts demonstrating how to accomplish:

- Locate a case in CourtAPI
- Purchase and display the docket sheet
- Purchase and display the claims register
- Download PDFs from the docket sheet and/or claims register

## Configuration

Configuration is handled by environment variables.  At a minimum, you must set
your CourtAPI `APP_ID` and `SECRET`.

```shell
 $ export COURTAPI_APP_ID="your-app-id"
 $ export COURTAPI_SECRET="your-secret"
```

For local examples, using `courtapi.inforuptcy.dev.azk.io`, you can use
anything for these.  For the training or live sites, you must use your real
values.  The default is to use the local dev environment.

Other possible settings can be seen in `config.sh`

## Manage your PACER credentials

Many operations require PACER credentials.  You need to save these in CourtAPI.
The following scripts demonstrate this functionality:

### Save PACER Credentials

Usage: `save-pacer-credentials.sh <PACER username> <PACER password>`

Endpoint: `POST /pacer/credentials`

Example:

```shell
  $ save-pacer-credentials.sh dummy test | jq
  {
    "app_id": "abc12345",
    "pacer_user": "dummy"
  }
```

### Show PACER Credentials

Usage: `show-pacer-credentials.sh`

Endpoint: `GET /pacer/credentials`

Example:

```shell
  $ show-pacer-credentials.sh | jq
  {
    "app_id": "abc12345",
    "pacer_user": "dummy"
  }

```

### Delete PACER Credentials

Usage: `delete-pacer-credentials.sh`

Endpoint: `DELETE /pacer/credentials`

Example:

```shell
  $ delete-pacer-credentials.sh | jq
  {
    "app_id": "abc12345",
    "pacer_user": "dummy",
    "status": "deleted"
  }
```

## Search or Display Courts

### Search for a Court

Usage `search-courts.sh`

Endpoint: `GET /courts/pacer`

This script displays all test courts.

You can also search for specific court types by specifying a `type` parameter
in the URL.  The `type` must be one of the following values:

- appellate
- bankruptcy
- district
- national

E.g.: `GET /courts/pacer?type=appellate`

Example:

```shell
  $ search_courts.sh | jq
  {
    "courts": [
      {
        "code": "akbtest",
        "links": {
          "self": {
            "href": "https://train.v1.courtapi.com/courts/pacer/akbtest"
          }
        },
        "name": "Alaska TEST Bankruptcy Court"
      },
      {
        "code": "akbtrain",
        "links": {
          "self": {
            "href": "https://train.v1.courtapi.com/courts/pacer/akbtrain"
          }
        },
        "name": "Alaska TRAIN Bankruptcy Court"
      },
      ...
    ]
  }
```

### Show a Specific Court

Usage `show-court.sh <court code>`

Endpoint: `GET /courts/pacer/{court}`

This script / endpoint displays details about a specific court.

Example:

```shell
  $ show-court.sh azbtest | jq
  {
    "abbr": "azbtest",
    "citation": "Bankr.D.Ariz.TEST",
    "links": {
      "cases_report_bk": {
        "href": "https://train.v1.courtapi.com/courts/pacer/azbtest/cases/report/bankruptcy"
      },
      "cases_search": {
        "href": "https://train.v1.courtapi.com/courts/pacer/azbtest/cases/search"
      }
    },
    "name": "Arizona TEST Bankruptcy Court",
    "subdomain": "ecf-test.azb.uscourts.gov",
    "timezone": "US/Arizona",
    "type": "bankruptcy"
  }
```

## Locate a Court Case

Once you have the court code (e.g.: `azbtest`), you can search for cases within
that court, or import a case from PACER.

### Search Court Cases

Usage: `search-court-cases.sh <court code> <case number>`

Endpoint: `POST /courts/pacer/{court}/cases/search`

This endpoint has several options for searching, but the example script just
searches for a specific case number.  See the CourtAPI documentation for other
search terms that could be used.

Example:

```shell
  $ search-court-cases.sh orbtrain 6:14-bk-63618 | jq
  {
    "cases": [
      {
        "case_no": "6:14-bk-63618",
        "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
        "chapter": 7,
        "court_code": "orbtrain",
        "date_closed": null,
        "date_filed": "10/15/2014",
        "lead_bk_case_no": null,
        "lead_bk_case_title": null,
        "links": {
          "dockets": {
            "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets"
          },
          "self": {
            "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618"
          }
        },
        "timestamp": 1533058495.07583,
        "title": "Joseph Wayne Sample and Sarah Lynn Sample"
      }
    ],
    "parties": [],
    "receipts": []
  }
```

### Show a Specific Court Case

Endpoint: `GET /cases/pacer/{court}/{case}`

This uses the CourtAPI endpoint `GET /cases/pacer/{court}/{case}`

For this example, you need a court code (e.g. `orbtrain`) and a case number
(e.g.: `6:14-bk-63618`).

For all CourtAPI endpoints that use a case number in the URL, long format case
numbers must be used.  That is, case numbers must be in the format
`o:yy-tp-nnnnn` where `o` is a single digit representing the office where the
case was filed, `yy` is the 2 digit year when the case was filed, `tp` is the
case type (up to 2 characters), and `nnnnn` is the case number (up to 5
digits).

Show a case that has not been imported from PACER yet:

```shell
  $ show-court-case.sh orbtrain 6:14-bk-63618 | jq
  {
    "error": "No Matching Case Found for 6:14-bk-63618 at orbtrain"
  }
```

If you get the above error for a case, you need to use the search example above
to import it from PACER first.

Show a case that has been imported from PACER:

```shell
  $ show-court-case.sh orbtrain 6:14-bk-63618 | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": null,
      "case_chapter_id": 1,
      "case_court_id": 221,
      "case_id": 5085876,
      "case_id_external": 458895,
      "case_no": "6:14-bk-63618",
      "case_petition_id": null,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "case_uuid": "orbtrain_458895",
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 7,
      "citation": "Bankr.D.Or.TRAIN.",
      "court": "orbtrain",
      "court_name": "orbtrain",
      "created": "2018-07-31 16:44:36.671892+00",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/1914",
      "date_of_last_filing": null,
      "date_plan_confirmed": null,
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": null,
      "industry": null,
      "is_business_bankruptcy": null,
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "liabilities": "Unknown",
      "modified": "2018-07-31 16:47:09.663273+00",
      "naics_code": null,
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "referred_to": null,
      "timestamp": 1533055629.66327,
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85063766,
      "website": null
    },
    "links": {
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618"
      }
    }
  }
```

## Purchase and Display Case Docket Sheet

Next, we will use the curl examples to purchase and display the docket sheet.

### Show Docket Entries

Usage: `show-case-docket.sh <court code> <case number>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets`

The docket entries are located at `GET /cases/pacer/{court}/{case}/dockets`.
Here, we fetch the dockets endpoint and see that there are no entries yet.
This means we need to update the docket entries from PACER, using the
`pacer-update` link that is provided in the response.

```shell
  $ show-case-docket.sh orbtrain 6:14-bk-63618 | jq
  {
    "entries": {
      "content": [],
      "links": {
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc&page_size=10&page_number=1"
        }
      },
      "page_size": 10,
      "total_items": 0,
      "total_pages": 1
    },
    "header": {
      "html": null,
      "timestamp": null
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc"
      }
    }
  }
```

### Purchase Docket Entries

Usage `buy-case-docket-sheet.sh <court code> <case number>`

Endpoint: `POST /cases/pacer/{court}/{case}/dockets`

This uses the `POST /cases/pacer/{court}/{case}/dockets/update` endpoint to
update the docket entries for a case.  The response is quite long and detailed.

```shell
  $ buy-case-docket-sheet.sh orbtrain 6:14-bk-6361 | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": " ",
      "case_chapter_id": 1,
      "case_court_id": 221,
      "case_id": 5083526,
      "case_id_external": 458895,
      "case_no": "6:14-bk-63618",
      "case_petition_id": 1,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "case_uuid": "orbtrain_458895",
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 7,
      "court": "orbtrain",
      "court_name": "orbtrain",
      "created": "2018-07-31 17:34:55.075826+00",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/2014",
      "date_of_last_filing": null,
      "date_plan_confirmed": null,
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": 0,
      "industry": null,
      "is_business_bankruptcy": 0,
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "liabilities": "Unknown",
      "modified": "2018-07-31 17:44:57.600539+00",
      "naics_code": null,
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": 1533059097.60054,
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055151,
      "website": null
    },
    "forms": {
      "case_code": "6-14-bk-63618",
      "date_from": null,
      "date_to": null,
      "date_type": "filed",
      "doc_from": null,
      "doc_to": null,
      "show_terminated": 1
    },
    "items": {
      "docket_headers": [
        {
          "meta": {
            "case_uuid": "orbtrain_458895",
            "filename": "<filename_is_ignored>",
            "timestamp": 1533059096.13301
          },
          "text": "... [docket header html] ..."
        }
      ],
      "dockets": [
        {
          "case_uuid": "orbtrain_458895",
          "date_filed": "10/15/2014",
          "docket_no": "1",
          "docket_seq": 0,
          "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
          "docket_uri": "https://ecf-train.orb.uscourts.gov/doc3/150014371924",
          "filename": "orbtrain_458895_1_0",
          "timestamp": 1533059096.13301,
          "title": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)"
        }
      ],
      "headers": [
        {
          "meta": {
            "case_uuid": "orbtrain_458895",
            "filename": "orbtrain_458895",
            "timestamp": 1533059096.13301
          },
          "text": {
            "case_code": null,
            "case_title": null,
            "case_type": null,
            "case_uuid": "orbtrain_458895",
            "chapter": null,
            "has_asset": null,
            "title": null
          }
        },
        {
          "meta": {
            "case_uuid": "orbtrain_458895",
            "filename": "orbtrain_458895",
            "timestamp": 1533059096.13301
          },
          "text": {
            "assigned_to": " ",
            "case_uuid": "orbtrain_458895",
            "chapter": "7",
            "date_filed": "10/15/2014",
            "has_asset": 1,
            "voluntary": 1
          }
        }
      ],
      "receipts": [
        {
          "meta": {
            "case_uuid": "orbtrain_458895",
            "filename": "70d0b69a-94e9-11e8-98ae-f7223abbf895",
            "timestamp": 1533059096.13301
          },
          "text": {
            "client_code": "",
            "cost": "0.10",
            "criteria": "14-63618-7 Fil or Ent: filed Doc From: 0 Doc To: 99999999 Term: included Links : included Format: html Page counts for documents: included",
            "datetime": "07/31/2018 10:44:57",
            "description": "Docket Report",
            "pages": "1",
            "user_id": "irtraining"
          }
        }
      ]
    },
    "queries": {
      "docket_headers": [
        {
          "meta": {
            "case_uuid": "orbtrain_458895",
            "filename": "orbtrain_458895_11b8fd7c9d5249ba5b64af8cb52f8459",
            "timestamp": 1533059096.13301
          },
          "text": {
            "attorneys": [
              {
                "associated": [
                  {
                    "address": "PO Box 123\nPortland, OR 97204\nMULTNOMAH-OR",
                    "name": "Joseph Wayne Sample",
                    "role": "Debtor"
                  }
                ],
                "attorney": {
                  "address": "630 Lincoln St\nEugene, OR 97401\nFax : OBO 1/27/2014",
                  "name": "CHARLES H. VINCENT",
                  "phone": "541-687-6765"
                }
              },
              {
                "associated": [
                  {
                    "address": "PO Box 123\nPortland, OR 97204\nMULTNOMAH-OR\nfka Sarah Lynn Smith",
                    "name": "Sarah Lynn Sample",
                    "role": "Joint Debtor",
                    "ssn": "xxx-xx-1298"
                  }
                ],
                "attorney": {
                  "address": "630 Lincoln St\nEugene, OR 97401\nFax : OBO 1/27/2014",
                  "name": "CHARLES H. VINCENT"
                }
              }
            ],
            "trustees": []
          }
        }
      ]
    }
  }
```

### Display Docket Entries

Endpoint: `GET /cases/pacer/{court}/{case}/dockets`

Now that the docket entries have been update from PACER, we can show the docket
entries again, and this time the `entries` in the response will contain the
docket entries.

Note that the `response.entries.content` is a paged result set, and if the
`total_pages` is greater than 1, then you will need to call this endpoint
repeatedly, using the `entries.content.links.next.href` location to fetch all
of the docket entries.  You could also use a larger `page_size` query parameter
to fetch more docket entries in the same request.  For each docket entry, the
`documents` and `self` links refer to the endpoints to get the documents or the
link to this specific docket entry, respectively.

```shell
  $ show-case-docket.sh orbtrain 6:14-bk-63618 | jq
  {
    "entries": {
      "content": [
        {
          "annotations": [],
          "case_uuid": "orbtrain_458895",
          "date_filed": "10/15/2014",
          "docket_no": 1,
          "docket_seq": "1.00000",
          "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
          "docket_uri": 85055152,
          "links": {
            "documents": {
              "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents"
            },
            "self": {
              "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
            }
          },
          "timestamp": 1533059097.61991
        }
      ],
      "links": {
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc&page_size=10&page_number=1"
        }
      },
      "page_size": 10,
      "total_items": 1,
      "total_pages": 1
    },
    "header": {
      "html": "... [ docket header html ] ...",
      "timestamp": 1533059097.60054
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc"
      }
    }
  }
```

### Show a Specific Docket Entry

Usage `show-docket-entry.sh <court code> <case number> <docket number>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}`

This just shows a single specific docket entry.  It is the `self` url from an
entry in the list of docket entries.

Example:

```shell
  $ show-docket-entry.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "entry": {
      "action": "https://ecf-train.orb.uscourts.gov/doc3/150014371924",
      "annotations": [],
      "case_docket_entry_id": 81274893,
      "case_uuid": "orbtrain_458895",
      "date_filed": "10/15/2014",
      "docket_no": 1,
      "docket_seq": "1.00000",
      "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
      "docket_uri": 85055152,
      "links": {
        "documents": {
          "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents"
        },
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
        }
      },
      "timestamp": 1533059097.61991
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
      }
    }
  }
```

## Get Documents for a Docket Entry

Usage: `show-docket-entry-documents.sh <court code> <case number> <docket seq>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents`

For each docket entry that we are interseted in, the documents are at the
`GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents` endpoint.  This
is in the previous response at the `entry.links.documents.href` location.

Example:

```shell
  $ show-docket-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    },
    "parts": []
  }
```

There are no entries available, so we need to do a POST to the `pacer-update`
link to get the list of documents.  Note that some docket entries will not have
any documents.

```shell
  $ update-docket-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    },
    "parts": [
      {
        "cost": null,
        "description_html": null,
        "docket_no": 1,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
          }
        },
        "number": 1,
        "pages": 7
      }
    ]
  }
```

And now we can show the documents again:

```shell
  $ show-docket-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    },
    "parts": [
      {
        "cost": null,
        "description_html": null,
        "docket_no": 1,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.v1.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
          }
        },
        "number": 1,
        "pages": 7
      }
    ]
  }
```

The next step is to follow the `order_pdf` link.  The `show-docket-entry-pdf.sh` script will do that for us:

Usage: `show-docket-entry-pdf.sh <court code> <case number> <docket seq> <document part>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents/{part}`

Example:
```shell
  $ show-docket-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "message": null,
    "origin": "cache",
    "part": {},
    "status": "success"
  }
```

Because the `part` is empty, we need to POST to the document part URL to
purchase the document from PACER.

The `update-docket-entry-pdf.sh` script will do this. It uses the CourtAPI
endpoint
`POST /cases/pacer/{court}/{case}/dockets/{docket_no}/documents/{part}` to do this.

```shell
  $ update-docket-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "origin": "PACER",
    "part": {
      "action": "https://ecf-train.orb.uscourts.gov/doc3/150114371924?caseid=458895",
      "case_uuid": "orbtrain_458895",
      "cost": null,
      "description_html": null,
      "docket_no": "1.00000",
      "download_url": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer/orbtrain/458895/dockets/1.00000/1-EC7FCFDA-94EC-11E8-98AE-F7223ABBF895?response-content-disposition=attachment%3B+filename%3DBankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf&AWSAccessKeyId=courtapi_dummy_key&Expires=1848679793&Signature=MQHl%2FVbQo8gjQ4fwos0eM97y13w%3D",
      "filename": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "free": null,
      "friendly_name": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "number": 1,
      "ocr_link": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer-ocr/pacer/orbtrain/458895/dockets/1.00000/1-EC7FCFDA-94EC-11E8-98AE-F7223ABBF895.txt?response-content-disposition=attachment%3B+filename%3DBankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf.txt&AWSAccessKeyId=courtapi_dummy_key&Expires=1848679793&Signature=o18SEoXK0AUdiryGkR%2BJay4hCK0%3D",
      "pages": 7,
      "raw_location": "s3://inforuptcy-storage/pacer/orbtrain/458895/dockets/1.00000/1-EC7FCFDA-94EC-11E8-98AE-F7223ABBF895",
      "sequence_number": "1.00000"
    },
    "receipt": {
      "meta": {
        "case_uuid": null,
        "filename": "eb800604-94ec-11e8-98ae-f7223abbf895",
        "timestamp": null
      },
      "text": {
        "client_code": "",
        "cost": "0.70",
        "criteria": "14-63618-7",
        "datetime": "Tue Jul 31 11:09:51 2018",
        "description": "Image:1-0",
        "pages": "7",
        "user_id": "irtraining"
      }
    },
    "status": "success"
  }
````

From this response, we have everything needed to save the PDF locally.  Note
that we received a receipt from PACER in the response indicating the
pass through charge amount. We can fetch the PDF at the `part.download_url`
location, and use the `part.filename` or `part.friendly_name` to save it
locally.  The `GET` endpoint now will return the same information:

```shell
  $ show-docket-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "origin": "cache",
    "part": {
      "cost": null,
      "description_html": null,
      "download_url": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer/orbtrain/458895/dockets/1.00000/1-EC7FCFDA-94EC-11E8-98AE-F7223ABBF895?response-content-disposition=attachment%3B+filename%3DBankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf&AWSAccessKeyId=courtapi_dummy_key&Expires=1848680027&Signature=sr264y47QN7qbCckWTrS4kfiOmc%3D",
      "filename": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "friendly_name": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "number": 1,
      "pages": 7
    },
    "status": "success"
  }
```

Note that the origin here is `cache` and there were no PACER fees incurred for
the request this time.  Again, simply fetch the PDF from the
`part.download_url` location, saving as whatever you prefer (or, use
`part.filename` or `part.friendly_name`).

## Purchase and Display a Claims Register

If you have a court code and case number, the following examples show how to
purchase the claims register and any documents you are interested in for the
case.

### Search for the Case.

This is exactly the same as the docket sheet example.

E.g.: `search-court-cases.sh azbtest 2:07-bk-00012`

### Show Claims

Usage: `list-case-claims.sh <court> <case number>`

Endpoint: `GET /cases/pacer/{court}/{case}/claims` endpoint.

Example:
```shell
  $ list-case-claims.sh azbtest 2:07-bk-00012
  {
    "claimed_amounts": {
      "admin_claimed": "0.00",
      "amount_claimed": "0.00",
      "priority_claimed": "0.00",
      "secured_claimed": "0.00",
      "unknown_claimed": "0.00",
      "unsecured_claimed": "0.00"
    },
    "entries": {
      "content": [],
      "links": {
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims?page_size=10&page_number=1"
        }
      },
      "page_size": 10,
      "total_items": 0,
      "total_pages": 1
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims"
      }
    }
  }
```

We can see that `entries.content` is empty, so we need to use the
`links.pacer-update` endpoint to purchase the claims register from PACER.
`update-case-claims.sh` will make this request for us (PACER pass through
charges apply)

```shell
  $ update-case-claims.sh azbtest 2:07-bk-00012 | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": null,
      "case_chapter_id": null,
      "case_court_id": 107,
      "case_id": 5083528,
      "case_id_external": 2644,
      "case_no": "2:07-bk-00012",
      "case_petition_id": null,
      "case_title": "TST Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "case_uuid": "azbtest_2644",
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": null,
      "court": "azbtest",
      "court_name": "azbtest",
      "created": "2018-07-31 18:38:17.36255+00",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": null,
      "date_of_last_filing": null,
      "date_plan_confirmed": null,
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": null,
      "industry": null,
      "is_business_bankruptcy": null,
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "liabilities": "Unknown",
      "modified": "2018-07-31 18:42:26.124362+00",
      "naics_code": null,
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": 1533062546.12436,
      "title": "TST Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055163,
      "website": null
    },
    "forms": {
      "case_code": "2-07-bk-12",
      "creditor_name": null,
      "creditor_no": null,
      "creditor_type": null,
      "date_from": null,
      "date_to": null,
      "date_type": null,
      "doc_from": null,
      "doc_to": null
    },
    "items": {
      "claim_headers": [
        {
          "meta": {
            "case_uuid": "azbtest_2644",
            "filename": "azbtest_2644",
            "timestamp": 1533062545.22225
          },
          "text": {
            "header": "... [ header html ] ...",
            "summary": "... [ summary HTML ] ..."
          }
        }
      ],
      "claims": [
        {
          "meta": {
            "case_uuid": "azbtest_2644",
            "claim_no": "1",
            "filename": "azbtest_2644_1",
            "timestamp": 1533062545.22225
          },
          "text": {
            "amounts": {
              "admin": {},
              "amount": {
                "claimed": "$160.00"
              },
              "priority": {},
              "secured": {},
              "unknown": {},
              "unsecured": {
                "claimed": "$160.00"
              }
            },
            "creditor": "Bloomingdales\nPO Box 8745\nNew York NY 10012-8745",
            "description": "(1-1) test<BR>",
            "history": [
              {
                "case_uuid": "azbtest_2644",
                "claim_date": "06/11/2007",
                "claim_history_no": 1,
                "claim_no": "1-1",
                "claim_seq": 0,
                "claim_text": "Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
                "claim_uri": "https://ecf-test.azb.uscourts.gov/cgi-bin/show_doc.pl?caseid=2644&claim_id=51742&claim_num=1-1&magic_num=MAGIC",
                "detail_uri": "https://ecf-test.azb.uscourts.gov/cgi-bin/ClaimHistory.pl?2644,1-1,1064,2:07-bk-00012-BMW"
              }
            ],
            "info": {
              "claim_no": "1",
              "original_entered_date": "06/11/2007",
              "original_filed_date": "06/11/2007"
            },
            "remarks": null,
            "status": {
              "entered_by": "Cindy Fouche",
              "filed_by": "CR",
              "modified": "11/15/2007"
            }
          }
        }
      ],
      "receipts": [
        {
          "meta": {
            "case_uuid": "azbtest_2644",
            "filename": "azbtest_2644",
            "timestamp": 1533062545.22225
          },
          "text": {
            "client_code": "",
            "cost": "0.10",
            "criteria": "2:07-bk-00012-BMW",
            "datetime": "07/31/2018 11:42:26",
            "description": "Claims Register",
            "pages": "1",
            "user_id": "paceruser:3611309:0"
          }
        }
      ]
    },
    "queries": {}
  }
```

Note that there is a receipt for the claims register purchase in the response.
Now we can re-run the `GET` request to show the claims register:

```shell
  $ list-case-claims.sh azbtest 2:07-bk-00012 | jq
  {
    "claimed_amounts": {
      "admin_claimed": "0.00",
      "amount_claimed": "160.00",
      "priority_claimed": "0.00",
      "secured_claimed": "0.00",
      "unknown_claimed": "0.00",
      "unsecured_claimed": "160.00"
    },
    "entries": {
      "content": [
        {
          "amounts": {
            "amount": {
              "claimed": "160.00"
            },
            "unsecured": {
              "claimed": "160.00"
            }
          },
          "creditor": "Bloomingdales\nPO Box 8745\nNew York NY 10012-8745",
          "description": "(1-1) test<BR>",
          "history": [
            {
              "action": "https://ecf-test.azb.uscourts.gov/cgi-bin/show_doc.pl?caseid=2644&claim_id=51742&claim_num=1-1&magic_num=MAGIC",
              "case_uuid": "azbtest_2644",
              "claim_date": "06/11/2007",
              "claim_no": "1-1",
              "claim_seq": "1-1.00000",
              "claim_text": "06/11/2007 Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
              "claim_uri": null,
              "detail_uri": null,
              "links": {
                "documents": {
                  "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000"
                }
              }
            }
          ],
          "info": {
            "claim_no": 1,
            "original_entered_date": "06/11/2007",
            "original_filed_date": "06/11/2007",
            "timestamp": 1533062546.14804
          },
          "links": {
            "self": {
              "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
            }
          },
          "remarks": null,
          "status": null
        }
      ],
      "links": {
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims?page_size=10&page_number=1"
        }
      },
      "page_size": 10,
      "total_items": 1,
      "total_pages": 1
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims"
      }
    }
  }
```

Just like case docket entries, claims register entries are paged, and if
`entries.total_pages` is greater than 1, you must fetch all of the pages by
following the `entries.links.next.href` for each result until you have fetched
all of the pages.  In this case, there is only one page, so the
`entries.links.next.href` is not present.

### Display A Specific Claim

Endpoint: `GET /cases/pacer/{court}/{case}/claims/{claim_no}`

This will display a specific claim from the claims register.

Usage: `show-case-claim.sh <court code> <case number> <claim number>`

Example:

```shell
  $ show-case-claim.sh azbtest 2:07-bk-00012 1 | jq
  {
    "entry": {
      "amounts": {
        "amount": {
          "claimed": "160.00"
        },
        "unsecured": {
          "claimed": "160.00"
        }
      },
      "creditor": "Bloomingdales\nPO Box 8745\nNew York NY 10012-8745",
      "description": "(1-1) test<BR>",
      "history": [
        {
          "action": "https://ecf-test.azb.uscourts.gov/cgi-bin/show_doc.pl?caseid=2644&claim_id=51742&claim_num=1-1&magic_num=MAGIC",
          "case_uuid": "azbtest_2644",
          "claim_date": "06/11/2007",
          "claim_no": "1-1",
          "claim_seq": "1-1.00000",
          "claim_text": "06/11/2007 Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
          "claim_uri": null,
          "detail_uri": null,
          "links": {
            "documents": {
              "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000"
            }
          }
        }
      ],
      "info": {
        "claim_no": 1,
        "original_entered_date": "06/11/2007",
        "original_filed_date": "06/11/2007",
        "timestamp": 1533062546.14804
      },
      "links": {
        "self": {
          "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
        }
      },
      "remarks": null,
      "status": null
    },
    "links": {
      "header": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "self": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
      }
    }
  }
```

### Purchase and Download a Claims Register Entry PDF

Endpoint: `GET /cases/pacer/{court}/{case}/claims/{claim_no}/documents/{document_no}`

Usage: `show-case-claim-document.sh <court code> <case number> <claim number> <document number>`

Now we will purchase and download the documents for this claim register entry.

`show-case-claim-document.sh` will make this request for us.

Example:
```shell
  $ show-case-claim-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    },
    "parts": []
  }
```

There are no parts present, so we need to update the documents from PACER by
using the `links.pacer-update` endpoint.  `update-case-claim-document.sh` will
make this request for us (it takes the same args as
`show-case-claim-document.sh`).

```shell
  $ update-case-claim-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    },
    "parts": [
      {
        "cost": null,
        "description_html": "Claim 51742-0",
        "docket_no": null,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
          }
        },
        "number": 1,
        "pages": 3
      }
    ]
  }
```

And now we can show the claims document again by using the `GET` method:

```shell
  $ show-case-claim-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "links": {
      "pacer-update": {
        "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    },
    "parts": [
      {
        "cost": null,
        "description_html": "Claim 51742-0",
        "docket_no": null,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.v1.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
          }
        },
        "number": 1,
        "pages": 3
      }
    ]
  }
```

The next step is to follow the `links.order_pdf` for each `parts` entry.  This uses the CourtAPI endpoint
`GET /cases/pacer/{court}/{case}/claims/{claim_no}/documents/{document_no}/{part_no}` endpoint.

```shell
  $ show-case-claim-document-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "message": null,
    "origin": "cache",
    "part": {},
    "status": "success"
  }
```

Note that the `part` field is empty.

We have to `POST` to the same endpoint to purchase the PDF.

Example:

```shell
  $ buy-case-claim-document-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "origin": "PACER",
    "part": {
      "action": "https://ecf-test.azb.uscourts.gov/doc2/02418759",
      "case_uuid": "azbtest_2644",
      "description_html": "Claim 51742-0",
      "docket_no": "1-1.00000",
      "download_url": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer/azbtest/2644/claims/1/1.00000/1-12B88492-94F4-11E8-98AE-F7223ABBF895?response-content-disposition=attachment%3B+filename%3DBankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf&AWSAccessKeyId=courtapi_dummy_key&Expires=1848682864&Signature=d0HxjSozTl4yeeWoSjbzmcqGDKg%3D",
      "filename": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "friendly_name": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "history_number": "1",
      "number": 1,
      "ocr_link": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer-ocr/pacer/azbtest/2644/claims/1/1.00000/1-12B88492-94F4-11E8-98AE-F7223ABBF895.txt?response-content-disposition=attachment%3B+filename%3DBankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf.txt&AWSAccessKeyId=courtapi_dummy_key&Expires=1848682864&Signature=xwrmK0jA2Dsnapev8U7fZgPFTHs%3D",
      "pages": 3,
      "raw_location": "s3://inforuptcy-storage/pacer/azbtest/2644/claims/1/1.00000/1-12B88492-94F4-11E8-98AE-F7223ABBF895"
    },
    "receipt": {
      "meta": {
        "case_uuid": null,
        "filename": "121214f4-94f4-11e8-98ae-f7223abbf895",
        "timestamp": null
      },
      "text": {
        "client_code": "",
        "cost": "0.30",
        "criteria": "2:07-bk-00012-BMW",
        "datetime": "Tue Jul 31 12:01:03 2018",
        "description": "Claim 51742-0",
        "pages": "3",
        "user_id": "test:3611309:0"
      }
    },
    "status": "success"
  }
```

At this point, you can fetch the PDF from the `part.download_url` location, and
save it at the location of your choice, or, use the `part.filename` or
`part.friendly_name` suggested filenames.  Note that we have a `receipt` for
the PACER pass through charges.

We can re-fetch the PDF endpoint using the `GET` method for no charge:

```shell
  $ show-case-claim-document-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "origin": "cache",
    "part": {
      "cost": null,
      "description_html": "Claim 51742-0",
      "download_url": "http://aws-s3.inforuptcy.dev.azk.io:32799/inforuptcy-storage/pacer/azbtest/2644/claims/1/1.00000/1-12B88492-94F4-11E8-98AE-F7223ABBF895?response-content-disposition=attachment%3B+filename%3DBankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf&AWSAccessKeyId=courtapi_dummy_key&Expires=1848683017&Signature=VZHSa9y4pERSNVhF%2BrWK0IQmn%2FE%3D",
      "filename": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "friendly_name": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "number": 1,
      "pages": 3
    },
    "status": "success"
  }
```

Note that there are no charges this time, and the `part.download_url` is
available showing where to fetch the PDF.
