#!/usr/bin/env python3
"""Export BrowseComp-Plus query manifest for GPC search_eval."""

from __future__ import annotations

import json
import os
from pathlib import Path

import duckdb

OPENRESEARCHER_ROOT = Path(os.environ.get("OPENRESEARCHER_ROOT", "/data/OpenResearcher"))
BCP_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_DIR = BCP_ROOT / "manifests"
SMOKE_N = int(os.environ.get("BCP_SMOKE_N", "100"))


def find_query_parquet() -> Path:
    base = OPENRESEARCHER_ROOT / "Tevatron" / "browsecomp-plus"
    candidates = list(base.glob("data/*.parquet")) + list(base.glob("**/*.parquet"))
    if not candidates:
        raise FileNotFoundError(f"No parquet under {base}; run setup_bcp.sh first")
    # Prefer data/*.parquet
    data_dir = base / "data"
    if data_dir.is_dir():
        files = sorted(data_dir.glob("*.parquet"))
        if files:
            return files[0]
    return sorted(candidates)[0]


def main() -> None:
    pq = find_query_parquet()
    con = duckdb.connect()
    rows = con.execute(f"SELECT * FROM read_parquet('{pq}')").fetchdf()
    con.close()

    # Normalize columns (HF may use query_id / query / answer)
    cols = {c.lower(): c for c in rows.columns}
    id_col = cols.get("query_id") or cols.get("id") or cols.get("qid")
    q_col = cols.get("query") or cols.get("question")
    a_col = cols.get("answer") or cols.get("ground_truth")

    if not q_col:
        raise ValueError(f"Cannot find query column in {list(rows.columns)}")

    items = []
    for i, row in rows.iterrows():
        qid = str(row[id_col]) if id_col else str(i)
        items.append(
            {
                "index": int(i),
                "query_id": qid,
                "query": str(row[q_col]),
                "answer": str(row[a_col]) if a_col else None,
            }
        )

    MANIFEST_DIR.mkdir(parents=True, exist_ok=True)
    full_path = MANIFEST_DIR / "browsecomp_plus_830.json"
    smoke_path = MANIFEST_DIR / f"browsecomp_plus_smoke_{SMOKE_N}.json"
    list_path = MANIFEST_DIR.parent.parent / "configs" / "task_lists" / f"bcp_smoke_{SMOKE_N}.txt"

    payload = {
        "source": "Tevatron/browsecomp-plus",
        "parquet": str(pq),
        "num_queries": len(items),
        "items": items,
    }
    full_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    smoke_items = items[:SMOKE_N]
    smoke_payload = {**payload, "num_queries": len(smoke_items), "items": smoke_items, "subset": "head"}
    smoke_path.write_text(json.dumps(smoke_payload, ensure_ascii=False, indent=2), encoding="utf-8")

    list_path.parent.mkdir(parents=True, exist_ok=True)
    list_path.write_text(
        "\n".join(x["query_id"] for x in smoke_items) + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {full_path} ({len(items)} queries)")
    print(f"Wrote {smoke_path} ({len(smoke_items)} queries)")
    print(f"Wrote {list_path}")


if __name__ == "__main__":
    main()
