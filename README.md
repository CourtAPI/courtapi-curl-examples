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

For local examples, using `train.v1.courtapi.com`, you can use
anything for these.  For the training or live sites, you must use your real
values.  The default is to use the local dev environment.

Other possible settings can be seen in `config.sh`

## Manage your PACER credentials

Many operations require PACER credentials.  You need to save these in CourtAPI.
The following scripts demonstrate this functionality:

### Save PACER Credentials

Usage: `./pacer/save-credentials.sh <PACER username> <PACER password>`

Endpoint: `POST /pacer/credentials`

Example:

```shell
  $ ./pacer/save-credentials.sh test secret | jq
  {
    "app_id": "25ed3872",
    "pacer_user": "test"
  }
```

### Show PACER Credentials

Usage: `./pacer/show-credentials.sh`

Endpoint: `GET /pacer/credentials`

Example:

```shell
  $ ./pacer/show-credentials.sh | jq
  {
    "app_id": "abc12345",
    "pacer_user": "test"
  }
```

### Delete PACER Credentials

Usage: `delete-pacer-credentials.sh`

Endpoint: `DELETE /pacer/credentials`

Example:

```shell
  $ ./pacer/delete-credentials.sh | jq
  {
    "app_id": "abc12345",
    "pacer_user": "test",
    "status": "deleted"
  }
```

## Search or Display Courts

### Search for a Court

Usage `./court/search.sh`

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
  $ ./court/search.sh | jq
  {
    "courts": [
      {
        "code": "akbtest",
        "links": {
          "self": {
            "href": "https://train.vi.courtapi.com/courts/pacer/akbtest"
          }
        },
        "name": "Alaska TEST Bankruptcy Court"
      },
      {
        "code": "akbtrain",
        "links": {
          "self": {
            "href": "https://train.vi.courtapi.com/courts/pacer/akbtrain"
          }
        },
        "name": "Alaska TRAIN Bankruptcy Court"
      },
      ...
    ]
  }
```

### Show a Specific Court

Usage `./court/show.sh <court code>`

Endpoint: `GET /courts/pacer/{court}`

This script / endpoint displays details about a specific court.

Example:

```shell
  $ ./court/show.sh azbtest | jq
  {
    "abbr": "azbtest",
    "citation": "Bankr.D.Ariz.TEST",
    "links": {
      "cases_report_bk": {
        "href": "https://train.vi.courtapi.com/courts/pacer/azbtest/cases/report/bankruptcy"
      },
      "cases_search": {
        "href": "https://train.vi.courtapi.com/courts/pacer/azbtest/cases/search"
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

Usage: `./court/search-cases.sh <court code> <case number>`

Endpoint: `POST /courts/pacer/{court}/cases/search`

This endpoint has several options for searching, but the example script just
searches for a specific case number.  See the CourtAPI documentation for other
search terms that could be used.

Example:

```shell
  $ ./court/search-cases.sh orbtrain 6:14-bk-63618 | jq
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
            "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets"
          },
          "self": {
            "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618"
          }
        },
        "timestamp": "2018-09-24T17:37:18.440870Z",
        "title": "Joseph Wayne Sample and Sarah Lynn Sample"
      }
    ],
    "parties": [],
    "receipts": []
  }
```

### Show a Specific Court Case

Usage: `./court/show-case.sh <court code> <case number>`

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
  $ ./court/show-case.sh orbtrain 6:14-bk-63618 | jq
  {
    "error": "No Matching Case Found for 6:14-bk-63618 at orbtrain"
  }
```

If you get the above error for a case, you need to use the search example above
to import it from PACER first.

Show a case that has been imported from PACER:

```shell
  $ ./court/show-case.sh orbtrain 6:14-bk-63618 | jq
  {
    "case": {
      "assets": "Unknown",
      "assigned_to": null,
      "case_category": "bankruptcy",
      "case_no": "6:14-bk-63618",
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type": "bk",
      "cause": null,
      "ch11_type": null,
      "chapter": 7,
      "court_code": "orbtrain",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/2014",
      "date_of_last_filing": "10/15/2014",
      "date_terminated": null,
      "disposition": null,
      "has_asset": "No",
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "modified": "2018-09-24T17:37:18.440870Z",
      "nature_of_suit_code": null,
      "petition_type": "v",
      "plan_confirmed": null,
      "referred_to": null
    },
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618"
      }
    },
    "menu": {}
  }
```

## Purchase and Display Case Docket Sheet

Next, we will use the curl examples to purchase and display the docket sheet.

### Show Docket Entries

Usage: `./docket/list.sh <court code> <case number>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets`

The docket entries are located at `GET /cases/pacer/{court}/{case}/dockets`.
Here, we fetch the dockets endpoint and see that there are no entries yet.
This means we need to update the docket entries from PACER, using the
`pacer-update` link that is provided in the response.

```shell
  $ ./docket/list.sh orbtrain 6:14-bk-63618 | jq
  {
    "entries": {
      "content": [],
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc&page_size=500&page_number=1"
        }
      },
      "page_size": 500,
      "total_items": 0,
      "total_pages": 1
    },
    "header": {
      "attorneys": [],
      "header_html_timestamp": null,
      "html": null,
      "is_header_html_valid": null,
      "latest_docket_number": null,
      "latest_history_number": null,
      "latest_known_date_filed": null,
      "modified": null,
      "trustees": []
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc"
      }
    }
  }
