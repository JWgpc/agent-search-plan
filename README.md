# Agent Search 能力提升 — 项目文档

> 提升 OpenClaw agent 在多轮工具调用中的**搜索能力**，覆盖 `web_search`、`memory_search`（知识库/RAG）与**浏览器浏览网页**三类能力。  
> 本文档集为项目计划落地版，供逐步评审与执行；**不替代** Cursor Plan 文件，与之同步维护。

## 文档索引

| 文档 | 说明 | 状态 |
|------|------|------|
| **[TASK_STATUS.md](./TASK_STATUS.md)** | **任务状态记录（各阶段 Agent / 决策者待办）** | 维护中 |
| [reports/search_landscape_report.md](./reports/search_landscape_report.md) | 阶段 1 Landscape 调研报告 | v0.1 |
| [reports/five_papers_deep_dive.md](./reports/five_papers_deep_dive.md) | 五篇 agent search 代表论文深度解读 | v0.1 |
| [reports/trace_vs_abseeker_credit.md](./reports/trace_vs_abseeker_credit.md) | TRACE vs ABSeeker credit 专篇（**TRACE：决策者已精读**） | v0.2 |
| [reports/important_references.md](./reports/important_references.md) | **重要参考文献登记**（精读状态、复现疑问） | v0.1 |
| [00_overview.md](./00_overview.md) | 背景、目标、范围、现状诊断 | 初稿 |
| [01_human_agent_roles.md](./01_human_agent_roles.md) | 六阶段人机分工总表 | 初稿 |
| [02_milestones_timeline.md](./02_milestones_timeline.md) | 里程碑、时间线、依赖关系 | 初稿 |
| [03_risks_and_open_questions.md](./03_risks_and_open_questions.md) | 风险、待决策项、决策记录 | 初稿 |
| [appendix_codebase_inventory.md](./appendix_codebase_inventory.md) | 仓库内可复用代码与路径 | 初稿 |
| [appendix_benchmark_inventory.md](./appendix_benchmark_inventory.md) | 评测任务清单与分层 | 初稿 |

### 分阶段计划

| 阶段 | 文档 | 周期（估） | 核心交付物 |
|------|------|------------|------------|
| 1 | [phases/phase1_landscape.md](./phases/phase1_landscape.md) | ~2 周 | Landscape Report |
| 2 | [phases/phase2_benchmark.md](./phases/phase2_benchmark.md) | ~2 周 | Benchmark 套件 v0.1 + baseline |
| 3 | [phases/phase3_method_poc.md](./phases/phase3_method_poc.md) | ~1–2 周 | 方法决策 memo + 冒烟测试 |
| 4 | [phases/phase4_data.md](./phases/phase4_data.md) | ~3–4 周 | SFT/RL 数据集 v1 |
| 5 | [phases/phase5_train.md](./phases/phase5_train.md) | ~3–4 周 | 训练 checkpoint |
| 6 | [phases/phase6_eval.md](./phases/phase6_eval.md) | ~2 周+ | 评估报告 + sign-off |

### 模板

- [templates/decision_log.md](./templates/decision_log.md) — 人工决策记录
- [templates/phase_gate_checklist.md](./templates/phase_gate_checklist.md) — 阶段门禁检查清单

## 能力范围（已确认）

1. **Web 搜索**：`web_search` + `web_fetch`（Brave/SERP 等）
2. **知识库检索**：`memory_search` + workspace RAG
3. **浏览器**：打开网页、阅读、交互式信息获取

训练路线（SFT / RL / SFT+RL）**尚未确定**，在阶段 1–3 调研与冒烟后决策。

## 建议阅读顺序

1. **`TASK_STATUS.md`** — 查看当前进度与待办  
2. `00_overview.md` — 了解为什么要做、当前缺口在哪  
3. `01_human_agent_roles.md` — 明确谁做什么  
4. `phases/phase1_landscape.md` — 从调研阶段开始逐步推进  
5. `03_risks_and_open_questions.md` — 跟踪待拍板事项  

## 与代码目录的对应关系（规划，尚未实现）

```
/dev/gpc_code/
  docs/agent_search/          ← 本计划文档（当前阶段）
  search_eval/                ← 阶段 2：评测套件（待建）
  data/search_sft_v1/         ← 阶段 4：训练数据（待建）
  data/search_rl_v1/
```

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-08-26 | 新增 `TASK_STATUS.md` 任务状态记录 |
| 2026-08-26 | 新增 `TASK_STATUS.md` 任务状态记录 |
| 2026-08-26 | 阶段 1 Landscape Report v0.1（Agent 任务完成） |
| 2026-08-27 | 新增五篇论文深度解读 `reports/five_papers_deep_dive.md` |
| 2026-08-27 | 新增 TRACE vs ABSeeker credit 专篇 `reports/trace_vs_abseeker_credit.md` |
| 2026-08-27 | TRACE 标重要参考文献、决策者已精读；新增 `reports/important_references.md`（turn reward 疑问 TRACE-Q1～Q3） |
| 2026-08-26 | 新增 `TASK_STATUS.md` 任务状态记录 |
