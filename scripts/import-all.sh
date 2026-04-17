#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DASHBOARDS_DIR="${ROOT_DIR}/dashboards"

for f in \
  "${DASHBOARDS_DIR}/linux-security-overview.ndjson" \
  "${DASHBOARDS_DIR}/ssh-auth-attacks.ndjson" \
  "${DASHBOARDS_DIR}/file-integrity-monitoring.ndjson"
do
  "${SCRIPT_DIR}/import-saved-object.sh" "$f"
done