```

### Purchase Docket Entries

Usage `./docket/update.sh <court code> <case number>`

Endpoint: `POST /cases/pacer/{court}/{case}/dockets`

This uses the `POST /cases/pacer/{court}/{case}/dockets/update` endpoint to
update the docket entries for a case.  The response is quite long and detailed.

```shell
  $ ./docket/update.sh orbtrain 6:14-bk-6361 | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": " ",
      "case_chapter_id": 1,
      "case_court_id": 221,
      "case_id_external": 458895,
      "case_no": "6:14-bk-63618",
      "case_petition_id": 1,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 7,
      "court": "orbtrain",
      "court_name": "orbtrain",
      "created": "2018-09-24T17:37:18.440872Z",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/2014",
      "date_of_last_filing": null,
      "date_plan_confirmed": null,
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": 0,
      "is_business_bankruptcy": 0,
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-6361"
        }
      },
      "modified": "2018-09-24T17:47:48.121075Z",
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": "2018-09-24T17:47:48.121070Z",
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055150
    },
    "dockets": [
      {
        "annotations": [],
        "date_filed": "10/15/2014",
        "docket_no": 1,
        "docket_seq": 0,
        "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
        "has_pdf_link_on_pacer": true,
        "sequence_number": "1.00000",
        "timestamp": "2018-09-24T17:47:46.594939Z",
        "title": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)"
      }
    ],
    "receipts": {
      "client_code": "",
      "cost": "0.10",
      "criteria": "14-63618-7 Fil or Ent: filed Doc From: 0 Doc To: 99999999 Term: included Format: html Page counts for documents: included",
      "datetime": "09/24/2018 10:47:47",
      "description": "Docket Report",
      "pages": "1",
      "timestamp": "2018-09-24T17:47:46.594939Z",
      "user_id": "testing"
    }
  }
```

There are many options that could be passed to the docket update endpoint.  One
very useful option for this example would be to request all of the document
information to be included in the response.  This does make the request a bit
slower as a lot more information is needed from PACER, but it does allow you to
fetch everything you need to get to the "buy a PDF" step in one call. To do
this, you pass `include_documents` as a form parameter to the docket update
call:

Example:

```shell
  $ ./docket/update.sh orbtrain 6:14-bk-6361 1
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": " ",
      "case_chapter_id": 1,
      "case_court_id": 221,
      "case_id_external": 458895,
      "case_no": "6:14-bk-63618",
      "case_petition_id": 1,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 7,
      "court": "orbtrain",
      "court_name": "orbtrain",
      "created": "2018-09-24T17:37:18.440872Z",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/2014",
      "date_of_last_filing": null,
      "date_plan_confirmed": null,
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": 0,
      "is_business_bankruptcy": 0,
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618"
        }
      },
      "modified": "2018-09-24T17:58:47.477298Z",
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": "2018-09-24T17:58:47.477300Z",
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055150
    },
    "dockets": [
      {
        "annotations": [],
        "binder": {
          "documents": [
            {
              "cost": "0.70",
              "description_html": null,
              "docket_no": 1,
              "filename": null,
              "free": null,
              "friendly_name": null,
              "links": {
                "order_pdf": {
                  "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
                }
              },
              "number": 1,
              "pages": 7
            }
          ],
          "links": {
            "pacer-update": {
              "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
              "method": "POST"
            }
          }
        },
        "date_filed": "10/15/2014",
        "docket_no": 1,
        "docket_seq": 0,
        "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
        "has_pdf_link_on_pacer": true,
        "sequence_number": "1.00000",
        "timestamp": "2018-09-24T17:58:46.158385Z",
        "title": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)"
      }
    ],
    "receipts": {
      "client_code": "",
      "cost": "0.10",
      "criteria": "14-63618-7 Fil or Ent: filed Doc From: 0 Doc To: 99999999 Term: included Format: html Page counts for documents: included",
      "datetime": "09/24/2018 10:58:47",
      "description": "Docket Report",
      "pages": "1",
      "timestamp": "2018-09-24T17:58:46.158385Z",
      "user_id": "testing"
    }
  }
