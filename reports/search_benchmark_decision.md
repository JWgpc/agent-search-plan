# Search Benchmark 调研与 v0.1 选型决策

> Agent Search 能力提升项目 · 阶段 2  
> 版本：v0.1 | 日期：2026-08-28  
> 关联：[phase2_benchmark.md](../phases/phase2_benchmark.md) · [appendix_benchmark_inventory.md](../appendix_benchmark_inventory.md)

---

## 0. 决策摘要（2026-08-28）

**训练前主评测套件 v0.1** 暂定由以下 **三套** 组成，覆盖 **开网 agent / 闭集 deep search / 闭集 KB 检索+对话**：

| 套件 ID | Benchmark | 题量 | 能力轴 |
|---------|-----------|------|--------|
| **`bcp_closed`** | **BrowseComp-Plus** | **830** | 闭集长程 deep search（对标 TRACE） |
| **`claw_web_search`** | **Claw-Eval 搜索题** | **65** | 开网 `web_search` + `web_fetch`（生产对齐） |
| **`tau3_banking`** | **τ³-Banking**（`banking_knowledge`） | **97** | 闭集 KB 检索 + 银行客服多轮 tool |

**暂不纳入 v0.1 主套件**（保留备选）：QCB Research、HotpotQA/NQ、LiveBrowseComp、GAIA 全量、Claw-Eval KB-only 子集（与 τ³-Banking 部分重叠）。

配置文件：`search_eval/configs/benchmark_suite.yaml`  
Claw 任务清单：`search_eval/configs/task_lists/claw_eval_web_search.txt`

---

## 1. 为什么先定 Benchmark 再训练

- GRPO / SFT 需要 **可重复的 eval** 定义提升，否则无法判断是算法增益还是评测漂移（R5）。
- 三套互补：**BCP** 对标论文闭集 deep search；**Claw-Eval web** 对齐 OpenClaw 生产工具；**τ³-Banking** 覆盖 **memory/KB 式检索** 在多轮对话中的表现（GPC 已有 `tau2-bench` 跑通经验）。

---

## 2. 调研总览（候选 Benchmark）

### 2.1 GPC 仓库内

| Benchmark | 题量 | 测什么 | 本地/免搜索 Key | GPC harness |
|-----------|------|--------|-----------------|-------------|
| Claw-Eval · Web | 65 | 多轮 web 搜+读+交付 | ❌ 63 题需 `SERP_DEV_KEY`（`web_real`）；2 题 mock web | ✅ `（GPC）claw_eval_new/claw-eval/` |
| Claw-Eval · KB | 27 | mock KB 检索 | ✅ | ✅ |
| QwenClawBench · Research | 7（全库 100） | 真实 OpenClaw research | 多数 workspace 内，无强制开网 | ✅ |
| **τ³-Banking** | **97** | KB 检索 + 客服 policy + DB 动作 | ✅ **`--retrieval-config bm25`** 全离线 | ✅ **`tau2-bench/`** |

### 2.2 论文 / 社区（闭集与 QA）

| Benchmark | 题量 | 测什么 | 本地/免搜索 Key | GPC harness |
|-----------|------|--------|-----------------|-------------|
| **BrowseComp-Plus** | **830** + 100K 文档 | 闭集 deep search；去 gold 测真检索 | ✅ BM25/dense 本地 | ⚠️ OpenResearcher / Tevatron |
| BrowseComp 开网 | 1,266 | 极难开网 browse | ❌ Serper 等 | ⚠️ OpenResearcher serper 模式 |
| HotpotQA / NQ | dev 7.4K / 3.6K | 单/双 hop EM | ✅ 本地 wiki FAISS | Search-R1 slime 示例 |
| LiveBrowseComp | 335 | 抗「伪搜索」时间敏感题 | ❌ | ❌ |
| GAIA | 466 | 长程 multi-tool research | ❌ 通常开网 | ⚠️ |
| OpenResearcher 闭集 | 6,102 | 同族 BCP 设定 | ✅ | ⚠️ 与 BCP 重叠，v0.1 不重复纳入 |

