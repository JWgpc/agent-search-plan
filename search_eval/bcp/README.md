# BrowseComp-Plus（bcp_closed）准备指南

> GPC search_eval · 套件 `bcp_closed`  
> 决策文档：[docs/agent_search/reports/search_benchmark_decision.md](../../docs/agent_search/reports/search_benchmark_decision.md)  
> **完整文档（含评测结果）**：[search_eval/bcp/README.md](../../../search_eval/bcp/README.md)

## 评测状态（2026-09-01）

环境构建完成；**切片 1**（139 题，`test-00000-of-00006.parquet`）已跑通，**30 轮**上限，BM25 检索。

| 模型 | Accuracy（本地 Judge `qwen3.8-27B`） |
|------|--------------------------------------|
| `9b_base` | **7%** |
| `merge_0821` | **4%** |

## 目标

离线闭集 **830** 题 deep search 评测：本地检索 + agent loop，**无需 Serper**。

| 资源 | HF | 规模 |
|------|-----|------|
| 题+答案 | [Tevatron/browsecomp-plus](https://huggingface.co/datasets/Tevatron/browsecomp-plus) | 830 |
| 语料 | [Tevatron/browsecomp-plus-corpus](https://huggingface.co/datasets/Tevatron/browsecomp-plus-corpus) | ~100K docs |
| 索引 | [Tevatron/browsecomp-plus-indexes](https://huggingface.co/datasets/Tevatron/browsecomp-plus-indexes) | BM25 ~2.1GB；dense 8b ~1.6GB |

## 目录布局（GPC 约定）

```text
/data/OpenResearcher/              # OpenResearcher 主仓（检索服务 + eval）
  Tevatron/
    browsecomp-plus/               # queries + answers
    browsecomp-plus-corpus/        # parquet 语料
    browsecomp-plus-indexes/bm25/  # BM25 索引（v0.1 默认）

/dev/gpc_code/search_eval/bcp/     # GPC 包装脚本与 manifest
  setup_bcp.sh
  start_search_bm25.sh
  verify_search_api.sh
  scripts/export_manifest.py
  manifests/
```

## 一键准备

```bash
# 1. 下载数据 + 安装 OpenResearcher 环境（BM25 路径；约 10–30 min 取决于网络）
bash /dev/gpc_code/search_eval/bcp/setup_bcp.sh

# 2. 生成 830 题 manifest + smoke 100 子集
source /data/OpenResearcher/.venv/bin/activate
python /dev/gpc_code/search_eval/bcp/scripts/export_manifest.py

# 3. 启动 BM25 检索（port 8000）
bash /dev/gpc_code/search_eval/bcp/start_search_bm25.sh

# 4. 另开终端验证
bash /dev/gpc_code/search_eval/bcp/verify_search_api.sh
```

## 跑 agent eval（OpenResearcher 原生）

检索服务在 `:8000` 运行后，用本地 vLLM/sglang：

```bash
cd /data/OpenResearcher
source .venv/bin/activate

# smoke：100 题（需 manifest 过滤或改 deploy_agent 参数）
python deploy_agent.py \
  --output_dir results/bcp_smoke/ornith_bm25 \
  --dataset_name browsecomp-plus \
  --data_path "Tevatron/browsecomp-plus/data/*.parquet" \
  --search_url http://127.0.0.1:8000 \
  --browser_backend local \
  --vllm_server_url http://127.0.0.1:8001/v1 \
  --model_name_or_path <your-model>
```

## 依赖

| 项 | v0.1 默认 |
|----|-----------|
| 检索 | **BM25**（免 GPU、免 embedding API） |
| Java | OpenJDK **21** 推荐（BM25/Pyserini）；当前机若为 11 可先试 |
| Python | 3.12 + `uv`（OpenResearcher `.venv`） |
| 磁盘 | corpus + index 约 **5–8GB**（BM25 全套） |
| GPU | BM25 **不需要**；dense 需 ~15GB |

## 与 OpenResearcher 训练语料

**BCP 仅作评测**；RL 训练若用 OpenResearcher-Corpus，须改 `start_search_service.sh` 路径（见 openresearcher_env_setup §3.2，R8）。