```

Note that the docket entry now has a `binder` field, and that field contains all the information needed to go straight to the "Order PDF" step.  That is:

* There is a PDF available
* It has 7 pages
* The cost to buy this PDF from PACER is $0.70.
* The Endpoint to purchase the PDF is: `/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1`

### Display Docket Entries

Endpoint: `GET /cases/pacer/{court}/{case}/dockets`

This shows the docket entries from the local CourtAPI database.

Now that the docket entries have been update from PACER, we can show the docket
entries again, and this time the `entries` in the response will contain the
docket entries.

Note that the `response.entries.content` is a paged result set, and if the
`total_pages` is greater than 1, then you will need to call this endpoint
repeatedly, using the `entries.content.links.next.href` location to fetch all
of the docket entries. The default page size is 500, so this will only be
necessary for cases with very large docket sheets.  You could also use a larger
`page_size` query parameter to fetch more docket entries in the same request.
For each docket entry, the `documents` and `self` links refer to the endpoints
to get the documents or the link to this specific docket entry, respectively.

```shell
  $ ./docket/list.sh orbtrain 6:14-bk-63618 | jq
  {
    "entries": {
      "content": [
        {
          "annotations": [],
          "binder": {
            "documents": [
              {
                "cost": "0.70",
                "description_html": null,
                "docket_no": 1,
                "filename": null,
                "free": null,
                "friendly_name": null,
                "links": {
                  "order_pdf": {
                    "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
                  }
                },
                "number": 1,
                "pages": 7
              }
            ],
            "links": {
              "pacer-update": {
                "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
                "method": "POST"
              }
            }
          },
          "date_filed": "10/15/2014",
          "docket_no": 1,
          "docket_seq": "1.00000",
          "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
          "has_pdf_link_on_pacer": true,
          "links": {
            "documents": {
              "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents"
            },
            "self": {
              "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
            }
          },
          "timestamp": "2018-09-24T17:47:48.147230Z"
        }
      ],
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc&page_size=500&page_number=1"
        }
      },
      "page_size": 500,
      "total_items": 1,
      "total_pages": 1
    },
    "header": {
      "assigned_to": " ",
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
      "chapter": "7",
      "date_filed": "10/15/2014",
      "has_asset": 0,
      "header_html_timestamp": "2018-09-24T18:06:41Z",
      "html": "... header html ...",
      "is_header_html_valid": 1,
      "latest_docket_number": 1,
      "latest_history_number": null,
      "latest_known_date_filed": "10/15/2014",
      "modified": "2018-09-24T18:06:41.769860Z",
      "trustees": [],
      "voluntary": 1
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets?sort_order=desc"
      }
    }
  }
```

Note here again, that the `binder` for each docket entry has everything that
you need to jump straight to the "Buy PDF" step.  There is no need to show
individual docket entries if you just want to jump straight to the PDF.

### Show a Specific Docket Entry

Usage `./docket/show-entry.sh <court code> <case number> <docket number>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}`

This just shows a single specific docket entry.  It is the `self` URL from an
entry in the list of docket entries.

Example:

```shell
  $ ./docket/show-entry.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "entry": {
      "action": "https://ecf-train.orb.uscourts.gov/doc3/150014371924",
      "annotations": [],
      "binder": {
        "documents": [
          {
            "cost": "0.70",
            "description_html": null,
            "docket_no": 1,
            "filename": null,
            "free": null,
            "friendly_name": null,
            "links": {
              "order_pdf": {
                "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
              }
            },
            "number": 1,
            "pages": 7
          }
        ],
        "links": {
          "pacer-update": {
            "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
            "method": "POST"
          }
        }
      },
      "case_docket_entry_id": 81274893,
      "date_filed": "10/15/2014",
      "docket_no": 1,
      "docket_seq": "1.00000",
      "docket_text": "Chapter 7 Voluntary Petition, Fee Amount &#036;335 CHARLES H. VINCENT on behalf of Joseph Wayne Sample, Sarah Lynn Sample. (VINCENT, CHARLES) (Entered: 10/15/2014)",
      "has_pdf_link_on_pacer": true,
      "links": {
        "documents": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents"
        },
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
        }
      },
      "timestamp": "2018-09-24T17:47:48.147230Z"
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/header"
      },
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000"
      }
    }
  }
```

## Show Docket Header

Usage: `./docket/show-header.sh <court code> <case number>`

Endpoint `GET /cases/pacer/{court}/{case}/dockets/header`

This endpoint shows the docket header information.

Example:

```shell
  $ ./docket/show-header.sh orbtrain 6:14-bk-63618  | jq
  {
    "case": {
      "assets": "Unknown",
      "assigned_to": " ",
      "case_category": "bankruptcy",
      "case_no": "6:14-bk-63618",
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type": "bk",
      "cause": null,
      "ch11_type": null,
      "chapter": 7,
      "court_code": "orbtrain",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "10/15/2014",
      "date_of_last_filing": null,
      "date_terminated": null,
      "disposition": null,
      "has_asset": "No",
      "judge_name": null,
      "jurisdiction": null,
      "jury_demand": null,
      "modified": "2018-09-24T21:02:59.027680Z",
      "nature_of_suit_code": null,
      "petition_type": "v",
      "plan_confirmed": null,
      "referred_to": null
    },
    "header": {
      "assigned_to": " ",
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
      "chapter": "7",
      "date_filed": "10/15/2014",
      "has_asset": 0,
      "header_html_timestamp": "2018-09-24T21:02:59Z",
      "html": "... header HTML ... ",
      "is_header_html_valid": 1,
      "latest_docket_number": 1,
      "latest_history_number": null,
      "latest_known_date_filed": "10/15/2014",
      "modified": "2018-09-24T21:02:59.027680Z",
      "trustees": [],
      "voluntary": 1
    }
  }
```

## Get Documents for a Docket Entry

Usage: `./docket/show-entry-documents.sh <court code> <case number> <docket seq>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents`

For each docket entry that we are interseted in, the documents are at the
`GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents` endpoint.  This
is in the previous response at the `entry.links.documents.href` location.

Example:

```shell
  $ ./docket/show-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "documents": [],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    }
  }
