#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DASHBOARDS_DIR="${ROOT_DIR}/dashboards"

# Import professional SOC dashboards bundle
"${SCRIPT_DIR}/import-saved-object.sh" "${DASHBOARDS_DIR}/soc-dashboards-bundle.ndjson"
