#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8000}"
URL="http://127.0.0.1:${PORT}/search"

echo "POST ${URL}"
resp=$(curl -sf -X POST "${URL}" \
  -H 'Content-Type: application/json' \
  -d '{"query": "OpenAI BrowseComp benchmark", "topn": 3}')

echo "${resp}" | python3 -m json.tool | head -40
echo ""
echo "OK: search service responded."