```

There are no entries available (`documents` is empty), so we need to do a POST
to the `pacer-update` link to get the list of documents.  Note that some docket
entries will not have any documents.  Also note that document information is
automatically imported by CourtAPI when the docket entry is updated from PACER.
This happens in the background.

```shell
  $ ./docket/update-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq~_
  {
    "documents": [
      {
        "cost": "0.70",
        "description_html": null,
        "docket_no": 1,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
          }
        },
        "number": 1,
        "pages": 7
      }
    ],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    }
  }
```

And now we can show the documents again:

```shell
  $ ./docket/show-entry-documents.sh orbtrain 6:14-bk-63618 1.00000 | jq
  {
    "documents": [
      {
        "cost": "0.70",
        "description_html": null,
        "docket_no": 1,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1"
          }
        },
        "number": 1,
        "pages": 7
      }
    ],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents",
        "method": "POST"
      }
    }
  }
```

The next step is to follow the `order_pdf` link.  The `show-docket-entry-pdf.sh` script will do that for us:

Usage: `./docket/show-entry-pdf.sh <court code> <case number> <docket seq> <document part>`

Endpoint: `GET /cases/pacer/{court}/{case}/dockets/{docket_no}/documents/{part}`

Example:
```shell
  $ ./docket/show-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "document": {},
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1",
        "method": "POST"
      }
    },
    "origin": "cache"
  }
```

Because the `document` is empty, we need to POST to the document PACER update URL to
purchase the document from PACER.

The `docket/update-entry-pdf.sh` script will do this. It uses the CourtAPI
endpoint
`POST /cases/pacer/{court}/{case}/dockets/{docket_no}/documents/{part}` to do this.

```shell
  $ ./docket/update-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "document": {
      "action": "https://ecf-train.orb.uscourts.gov/doc3/150114371924?caseid=458895",
      "cost": "0.70000",
      "description_html": null,
      "docket_no": "1.00000",
      "download_url": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/documents/docket/download/eyJjYXNlX3V1aWQiO...",
      "filename": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "free": null,
      "friendly_name": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "number": 1,
      "ocr_link": "/cases/pacer/orbtrain/6:14-bk-63618/documents/docket/download/eyJjYXNlX3V1...",
      "pages": 7,
      "sequence_number": "1.00000"
    },
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1",
        "method": "POST"
      }
    },
    "origin": "PACER",
    "receipt": {
      "meta": {
        "case_uuid": null,
        "timestamp": null
      },
      "text": {
        "client_code": "",
        "cost": "0.70",
        "criteria": "14-63618-7",
        "datetime": "Mon Sep 24 14:12:58 2018",
        "description": "Image:1-0",
        "pages": "7",
        "user_id": "testing"
      }
    }
  }
````
From this response, we have everything needed to save the PDF locally.  Note
that we received a receipt from PACER in the response indicating the pass
through charge amount. We can fetch the PDF at the `document.download_url`
location, and use the `document.filename` or `document.friendly_name` to save
it locally.  Note that the fetch PDF link is a local link to CourtAPI, and will
return a 302 redirect to the actual location of the PDF file.

The `GET` endpoint now will return the same information:

```shell
  $ ./docket/show-entry-pdf.sh orbtrain 6:14-bk-63618 1.00000 1 | jq
  {
    "document": {
      "cost": "0.70000",
      "description_html": null,
      "download_url": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/documents/docket/download/eyJjYXNlX3V...",
      "filename": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "friendly_name": "Bankr.D.Or.TRAIN._6-14-bk-63618_1.00000.pdf",
      "number": 1,
      "pages": 7
    },
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/orbtrain/6:14-bk-63618/dockets/1.00000/documents/1",
        "method": "POST"
      }
    },
    "origin": "cache"
  }
```

Note that the origin here is `cache` and there were no PACER fees incurred for
the request this time.  Again, simply fetch the PDF from the
`document.download_url` location, saving as whatever you prefer (or, use
`document.filename` or `document.friendly_name`).

## Purchase and Display a Claims Register

If you have a court code and case number, the following examples show how to
purchase the claims register and any documents you are interested in for the
case.

### Search for the Case.

This is exactly the same as the docket sheet example.

E.g.: `search-court-cases.sh azbtest 2:07-bk-00012`

### Show Claims

Usage: `./claim/list.sh <court> <case number>`

Endpoint: `GET /cases/pacer/{court}/{case}/claims` endpoint.

Example:
```shell
  $ ./claim/list.sh azbtest 2:07-bk-00012
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
          "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims?page_size=500&page_number=1"
        }
      },
      "page_size": 500,
      "total_items": 0,
      "total_pages": 1
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims"
      }
    }
  }
```

We can see that `entries.content` is empty, so we need to use the
`links.pacer-update` endpoint to purchase the claims register from PACER.
`update-case-claims.sh` will make this request for us (PACER pass through
charges apply)

### Update (Purchase) Claims Register Entries

Usage `./claim/update.sh <court code> <case number>`

Endpoint `POST /cases/pacer/{court_code}/{case_number}/claims/update`