完整 URL 见 [rl_search_data_landscape.md §8](./rl_search_data_landscape.md#8-项目与数据-url-索引)。

---

## 3. v0.1 选定套件详解

### 3.1 BrowseComp-Plus（`bcp_closed`）

| 项 | 内容 |
|----|------|
| **特点** | 从 BrowseComp 抽 **830** 题；固定 **~100K** 文档闭集；含 evidence + hard negatives；可 disentangle 检索 vs LLM |
| **测什么** | 多轮 `search` / `open` / `find`（或等价工具）在闭集上的 **短答案准确率** |
| **题量** | **830** queries；corpus **100,195** docs |
| **指标** | 准确率 / EM（与 TRACE、OpenResearcher 论文一致） |
| **论文** | [BrowseComp-Plus ACL 2026](https://doi.org/10.18653/v1/2026.acl-long.1023) |

**使用步骤**

1. 下载语料与索引（HF）  
2. clone [OpenResearcher](https://github.com/TIGER-AI-Lab/OpenResearcher) 或 Tevatron 评测脚本  
3. 起本地检索服务（BM25 或 dense）  
4. 接 agent loop + 被测 LLM（本地 sglang 即可）

**依赖配置**

| 依赖 | 说明 |
|------|------|
| 数据 | [browsecomp-plus](https://huggingface.co/datasets/Tevatron/browsecomp-plus) · [corpus](https://huggingface.co/datasets/Tevatron/browsecomp-plus-corpus) · [indexes](https://huggingface.co/datasets/Tevatron/browsecomp-plus-indexes) |
| Java 21 | BM25（Pyserini） |
| GPU 可选 | dense：`Qwen/Qwen3-Embedding-8B`，显存 ~15GB |
| 搜索 API | **不需要**（闭集） |
| 被测模型 | OpenAI-compatible API（如 `model/model_deploy/sglang_deploy_3_5.sh`） |

**Smoke 建议**：先跑 **100 题** subset，再全量 830。

**与训练关系**：闭集 RL smoke 可与同一 corpus 对齐（见 [openresearcher_env_setup.md](./openresearcher_env_setup.md)）；**评测语料 ≠ OpenResearcher 训练 corpus**，勿与 BCP 混用路径（R8）。

---

### 3.2 Claw-Eval 搜索题（`claw_web_search`）

| 项 | 内容 |
|----|------|
| **特点** | 300 任务中人机 verified 子集；**65** 题显式使用 `web_search` / `web_fetch`；含安全题 T073 |
| **测什么** | OpenClaw agent：**Completion / Safety / Robustness**；多轮开网研究、金融、合规、CVE 等 |
| **题量** | **65**（清单见 `search_eval/configs/task_lists/claw_eval_web_search.txt`） |
| **指标** | 开发期 **Pass@1**；对外对标 **Pass^3**（Claw-Eval 官方，D3 待拍板） |
| **论文** | [Claw-Eval arXiv:2604.06132](https://arxiv.org/abs/2604.06132) |

**任务构成**

| 后端 | 题数 | 说明 |
|------|------|------|
| `web_real` | **63** | 真实 Serp（Novada ScraperAPI），有本地 cache |
| `mock_services/web` | **2** | T043/T044，fixture 开网，**无需 SERP** |

**使用步骤**

```bash
cd /dev/gpc_code/claw_eval_new/claw-eval
pip install uv && uv venv --python 3.11 && source .venv/bin/activate
export OPENROUTER_API_KEY=...          # 被测模型
export SERP_DEV_KEY=...                # web_real 任务（63 题）
bash scripts/test_sandbox.sh
claw-eval batch --config config_general.yaml \
  --tasks-dir tasks \
  --task-filter <来自 task_lists> \
  --sandbox --trials 3 --parallel 8
```

**依赖配置**

| 依赖 | 说明 |
|------|------|
| `SERP_DEV_KEY` | **63 题必需**（[Novada](https://www.novada.com/) 等） |
| 被测模型 API | OpenAI-compatible |
| Judge LLM | 默认 Gemini-3-flash / Claude Opus（可改 config 换本地 judge） |
| Docker sandbox | 建议；Linux ≥32GB RAM |
| HF fixtures | [claw-eval/Claw-Eval](https://huggingface.co/datasets/claw-eval/Claw-Eval) |

**代码路径**：`/dev/gpc_code/（GPC）claw_eval_new/claw-eval/`

---

### 3.3 τ³-Banking（`tau3_banking`）

| 项 | 内容 |
|----|------|
| **特点** | τ³-bench 的 **`banking_knowledge`** 域；发表名 **τ-knowledge**；~**698** 篇银行政策文档；可配置 RAG pipeline |
| **测什么** | 客服 agent：**KB_search** 检索政策 + 多轮 user sim + **DB 动作正确性**（申请卡、改账户等） |
| **题量** | **97** tasks |
| **指标** | **Pass^k**（leaderboard 常用 pass@1～4）；动作级 DB reward |
| **论文** | [τ-Knowledge arXiv:2603.04370](https://arxiv.org/abs/2603.04370) · [τ³ 总述 arXiv:2603.13686](https://arxiv.org/abs/2603.13686) |

**使用步骤**（GPC 已有范例：`tau2-bench/logs/run_ornith15_qwen38_tau3.sh`）

```bash
cd /dev/gpc_code/tau2-bench
uv sync --extra knowledge
# .env：被测 agent + user simulator LLM（LiteLLM）

tau2 run \
  --domain banking_knowledge \
  --retrieval-config bm25 \
  --agent-llm openai/<your-model> \
  --user-llm openai/<user-sim-model> \
  --num-trials 1 \
  --max-concurrency 8 \
  --save-to banking_<model>_v1
```

**依赖配置**

| 依赖 | v0.1 推荐 `bm25` | 备注 |
|------|------------------|------|
| 搜索 / embedding API | **不需要** | BM25 全本地 |
| 被测 agent LLM | ✅ | 本地 sglang + `--agent-llm openai/...` |
| User simulator LLM | ✅ | 如 `Qwen3.8-27B` 本地 endpoint |
| `OPENAI_API_KEY` | 仅 dense/alltools 配置需要 | 默认 **`bm25` 免 Key** |
| sandbox-runtime | 仅 `terminal_use` / `alltools` 需要 | v0.1 不用 |
| Python | ≥3.12，`uv sync --extra knowledge` | |
| 数据 | 随仓库 `data/tau2/domains/banking_knowledge/` | 698 docs + 97 tasks |

**检索配置备选**（见 `src/tau2/knowledge/README.md`）

| config | 离线 | 说明 |
|--------|------|------|
| **`bm25`** | ✅ | **v0.1 默认**；`KB_search` BM25 |
| `bm25_grep` | ✅ | + grep |
| `alltools` | 部分 | BM25 离线 + OpenAI dense + shell |
| `grep_only` / `terminal_use` | ✅/需 sandbox | agentic search 变体 |

**代码路径**：`/dev/gpc_code/tau2-bench/`  
**Leaderboard**：[taubench.com](https://taubench.com)（τ³-Banking 栏）

**纳入理由**：补足 Claw-Eval **KB/mock** 与 BCP **闭集 QA** 之间的 **「检索 + 多轮对话 + 结构化 tool/DB」** 轴；与 GPC `memory_search` 能力路线一致，且 **bm25 可零搜索 Key 起步**。

---

## 4. 三套件对比矩阵

| 维度 | BrowseComp-Plus | Claw-Eval Web | τ³-Banking |
|------|-----------------|---------------|------------|
| 题量 | 830 | 65 | 97 |
| 工具范式 | search/open/find | web_search/web_fetch | KB_search (+ grep/shell 可选) |
| 开网 | ❌ 闭集 | ✅ 真 web（63/65） | ❌ 闭集 KB |
| 免搜索 Key | ✅ | ❌（除 2 mock） | ✅（bm25） |
| 多轮对话 | 中（tool 轮次） | 高（agent task） | 高（user sim） |
| 对标论文 | TRACE / OpenResearcher | Claw 生产 | τ-knowledge |
| GPC 成熟度 | 需接 OR 脚本 | runner 现成 | **已跑通**（见 logs） |

---

## 5. v0.1 跑分约定（待 D3/D4 确认）

| 套件 | 默认指标 | Trials | Baseline 模型 |
|------|----------|--------|---------------|
| bcp_closed | 准确率 / EM | 1（smoke）→ 论文设定 | 待定（D4） |
| claw_web_search | Pass@1（dev）/ Pass^3（report） | 3 | 待定（D4） |
| tau3_banking | Pass@1 | 1→4（对标 leaderboard） | 待定（D4） |

**汇总**：三分项独立报分，**不做加权总分**；训练是否提升以三项分别对比 baseline。

---

## 6. 未选入 v0.1 的说明

| 候选 | 未选原因 |
|------|----------|
| QCB Research 7 | 与 Claw web 场景重叠；v0.1 先 Claw 官方 65 题 |
| HotpotQA/NQ | L1 EM，schema 不同；留作 GRPO smoke |
| LiveBrowseComp | 无 harness；后期抗刷榜 |
| Claw-Eval KB 27 题 | τ³-Banking 覆盖 KB+对话，粒度更细 |
| OpenResearcher 6102 eval | 与 BCP 同族，v0.1 避免重复 |

---

## 7. 阶段 2 下一步

| 顺序 | 动作 | 产出 |
|------|------|------|
| 1 | 人：定 D3 指标、D4 baseline ckpt | decision_log |
| 2 | 批 `SERP_DEV_KEY`（Claw 63 题） | 可跑 claw_web_search |
| 3 | 下 BCP corpus+index；起检索 smoke | bcp_closed 100 题 |
| 4 | `tau2 run` banking bm25 baseline | tau3_banking summary |
| 5 | 聚合三分 → `baselines/{model}/summary.json` | baseline_report.md |

---

## 8. 参考链接

| 资源 | URL |
|------|-----|
| BrowseComp-Plus 数据 | https://huggingface.co/datasets/Tevatron/browsecomp-plus |
| BrowseComp-Plus corpus | https://huggingface.co/datasets/Tevatron/browsecomp-plus-corpus |
| OpenResearcher（BCP eval 脚本） | https://github.com/TIGER-AI-Lab/OpenResearcher |
| Claw-Eval | https://github.com/claw-eval/claw-eval |
| τ²/τ³-bench | https://github.com/sierra-research/tau2-bench |
| τ-Knowledge 论文 | https://arxiv.org/abs/2603.04370 |

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-08-28 | v0.1：调研摘要 + 暂定三套件 BCP + Claw-Eval web + τ³-Banking |
