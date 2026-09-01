#!/usr/bin/env bash
# BrowseComp-Plus one-shot setup via OpenResearcher.
# Downloads: queries, corpus, BM25 index (+ optional dense 8b with --dense).
set -euo pipefail

OPENRESEARCHER_ROOT="${OPENRESEARCHER_ROOT:-/data/OpenResearcher}"
DOWNLOAD_DENSE="${DOWNLOAD_DENSE:-0}"

echo "==> OpenResearcher root: ${OPENRESEARCHER_ROOT}"

if [[ ! -d "${OPENRESEARCHER_ROOT}/.git" ]]; then
  echo "Cloning OpenResearcher..."
  git clone --depth 1 https://github.com/TIGER-AI-Lab/OpenResearcher.git "${OPENRESEARCHER_ROOT}"
fi

cd "${OPENRESEARCHER_ROOT}"

if [[ ! -d .venv ]]; then
  echo "==> Creating venv (Python 3.12)..."
  uv venv --python 3.12
fi
# shellcheck disable=SC1091
source .venv/bin/activate

echo "==> Installing OpenResearcher + tevatron..."
uv pip install -q -e .
if [[ ! -d tevatron ]]; then
  git clone --depth 1 https://github.com/texttron/tevatron.git
fi
uv pip install -q -e tevatron/

# Lucene JARs for BM25 highlighter
if [[ ! -f tevatron/lucene-highlighter-9.9.1.jar ]]; then
  echo "==> Downloading Lucene JARs..."
  (cd tevatron && \
    LUCENE_VERSION="9.9.1" && \
    wget -q "https://repo1.maven.org/maven2/org/apache/lucene/lucene-highlighter/${LUCENE_VERSION}/lucene-highlighter-${LUCENE_VERSION}.jar" && \
    wget -q "https://repo1.maven.org/maven2/org/apache/lucene/lucene-queries/${LUCENE_VERSION}/lucene-queries-${LUCENE_VERSION}.jar" && \
    wget -q "https://repo1.maven.org/maven2/org/apache/lucene/lucene-memory/${LUCENE_VERSION}/lucene-memory-${LUCENE_VERSION}.jar")
fi

uv pip install -q "huggingface_hub[cli]"

download_hf() {
  local repo="$1" dest="$2" extra="${3:-}"
  if [[ -d "${dest}" ]] && [[ -n "$(ls -A "${dest}" 2>/dev/null)" ]]; then
    echo "==> Skip (exists): ${dest}"
    return 0
  fi
  mkdir -p "$(dirname "${dest}")"
  echo "==> Downloading ${repo} -> ${dest}"
  # shellcheck disable=SC2086
  huggingface-cli download "${repo}" --repo-type dataset --local-dir "${dest}" ${extra}
}

download_hf "Tevatron/browsecomp-plus" "./Tevatron/browsecomp-plus"
download_hf "Tevatron/browsecomp-plus-corpus" "./Tevatron/browsecomp-plus-corpus"

if [[ ! -d ./Tevatron/browsecomp-plus-indexes/bm25 ]]; then
  mkdir -p ./Tevatron/browsecomp-plus-indexes
  echo "==> Downloading BM25 index (~2.1GB)..."
  huggingface-cli download Tevatron/browsecomp-plus-indexes \
    --repo-type dataset --include "bm25/*" \
    --local-dir ./Tevatron/browsecomp-plus-indexes
fi

if [[ "${DOWNLOAD_DENSE}" == "1" ]]; then
  echo "==> Downloading dense index (qwen3-embedding-8b)..."
  huggingface-cli download Tevatron/browsecomp-plus-indexes \
    --repo-type dataset --include "qwen3-embedding-8b/*" \
    --local-dir ./Tevatron/browsecomp-plus-indexes
fi

echo ""
echo "==> Setup complete."
echo "    Queries:  $(find Tevatron/browsecomp-plus -name '*.parquet' 2>/dev/null | wc -l) parquet file(s)"
echo "    Corpus:   $(ls Tevatron/browsecomp-plus-corpus/data/*.parquet 2>/dev/null | wc -l) parquet shard(s)"
echo "    BM25 idx: $(test -d Tevatron/browsecomp-plus-indexes/bm25 && echo OK || echo MISSING)"
echo ""
echo "Next:"
echo "  bash /dev/gpc_code/search_eval/bcp/start_search_bm25.sh"
echo "  python /dev/gpc_code/search_eval/bcp/scripts/export_manifest.py"