```shell
  $ ./claim/update.sh azbtest 2:07-bk-00012 | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": null,
      "case_chapter_id": 3,
      "case_court_id": 107,
      "case_id_external": 2644,
      "case_no": "2:07-bk-00012",
      "case_petition_id": 1,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 11,
      "court": "azbtest",
      "court_name": "azbtest",
      "created": "2018-09-24T21:00:28.063665Z",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "02/19/2007",
      "date_of_last_filing": "10/08/2013",
      "date_plan_confirmed": "07/30/2007",
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": 1,
      "is_business_bankruptcy": null,
      "judge_name": "Brenda Moody Whinery",
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012"
        }
      },
      "modified": "2018-09-24T21:30:48.788762Z",
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": "2018-09-24T21:30:48.788760Z",
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055150
    },
    "claims": [
      {
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
        "claim_no": "1",
        "creditor": "Bloomingdales\nPO Box 8745\nNew York NY 10012-8745",
        "description": "(1-1) test<BR>",
        "history": [
          {
            "claim_date": "06/11/2007",
            "claim_history_no": "1",
            "claim_no": "1-1",
            "claim_seq": 0,
            "claim_text": "Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
            "history_no": 1,
            "sequence_number": "1.00000"
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
        },
        "timestamp": "2018-09-24T21:30:51.403973Z"
      }
    ],
    "receipts": {
      "client_code": "",
      "cost": "0.10",
      "criteria": "2:07-bk-00012-BMW",
      "datetime": "09/24/2018 14:30:52",
      "description": "Claims Register",
      "filename": "azbtest_2644",
      "pages": "1",
      "timestamp": "2018-09-24T21:30:51.403973Z",
      "user_id": "testing"
    }
  }
```

Note that there is a receipt for the claims register purchase in the response.

Just like the docket update endpoint, we can ask for the claims documents to be
returned with the claims entries here by passing the form parameter
`include_documents`.  The script will do that for us if we pass the value as a
third argument.

```shell
  $ ./claim/update.sh azbtest 2:07-bk-00012 1  | jq
  {
    "case": {
      "appeal_case_uuid": null,
      "assets": "Unknown",
      "assigned_to": null,
      "case_chapter_id": 3,
      "case_court_id": 107,
      "case_id_external": 2644,
      "case_no": "2:07-bk-00012",
      "case_petition_id": 1,
      "case_title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "case_type_id": 1,
      "cause": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "chapter": 11,
      "court": "azbtest",
      "court_name": "azbtest",
      "created": "2018-09-24T21:00:28.063665Z",
      "date_closed": null,
      "date_discharged": null,
      "date_filed": "02/19/2007",
      "date_of_last_filing": "10/08/2013",
      "date_plan_confirmed": "07/30/2007",
      "date_terminated": null,
      "disabled": 0,
      "disposition": null,
      "has_asset": 1,
      "is_business_bankruptcy": null,
      "judge_name": "Brenda Moody Whinery",
      "jurisdiction": null,
      "jury_demand": null,
      "lead_case_uuid": null,
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012"
        }
      },
      "modified": "2018-09-24T21:30:48.788762Z",
      "nature_of_debt": null,
      "nature_of_suit_code": null,
      "ncl_parties": [],
      "referred_to": null,
      "schedule_ab": null,
      "timestamp": "2018-09-24T21:30:48.788760Z",
      "title": "Joseph Wayne Sample and Sarah Lynn Sample",
      "uri_id": 85055150
    },
    "claims": [
      {
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
        "claim_no": "1",
        "creditor": "Bloomingdales\nPO Box 8745\nNew York NY 10012-8745",
        "description": "(1-1) test<BR>",
        "history": [
          {
            "binder": {
              "documents": [
                {
                  "cost": "0.30",
                  "description_html": "Claim 51742-0",
                  "docket_no": null,
                  "filename": null,
                  "free": null,
                  "friendly_name": null,
                  "links": {
                    "order_pdf": {
                      "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
                    }
                  },
                  "number": 1,
                  "pages": 3
                }
              ],
              "links": {
                "pacer-update": {
                  "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
                  "method": "POST"
                }
              }
            },
            "claim_date": "06/11/2007",
            "claim_history_no": "1",
            "claim_no": "1-1",
            "claim_seq": 0,
            "claim_text": "Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
            "history_no": 1,
            "sequence_number": "1.00000"
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
        },
        "timestamp": "2018-09-24T21:38:06.699152Z"
      }
    ],
    "receipts": {
      "client_code": "",
      "cost": "0.10",
      "criteria": "2:07-bk-00012-BMW",
      "datetime": "09/24/2018 14:38:07",
      "description": "Claims Register",
      "filename": "azbtest_2644",
      "pages": "1",
      "timestamp": "2018-09-24T21:38:06.699152Z",
      "user_id": "testing"
    }
  }
```

Note that the claim history entry has a `binder` this time, which contains
everything needed to jump straight to the "Order PDF" step.  If your goal is to
fetch PDFs for claims entries, this is all you need to do, and you can go
straight to the purchase PDF step.

If we re-run the `GET` request to show the claims register, we can see the same
information now, including the `binder` for the history entry.

