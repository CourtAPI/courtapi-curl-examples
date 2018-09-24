if [ -z "$COURTAPI_APP_ID" ]; then
  echo "Please set COURTAPI_APP_ID in the environment"
  exit 1
fi

if [ -z "$COURTAPI_SECRET" ]; then
  echo "Please set COURTAPI_SECRET in the environment"
  exit 1
fi

if [ -z "$COURTAPI_HOST" ]; then
  COURTAPI_HOST="courtapi.courtio.dev.azk.io"
fi

if [ -z "$COURTAPI_SCHEME" ]; then
  COURTAPI_SCHEME="http"
fi

if [ -z "$COURTAPI_BASE_URL" ]; then
  COURTAPI_BASE_URL="$COURTAPI_SCHEME://$COURTAPI_APP_ID:$COURTAPI_SECRET@$COURTAPI_HOST"
fi
