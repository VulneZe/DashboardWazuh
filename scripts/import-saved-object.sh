#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <fichier.ndjson>" >&2
  exit 1
fi

FILE="$1"

: "${OSD_URL:?OSD_URL is required}"
: "${OSD_USER:?OSD_USER is required}"
: "${OSD_PASS:?OSD_PASS is required}"

OVERWRITE="${OVERWRITE:-true}"
CURL_INSECURE="${CURL_INSECURE:-false}"

CURL_TLS_ARGS=()
if [ "$CURL_INSECURE" = "true" ]; then
  CURL_TLS_ARGS+=(--insecure)
fi

CURL_HEADERS=(-H "osd-xsrf: true")
if [ -n "${SECURITY_TENANT:-}" ]; then
  CURL_HEADERS+=(-H "securitytenant: ${SECURITY_TENANT}")
fi

echo "Import de ${FILE} vers ${OSD_URL} (tenant=${SECURITY_TENANT:-<none>}, overwrite=${OVERWRITE})"

HTTP_CODE="$(
  curl -sS "${CURL_TLS_ARGS[@]}" \
    -u "${OSD_USER}:${OSD_PASS}" \
    "${CURL_HEADERS[@]}" \
    -o /tmp/osd-import-response.json \
    -w "%{http_code}" \
    -X POST \
    "${OSD_URL%/}/api/saved_objects/_import?overwrite=${OVERWRITE}" \
    -F "file=@${FILE};type=application/ndjson"
)"

cat /tmp/osd-import-response.json
echo

if [ "${HTTP_CODE}" -lt 200 ] || [ "${HTTP_CODE}" -ge 300 ]; then
  echo "Échec HTTP ${HTTP_CODE}" >&2
  exit 1
fi

if grep -q '"success":false' /tmp/osd-import-response.json; then
  echo "Import API terminé avec success=false" >&2
  exit 1
fi

echo "Import OK: ${FILE}"