```shell
  $ ./claim/list.sh azbtest 2:07-bk-00012 | jq
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
              "binder": {
                "documents": [
                  {
                    "cost": "0.30",
                    "description_html": "Claim 51742-0",
                    "docket_no": null,
                    "filename": null,
                    "free": null,
                    "friendly_name": null,
                    "links": {
                      "order_pdf": {
                        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
                      }
                    },
                    "number": 1,
                    "pages": 3
                  }
                ],
                "links": {
                  "pacer-update": {
                    "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
                    "method": "POST"
                  }
                }
              },
              "claim_date": "06/11/2007",
              "claim_no": "1-1",
              "claim_seq": "1-1.00000",
              "claim_text": "06/11/2007 Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
              "links": {
                "documents": {
                  "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000"
                }
              }
            }
          ],
          "info": {
            "claim_no": 1,
            "modified": "2018-09-24T21:38:08.038270Z",
            "original_entered_date": "06/11/2007",
            "original_filed_date": "06/11/2007"
          },
          "links": {
            "self": {
              "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
            }
          },
          "remarks": null,
          "status": null
        }
      ],
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims?page_size=500&page_number=1"
        }
      },
      "page_size": 500,
      "total_items": 1,
      "total_pages": 1
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/update",
        "method": "POST"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims"
      }
    }
  }
```

Just like case docket entries, claims register entries are paged, and if
`entries.total_pages` is greater than 1, you must fetch all of the pages by
following the `entries.links.next.href` for each result until you have fetched
all of the pages.  In this case, there is only one page, so the
`entries.links.next.href` is not present.  The default page size is 500 claims
entries, so for most cases, you should not need to worry about this.

### Display A Specific Claim

Endpoint: `GET /cases/pacer/{court}/{case}/claims/{claim_no}`

This will display a specific claim from the claims register.

Usage: `./claim/show.sh <court code> <case number> <claim number>`

Example:

```shell
  $ ./claim/show.sh azbtest 2:07-bk-00012 1 | jq
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
          "binder": {
            "documents": [
              {
                "cost": "0.30",
                "description_html": "Claim 51742-0",
                "docket_no": null,
                "filename": null,
                "free": null,
                "friendly_name": null,
                "links": {
                  "order_pdf": {
                    "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
                  }
                },
                "number": 1,
                "pages": 3
              }
            ],
            "links": {
              "pacer-update": {
                "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
                "method": "POST"
              }
            }
          },
          "claim_date": "06/11/2007",
          "claim_no": "1-1",
          "claim_seq": "1-1.00000",
          "claim_text": "06/11/2007 Claim #1 filed by Bloomingdales, Amount claimed: $160.00 (Fouche, Cindy)",
          "links": {
            "documents": {
              "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000"
            }
          }
        }
      ],
      "info": {
        "claim_no": 1,
        "modified": "2018-09-24T21:38:08.038270Z",
        "original_entered_date": "06/11/2007",
        "original_filed_date": "06/11/2007"
      },
      "links": {
        "self": {
          "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
        }
      },
      "remarks": null,
      "status": null
    },
    "links": {
      "header": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/header"
      },
      "self": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1"
      }
    }
  }
```

### Purchase and Download a Claims Register Entry PDF

Endpoint: `GET /cases/pacer/{court}/{case}/claims/{claim_no}/documents/{document_no}`

Usage: `./claim/show-document.sh <court code> <case number> <claim number> <document number>`

Now we will purchase and download the documents for this claim register entry.

`show-case-claim-document.sh` will make this request for us.

Example:
```shell
  $ ./claim/show-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "documents": [],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    }
  }
```

There are no documents present, so we need to update the documents from PACER
by using the `links.pacer-update` endpoint.  `update-case-claim-document.sh`
will make this request for us (it takes the same args as
`show-case-claim-document.sh`).  Note that not every claims entry will have
documents.  Also note that CourtAPI will automatically fetch document
information when you purchase the claims entries, so this step is typically not
necessary.

```shell
  $ ./claim/update-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "documents": [
      {
        "cost": "0.30",
        "description_html": "Claim 51742-0",
        "docket_no": null,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
          }
        },
        "number": 1,
        "pages": 3
      }
    ],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    }
  }
```

And now we can show the claims document again by using the `GET` method:

```shell
  $ ./claim/show-document.sh azbtest 2:07-bk-00012 1 1.00000 | jq
  {
    "documents": [
      {
        "cost": "0.30",
        "description_html": "Claim 51742-0",
        "docket_no": null,
        "filename": null,
        "free": null,
        "friendly_name": null,
        "links": {
          "order_pdf": {
            "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1"
          }
        },
        "number": 1,
        "pages": 3
      }
    ],
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000",
        "method": "POST"
      }
    }
  }
```

The next step is to follow the `links.order_pdf` for each `documents` entry.  This uses the CourtAPI endpoint
`GET /cases/pacer/{court}/{case}/claims/{claim_no}/documents/{document_no}/{part_no}` endpoint.

```shell
  $ ./claim/show-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "document": {},
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1",
        "method": "POST"
      }
    },
    "origin": "cache"
  }
```

Note that the `document` field is empty.

We have to `POST` to the same endpoint to purchase the PDF in this case.

Example:

```shell
  $ ./claim/buy-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "document": {
      "action": "https://ecf-test.azb.uscourts.gov/doc2/02418759",
      "case_uuid": "azbtest_2644",
      "cost": "0.30000",
      "description_html": "Claim 51742-0",
      "docket_no": "1-1.00000",
      "download_url": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/documents/claims/download/eyJjYXNlX3V1a...",
      "filename": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "friendly_name": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "history_number": "1",
      "number": 1,
      "ocr_link": "http://...",
      "pages": 3
    },
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1",
        "method": "POST"
      }
    },
    "origin": "PACER",
    "receipt": {
      "meta": {
        "case_uuid": null,
        "timestamp": null
      },
      "text": {
        "client_code": "",
        "cost": "0.30",
        "criteria": "2:07-bk-00012-BMW",
        "datetime": "Mon Sep 24 14:55:33 2018",
        "description": "Claim 51742-0",
        "pages": "3",
        "user_id": "testing"
      }
    }
  }
```

