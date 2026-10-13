# 附录 — 代码库清单

> 仓库内与搜索 / agent 训练 / 评测相关的路径，供各阶段引用。路径相对于 `/dev/gpc_code/`。

## 训练

| 组件 | 路径 | 说明 |
|------|------|------|
| **Agent ES（noise_weight）** | `agentic_es/` · [GitHub agent_ES](https://github.com/JWgpc/agent_ES) | ES 黑盒优化；rollout：`clawgym` / `general_agent` / **`bcp`**；详见 [agent_es_attempts.md](./reports/agent_es_attempts.md) |
| BCP ES 入口 | `agentic_es/scripts/run_es_bcp.sh` | OpenResearcher rollout + BM25；语料 `build_bcp_es_corpus.py` |
| ClawGym GRPO | `clawGym/ClawGym-Agents/RL/` | OpenClaw 沙箱 RL；**当前 deny web_search/memory_search** |
| RL rollout | `clawGym/ClawGym-Agents/RL/clawgym_rl_rollout.py` | gateway 配置 L545–548 |
| 沙箱工具 | `clawGym/ClawGym-Agents/RL/clawgym_tools.py` | 含 web_fetch，无 web_search |
| 训练数据说明 | `clawGym/ClawGym-Agents/RL/data/DATASET_README.md` | 2000 任务排除 web |
| Search-R1 示例 | `slime_0427/slime/examples/search-r1/` | QA 多轮 search + GRPO |
| BFCL 多轮 GRPO | `slime_0427/slime/examples/bfcl_multiturn/` | 多轮 tool 合成训练范式 |
| BFCL 数据合成 | `simulator_tool_sever_bfcl_revise_fix/pipeline.py` | 轨迹生成参考 |
| Travel 合成 DPO | `travel_synth/` | 强模型 rollout → DPO 参考 |
| OpenClaw-RL | `OpenClaw-RL/` | 异步 RL；含 gui-rl |
| SFT tokenization | `clawGym/ClawGym-Agents/SFT/process_scripts/sft_data_pre_tokenize_toolcall_for_openclaw.py` | OpenClaw tool schema |

## 评测

| 组件 | 路径 | 说明 |
|------|------|------|
| Claw-Eval | `claw_eval_new/claw-eval/` | 300 任务；含 web/KB mock+真实 SERP |
| KB 任务示例 | `claw_eval_new/claw-eval/tasks/T016_kb_search/` | 知识库检索 |
| Web 注入防御 | `claw_eval_new/claw-eval/tasks/T073_web_search_injection/` | 安全 |
| Mock SERP | `claw_eval_new/claw-eval/mock_services/web_real/` | 可复用于训练 |
| QwenClawBench | `QwenClaw_new/QwenClawBench-main/` | 100 OpenClaw 真实任务 |
| QCB 脚本 | `QwenClaw_new/QwenClawBench-main/scripts/benchmark.py` | 评测入口 |
| tau2 KB 域 | `tau2-bench/src/tau2/domains/banking_knowledge/` | BM25 检索参考 |
| search_eval v0.1 | `search_eval/` | BCP + Claw web + τ³-Banking；见 [search_eval/README.md](../../search_eval/README.md) |

## 部署

| 组件 | 路径 |
|------|------|
| SGLang 部署 | `model/model_deploy/sglang_deploy_3_5.sh` |
| 模型 symlink | `models` → `/data/gpc/models` |

## 已知缺口（v1 需补齐）

1. 无 `generate_with_openclaw_search.py` 类 OpenClaw 搜索 **GRPO** 管线（**BCP 闭集 ES 已跑通**，见 agent_es_attempts）  
2. BrowseComp-Plus **官方 eval** 与 ES 内 eval 尚未统一登记到 `search_eval/baselines/`  
3. Search-R1 未适配 Qwen3.5 chat template  
4. search_eval **统一 runner / baseline JSON** 仍待建  

## 关键代码引用

ClawGym RL 禁用搜索工具：

```545:548:clawGym/ClawGym-Agents/RL/clawgym_rl_rollout.py
        "tools": {
            "profile": "coding",
            "deny": ["web_search", "memory_search"],
            "exec": {"host": "gateway", "security": "full"},
```

训练集排除 web 原因：

```32:34:clawGym/ClawGym-Agents/RL/data/DATASET_README.md
- **Tool-call diversity** — subsampled to balance tool invocations.
- **No web tools** — `web_search` / `web_fetch` related tasks are excluded;
  network tools dominate latency and cause cascading timeouts when running in large-scale parallel sandboxes.
```
