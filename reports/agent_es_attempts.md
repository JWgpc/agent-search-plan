# Agent ES 尝试记录（与 Search 项目的关系）

> **代码仓库**：[JWgpc/agent_ES](https://github.com/JWgpc/agent_ES)  
> **本机路径**：`/dev/gpc_code/agentic_es/`  
> **设计文档**：[`agentic_es/docs/CLAWGYM_NOISE_WEIGHT_ES.md`](../../../agentic_es/docs/CLAWGYM_NOISE_WEIGHT_ES.md)（相对 gpc_code 根目录）

本文档记录在 **Agent Search 能力提升** 主线之外、并行开展的 **Agentic ES（进化策略 + noise_weight）** 工程与实验，尤其是 **BrowseComp-Plus（BCP）闭集搜索** 上的训练尝试。

---

## 1. 为什么做 Agent ES

| 动机 | 说明 |
|------|------|
| 避开长轨迹 GRPO 显存与 credit 问题 | ES 只需标量 reward，无需反传 |
| 与现有 **SGLang 独立部署** 栈对齐 | 通过 `/es/*` hook 在 GPU 上 apply/revert/update delta |
| 快速验证「搜索 agent 能否被黑盒优化」 | 先跑通 BCP + OpenResearcher rollout，再决定是否并入主 RL 路线 |

算法思路对齐 [Agentic-ESOpt](https://github.com/zz1358m/Agentic-ESOpt)：seeded Gaussian 扰动、z-score reward、加权 ES 更新；**工程上**改为 ClawGym / BCP / General-Agent 三套 rollout 后端 + 累积 `noise_weight`。

---

## 2. 工程结构（三档 rollout）

| `--rollout-backend` | 场景 | 依赖 |
|---------------------|------|------|
| `clawgym` | OpenClaw Docker 沙箱，2000 训练 / 80 eval 任务 | `clawGym/ClawGym-Agents/RL/data/`、`clawgym-rl:v0.1` |
| `general_agent` | 进程内 tool-use + DB reward（无 Docker） | Prime `general-agent` corpus |
| **`bcp`** | **BrowseComp-Plus 多轮 search/open** | OpenResearcher venv + **BM25 HTTP**（默认 `:8010`） |

搜索专项与 [search_benchmark_decision.md](./search_benchmark_decision.md) 中的 **`bcp_closed`** 一致；语料由 `scripts/build_bcp_es_corpus.py` 从 OpenResearcher Tevatron parquet 解密构建，默认输出 `/data/gpc/agentic_es/bcp_corpus/`（train shard 0–4，eval shard 5）。

**双 Python 环境（BCP 跑法）**：

- ES + SGLang：`/data/gpc/models/.venv`（或 `ES_PYTHON`）
- Agent rollout（OpenResearcher `BrowserPool`）：`/data/OpenResearcher/.venv`（`BCP_ROLLOUT_PYTHON`）

入口脚本：`agentic_es/scripts/run_es_bcp.sh`。

---

## 3. 已跑实验摘要（本机 `/data/gpc/agentic_es/runs/`，不入 Git）

### 3.1 ClawGym + Lingxi（Agent 能力，非闭集搜索）

- **Base**：`/data/models/Lingxi-Agent-2.2`（及早期 Lingxi-Agent-2.0 试验）
- **代表 run**：`lingxi_agent_es_alllinear_g8_*`（2026-09 起，8 GPU，`all_linear` scope，长 context / 高 turn 等多组超参）
- **目的**：验证 ES hook、ClawGym 并行、resume、`merged_gen*` 导出；**任务集不含 web_search**（与 ClawGym RL 相同限制）

### 3.2 BCP ES（闭集搜索，与 Search 项目直接相关）

**权威训练日志**（指标以此为准，勿把 `history.json` 里的 `n_ok` 当成官方准确率）：

`/data/gpc/agentic_es/runs/bcp_es_g70_trace_20260928_064200/train.nohup.log`

| Run ID | 配置要点（见 log `[setup]`） | Holdout eval：138 题固定集，`avg_reward` |
|--------|------------------------------|-------------------------------------------|
| `bcp_es_g70_trace_20260928_064200` | Base `Lingxi-Agent-2.2`；计划 **70 gen**（log 在 **gen 69 训练刚开始**处截断，未跑满）；`rollout_backend=bcp`；BM25 `http://127.0.0.1:8010`；692 train / 138 eval；`fitness_reward_mode=continuous`，`fitness_aggregation=task_minmax`；8×1 GPU，`use_es_hook=True`，`eval_step=1` | **before_train** 0.239130 → **gen0** 0.311594；**eval 最高** **gen9** **0.346377**；gen54 0.339855；gen59 0.289855（有 checkpoint）；**末条完整 eval** gen68 **0.318841** |
| `bcp_es_g70_plain_*` / 早期 `bcp_es_g70_20260924_*` | plain vs trace reward、冒烟与链路调试 | 见各自 run 目录下 `train.nohup.log` |

**产物示例**：

- `train.nohup.log`、`noise_weight/`、`history.json`、`eval_gen*/`、`checkpoints/checkpoint_gen*`（每 5 代，含 gen9 / gen54 / gen59 等）
- 曾用于本机 SGLang 试部署：`model/model_deploy/sglang_deploy_3_5.sh` 指向 `merged_gen0054`（对应 **gen54** eval avg_reward=0.339855，非 eval 曲线最高点 gen9）

**检索依赖**：训练/评测时 BM25 服务需可达（`BCP_SEARCH_URL`，常见 `http://127.0.0.1:8010`）；与 [openresearcher_env_setup.md](./openresearcher_env_setup.md) 检索层一致。

### 3.3 General-Agent smoke

- 脚本：`scripts/run_es_ga_smoke.sh`
- **目的**：无 Docker 的快速 ES 链路验证（与搜索无关，属工程回归）

---

## 4. 与 Agent Search 六阶段计划的映射

| Search 阶段 | Agent ES 已覆盖 | 仍缺 |
|-------------|-----------------|------|
| 2 Benchmark | BCP holdout 138 题作 **训练内 eval**；未统一写入 `search_eval/baselines/` | 与 v0.1 三套件对齐的 **官方 baseline JSON** |
| 3 方法 | 提供 **ES 作为 GRPO/SFT 的第三候选** | 决策者 memo 未收录；与 TRACE/ABSeeker credit 未对比 |
| 5 训练 | **已跑 BCP ES 长 run** | Claw **真 web**（Claw-Eval 65 题）ES/RL 未做 |
| 6 评估 | 仅 BCP shard-5 子集 | Claw web + τ³-Banking 上未测 merged checkpoint |

建议：阶段 5 的「双池架构」中，**闭集池**可继续用 `run_es_bcp.sh`；**Claw 主池**仍走 GRPO + search profile（见 [phase5_train.md](../phases/phase5_train.md)）。

---

## 5. 已知问题与下一步

1. **Eval 与 BCP 官方 harness 未完全同构**：训练内指标以 `train.nohup.log` 的 `[eval] avg_reward` 为准；对外数字仍需 `search_eval/bcp/` 对 merged 模型复测。
2. **长轨迹稳定性**：rollout / history 中偶发 SGLang `400` on `/v1/completions`；需与 context、tool 格式一并监控。
3. **算力与迭代成本**：70 gen × 8 候选 × 多轮 search，依赖检索与 rollout 并发调优（`eval_concurrency`、`tasks_per_group`）。
4. **待办（文档/工程）**  
   - [ ] 将最佳 `merged_gen*` 登记到 `search_eval/baselines/`  
   - [ ] 在 `method_decision_memo` 中增加 ES vs GRPO 一行对比  
   - [ ] ClawGym 启用 web 后是否复用同一 ES 框架（`rollout-backend clawgym` + search profile）

---

## 6. 快速命令

```bash
# BCP ES（需检索服务 + OpenResearcher venv）
cd /dev/gpc_code/agentic_es
./scripts/run_es_bcp.sh

# ClawGym ES（Ornith / 其他 base）
./scripts/run_ornith9b_es_smoke.sh --run-root /data/gpc/agentic_es/runs/my_run ...

# 导出 merged HF
./scripts/merge_export.sh "$BASE_DIR" /data/gpc/agentic_es/runs/<run_id>/noise_weight runs/exported
```

推送 **agent_ES** 代码仓库：

```bash
cd /dev/gpc_code/agentic_es && ./scripts/push_github.sh
```

推送 **本计划文档**（agent-search-plan）：

```bash
cd /dev/gpc_code/docs/agent_search && ./scripts/push_github.sh
```

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-10-13 | 初版：ClawGym / BCP / GA 三路 ES + BCP trace run 指标摘要 |
| 2026-10-13 | 修正 BCP 指标来源为 `train.nohup.log` 的 avg_reward（非 history n_ok） |