At this point, you can fetch the PDF from the `document.download_url` location,
and save it at the location of your choice, or, use the `part.filename` or
`part.friendly_name` suggested filenames.  Note that we have a `receipt` for
the PACER pass through charges.

We can re-fetch the PDF endpoint using the `GET` method for no charge:

```shell
  $ ./claim/show-pdf.sh azbtest 2:07-bk-00012 1 1.00000 1 | jq
  {
    "document": {
      "cost": "0.30000",
      "description_html": "Claim 51742-0",
      "download_url": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/documents/claims/download/eyJjYXNlX3V",
      "filename": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "friendly_name": "Bankr.D.Ariz.TEST_2-07-bk-00012_Claim_1-1.pdf",
      "number": 1,
      "pages": 3
    },
    "links": {
      "pacer-update": {
        "href": "https://train.vi.courtapi.com/cases/pacer/azbtest/2:07-bk-00012/claims/1/documents/1.00000/1",
        "method": "POST"
      }
    },
    "origin": "cache"
  }
```
Note that there are no charges this time, and the `document.download_url` is
available showing where to fetch the PDF.

## Advanced Filings Search

Endpoint: `GET /cases/pacer/search-filings`

Usage: `./pacer/search-filings.sh <case_uuid>`

Example:
```shell
 $ ./pacer/search-filings.sh nysbke_247775 | jq
{
  "facets" => {
    "chapter" => {
      "11" => 1023
    },
    "court" => {
      "nysbke" => 1023
    },
    "date_filed" => {
      "2014" => 1023
    },
    "judge_name" => {
      "Martin Glenn" => 1023
    },
    "nature_of_suit" => []
  },
  "num_cases" => 1,
  "num_found" => 1023,
  "page_count" => 1,
  "results" => [
    {
      "appeal_case_uuid" => undef,
      "assets" => "Unknown",
      "assigned_to" => undef,
      "case_assets" => "Unknown",
      "case_chapter" => 11,
      "case_chapter_id" => 3,
      "case_court" => "nysbke",
      "case_court_id" => 72,
      "case_date_filed" => "03/10/2014",
      "case_id" => 3098692,
      "case_id_external" => 247775,
      "case_judge_name" => "Martin Glenn",
      "case_liabilities" => "Unknown",
      "case_naics_code" => undef,
      "case_nature_of_suit_code" => undef,
      "case_no" => "1:14-bk-10557",
      "case_petition_id" => 1,
      "case_title" => "Sbarro LLC",
      "case_type" => "bk",
      "case_type_id" => 1,
      "cause" => undef,
      "ch11_type" => undef,
      "ch11_type_code" => undef,
      "chapter" => 11,
      "court" => "nysbke",
      "court_code" => [
        "ny",
        "nys",
        "02"
      ],
      "court_name" => "nysbke",
      "created" => "2014-03-10T12:59:56.335718Z",
      "date_closed" => undef,
      "date_discharged" => undef,
      "date_filed" => "03/10/2014",
      "date_of_last_filing" => undef,
      "date_plan_confirmed" => undef,
      "date_terminated" => undef,
      "disposition" => undef,
      "document_type" => "cases",
      "has_asset" => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
      "id" => "cases:nysbke_247775",
      "industry" => undef,
      "inner_hits" => "1023 matches",
      "is_business_bankruptcy" => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' ),
      "join" => {
        "name" => "cases"
      },
      "judge_name" => "Martin Glenn",
      "jurisdiction" => undef,
      "jury_demand" => undef,
      "lead_case_uuid" => undef,
      "liabilities" => "Unknown",
      "links" => {
        "self" => {
          "href" => "http://127.0.0.1:43959/cases/pacer/nysbke/1:14-bk-10557"
        }
      },
      "modified" => "2017-07-09T05:13:32.653406Z",
      "naics_code" => undef,
      "nature_of_debt" => "Business",
      "nature_of_suit_code" => undef,
      "ncl_parties" => [
        {
          "name" => "Sbarro LLC",
          "role" => "db"
        },
        {
          "name" => "New Sbarro LLC",
          "role" => "db"
        },
        {
          "name" => "Belmonte, Christopher Robert",
          "role" => "aty"
        }
      ],
      "query" => "cases",
      "referred_to" => undef,
      "schedule_ab" => undef,
      "title" => "Sbarro LLC",
      "type_code" => 0,
      "website" => undef
    }
  ]
}
```

## Advanced Filings Search: Business Bankruptcies

Endpoint: `GET /cases/pacer/search-filings`

Usage: `./pacer/search-business-bankruptcies.sh [<date_filed_from>]`

