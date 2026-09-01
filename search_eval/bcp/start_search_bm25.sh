#!/usr/bin/env bash
# Start BrowseComp-Plus BM25 search service (port 8000 by default).
set -euo pipefail

OPENRESEARCHER_ROOT="${OPENRESEARCHER_ROOT:-/data/OpenResearcher}"
PORT="${1:-8000}"
GPU="${2:-}"  # optional CUDA_VISIBLE_DEVICES for dense; unused for bm25

cd "${OPENRESEARCHER_ROOT}"
if [[ -n "${GPU}" ]]; then
  export CUDA_VISIBLE_DEVICES="${GPU}"
fi

exec bash scripts/start_search_service.sh bm25 "${PORT}"
