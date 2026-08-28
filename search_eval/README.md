# search_eval — Search 能力评测套件 v0.1

> 配置与任务清单；runner 脚本阶段 2 待建。  
> **决策文档**：[reports/search_benchmark_decision.md](../reports/search_benchmark_decision.md)

## v0.1 套件

| ID | Benchmark | 题量 | 代码路径 |
|----|-----------|------|----------|
| `bcp_closed` | BrowseComp-Plus | 830 | `tau2-bench` 外 · OpenResearcher / Tevatron |
| `claw_web_search` | Claw-Eval web | 65 | `（GPC）claw_eval_new/claw-eval/` |
| `tau3_banking` | τ³-Banking | 97 | `tau2-bench/` |

## 目录

```
configs/
  benchmark_suite.yaml
  task_lists/
    claw_eval_web_search.txt   # 65 题 task_id
```

## 快速命令（baseline smoke）

### τ³-Banking（免搜索 Key，推荐先跑）

```bash
cd /dev/gpc_code/tau2-bench
tau2 run --domain banking_knowledge --retrieval-config bm25 \
  --agent-llm openai/<model> --user-llm openai/<user-sim> \
  --num-trials 1 --save-to banking_smoke
```

### BrowseComp-Plus

见 [openresearcher_env_setup.md](../reports/openresearcher_env_setup.md) §3（默认绑 BCP 语料）。

### Claw-Eval web

```bash
cd /dev/gpc_code/claw_eval_new/claw-eval
# 需 SERP_DEV_KEY + 被测模型 + judge
claw-eval batch --config config_general.yaml --tasks-dir tasks --sandbox --trials 3
```

## 产出（规划）

```
baselines/{model_name}/summary.json
```