Example:
```shell
$ pacer/search-bankruptcies-cases.sh 11/10/2014 | jq
{
  "results": [
    {
      "case_date_filed": "11/10/2014",
      "referred_to": null,
      "case_type": "bk",
      "case_id_external": 156595,
      "case_assets": "Unknown",
      "join": {
        "name": "cases"
      },
      "case_type_id": 1,
      "type_code": 0,
      "case_petition_id": null,
      "case_judge_name": null,
      "date_terminated": null,
      "ch11_type": null,
      "ch11_type_code": null,
      "has_asset": false,
      "naics_code": null,
      "case_no": "1:14-bk-12515",
      "website": null,
      "chapter": 11,
      "court_name": "debke",
      "query": "cases",
      "court_code": [
        "de",
        "03"
      ],
      "date_filed": "11/10/2014",
      "date_plan_confirmed": null,
      "case_nature_of_suit_code": null,
      "links": {
        "self": {
          "href": "http://courtapi.dev.courtio.com/cases/pacer/debke/1:14-bk-12515"
        }
      },
      "nature_of_debt": "Business",
      "case_id": 4009950,
      "cause": null,
      "lead_case_uuid": null,
      "date_of_last_filing": "06/04/2015",
      "date_closed": null,
      "case_naics_code": null,
      "party_name": [],
      "appeal_case_uuid": null,
      "schedule_ab": null,
      "liabilities": "Unknown",
      "case_court": "debke",
      "assets": "Unknown",
      "court": "debke",
      "date_discharged": null,
      "jury_demand": null,
      "assigned_to": null,
      "case_chapter": 11,
      "title": "Dendreon Corporation",
      "modified": "2017-07-09T05:13:32.653406Z",
      "case_court_id": 27,
      "nature_of_suit_code": null,
      "case_chapter_id": 3,
      "index_timestamp": 1569933971,
      "created": "2014-11-10T06:47:06.292671Z",
      "case_title": "Dendreon Corporation",
      "industry": null,
      "ncl_parties": [],
      "id": "cases:debke_156595",
      "jurisdiction": null,
      "document_type": "cases",
      "case_liabilities": "Unknown",
      "is_business_bankruptcy": true,
      "judge_name": null,
      "disposition": null
    },
    {
      "case_id": 4268810,
      "lead_case_uuid": null,
      "cause": null,
      "date_plan_confirmed": null,
      "case_nature_of_suit_code": null,
      "date_filed": "02/05/2015",
      "links": {
        "self": {
          "href": "http://courtapi.dev.courtio.com/cases/pacer/debke/1:15-bk-10197"
        }
      },
      "nature_of_debt": "Business",
      "chapter": 11,
      "court_name": "debke",
      "website": null,
      "court_code": [
        "de",
        "03"
      ],
      "query": "cases",
      "case_no": "1:15-bk-10197",
      "case_judge_name": "Brendan Linehan Shannon",
      "naics_code": null,
      "has_asset": true,
      "ch11_type_code": null,
      "date_terminated": null,
      "ch11_type": null,
      "case_petition_id": 1,
      "case_type_id": 1,
      "case_assets": "More than $1 billion",
      "join": {
        "name": "cases"
      },
      "type_code": 0,
      "case_date_filed": "02/05/2015",
      "referred_to": null,
      "case_id_external": 157447,
      "case_type": "bk",
      "disposition": null,
      "judge_name": "Brendan Linehan Shannon",
      "is_business_bankruptcy": true,
      "case_liabilities": "More than $1 billion",
      "id": "cases:debke_157447",
      "jurisdiction": null,
      "industry": null,
      "ncl_parties": [
        {
          "role": "db",
          "name": "RadioShack Corporation"
        }
      ],
      "document_type": "cases",
      "index_timestamp": 1569933975,
      "case_chapter_id": 3,
      "case_title": "RadioShack Corporation",
      "created": "2015-02-05T22:10:04.971241Z",
      "title": "RadioShack Corporation",
      "nature_of_suit_code": null,
      "modified": "2017-07-09T05:13:32.653406Z",
      "case_court_id": 27,
      "court": "debke",
      "case_court": "debke",
      "assets": "More than $1 billion",
      "case_chapter": 11,
      "assigned_to": null,
      "date_discharged": null,
      "jury_demand": null,
      "schedule_ab": {
        "intangibles": 1000000,
        "total": 6734500,
        "cash": 100000,
        "property": 900000,
        "office": 700000,
        "personal_total": 5834500,
        "farming": 600000,
        "deposits": 200000,
        "real_total": 900000,
        "machinery": 800000,
        "acct_rcpt": 300000,
        "investments": 400000,
        "others": 1234500,
        "inventory": 500000
      },
      "liabilities": "More than $1 billion",
      "date_of_last_filing": "06/04/2015",
      "date_closed": null,
      "case_naics_code": null,
      "appeal_case_uuid": null,
      "party_name": [
        "RadioShack Corporation (db)"
      ]
    }
  ],
  "facets": {
    "date_filed": {
      "2015": 1,
      "2014": 1
    },
    "assets": {
      "Unknown": 1,
      "More than $1 billion": 1
    },
    "court": {
      "debke": 2
    },
    "nature_of_suit": [],
    "liabilities": {
      "Unknown": 1,
      "More than $1 billion": 1
    },
    "judge_name": {
      "Brendan Linehan Shannon": 1
    },
    "industry": [],
    "chapter": {
      "11": 2
    }
  },
  "page_count": 1,
  "num_found": 2,
  "num_cases": 2
}
```
