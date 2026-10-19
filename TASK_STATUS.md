# 任务状态记录

> 跟踪 Agent Search 能力提升项目各阶段完成状况。  
> **状态枚举**：`待办` | `进行中` | `已完成` | `阻塞` | `跳过`  
> 更新本文件后请同步修改「最后更新」日期，重大变更可 commit 并 push。

**最后更新**：2026-10-19  
**当前阶段**：阶段 2 进行中（**v0.1 Benchmark 三套件已定**；baseline 待跑）；**并行**：Agent ES + BCP 训练已跑通  
**GitHub**：[JWgpc/agent-search-plan](https://github.com/JWgpc/agent-search-plan)

---

## 总览

| 阶段 | 名称 | 阶段状态 | 门禁 |
|------|------|----------|------|
| 0 | 计划文档落地 | 已完成 | — |
| 1 | 信息收集与调研 | 进行中 | 未通过 |
| 2 | Benchmark 与 Baseline | 进行中 | 未通过 |
| 3 | 方法决策与冒烟测试 | 待办 | 未通过 |
| 4 | 数据准备与质量核验 | 待办 | 未通过 |
| 5 | 环境构建与训练 | 待办 | 未通过 |
| 6 | 效果评估与迭代 | 待办 | 未通过 |

---

## 并行探索 — Agent ES（[agent_ES](https://github.com/JWgpc/agent_ES)）

**说明**：与阶段 3「GRPO/SFT 路线」并行；详见 [reports/agent_es_attempts.md](./reports/agent_es_attempts.md)。

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| ES-A01 | noise_weight + SGLang `/es/*` hook 框架 | **已完成** | `agentic_es/` |
| ES-A02 | ClawGym rollout + Lingxi base 长 run | **已完成** | runs 在 `/data/gpc/agentic_es/runs/` |
| ES-A03 | BCP corpus + `run_es_bcp.sh` 闭集搜索 ES | **已完成** | OpenResearcher 子进程 rollout |
| ES-A04 | BCP holdout 138 题 eval 曲线（trace reward run） | **已完成** | 见 `train.nohup.log`：before 0.239 → **best gen9 avg_reward=0.346**（run 未跑满 70 gen） |
| ES-A05 | merged checkpoint 五套件对外评测（ES-1009-54） | **已完成** | BCP +34.0、τ³ +0.7 等，见 [agent_es_attempts.md §3.4](./reports/agent_es_attempts.md) |
| ES-A05b | 结果写入 `search_eval/baselines/` JSON | 待办 | 文档已记，机器可读 baseline 待建 |
| ES-A06 | Claw 真 web 任务 ES / 或纳入 method memo | 待办 | 依赖 search profile |

---

## 阶段 0 — 计划文档落地

**阶段状态**：已完成  
**说明**：项目计划写入 `docs/agent_search/`，已推送 GitHub。

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P0-A01 | 编写项目计划文档（overview / phases / 附录） | 已完成 | |
| P0-A02 | 编写人机分工、里程碑、风险与待决策项 | 已完成 | |
| P0-A03 | 初始化 git 仓库并推送 GitHub | 已完成 | 见 `GITHUB_UPLOAD.md` |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P0-H01 | 确认能力范围（web + KB + browser） | 已完成 | |
| P0-H02 | 确认计划文档结构与六阶段划分 | 待办 | 可评审后勾选 |

---

## 阶段 1 — 信息收集与调研

**周期**：~2 周  
**阶段状态**：进行中（Agent 任务已完成，待人 P1-H01～H04）  
**目标**：输出《Search Capability Landscape Report》  
**详细计划**：[phases/phase1_landscape.md](./phases/phase1_landscape.md)  
**交付报告**：[reports/search_landscape_report.md](./reports/search_landscape_report.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P1-A01 | 检索 arXiv / GitHub / HuggingFace 相关项目与论文 | 已完成 | 方向 A–E，见 landscape report §3–7 |
| P1-A02 | 阅读仓库内 Search-R1 README、Claw-Eval grader、QCB 搜索类任务并摘要 | 已完成 | 见 report §8 |
| P1-A03 | 填充「方法 × 能力（web/KB/browser）× 可复用性」对比表（≥10 行） | 已完成 | report §9，12 行 |
| P1-A04 | 撰写 `reports/search_landscape_report.md` 初稿 | 已完成 | v0.1 |
| P1-A05 | 输出 3–5 条方法 shortlist（含 OpenClaw 集成难度与风险） | 已完成 | 路线 A–D，report §10 |
| P1-A06 | 更新 `03_risks_and_open_questions.md` 中 D1 等决策选项与建议 | 已完成 | D1/D2/D6 Agent 建议 |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P1-H01 | 确认调研深度与优先级（三类能力并行或分阶段） | 待办 | 对应 D1 |
| P1-H02 | 评审 Landscape Report，剔除与 OpenClaw 工具栈不兼容方案 | 待办 | |
| P1-H03 | 批准外部依赖（Serper/Brave API、wiki-18 索引等） | 待办 | |
| P1-H04 | 阶段 1 门禁 sign-off | 待办 | 见 phase1 DoD |

### 重要文献 · 决策者精读（阶段 1 延伸）

| ID | 文献 | 状态 | 备注 |
|----|------|------|------|
| P1-LIT-01 | **TRACE** arXiv:2607.13988 | **决策者已精读** | ⭐ 重要参考文献；turn reward POC 候选；疑问 TRACE-Q1～Q3 见 [important_references.md](./reports/important_references.md) |
| P1-LIT-02 | ABSeeker arXiv:2608.05102 | 已对照精读 | 与 TRACE 合读，见 trace_vs_abseeker_credit.md |
| P1-LIT-03 | **OpenResearcher** arXiv:2603.20278 | **决策者认定参考价值较高**（2026-08-28） | [rl_search_data_landscape.md](./reports/rl_search_data_landscape.md) · [openresearcher_env_setup.md](./reports/openresearcher_env_setup.md) |

---

## 阶段 2 — Benchmark 设计与 Baseline

**周期**：~2 周（与阶段 4 部分并行）  
**阶段状态**：进行中（v0.1 套件已定；baseline 待跑）  
**目标**：分层评测体系 + baseline 分数  
**详细计划**：[phases/phase2_benchmark.md](./phases/phase2_benchmark.md)  
**选型文档**：[reports/search_benchmark_decision.md](./reports/search_benchmark_decision.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P2-A01 | 从 Claw-Eval 导出 web 搜索 task 清单 | **已完成** | 65 题 → `search_eval/configs/task_lists/claw_eval_web_search.txt` |
| P2-A02 | 搭建 `search_eval/` 目录结构与 README | **已完成** | v0.1 配置 |
| P2-A03 | 编写 `benchmark_suite.yaml` 与 task_lists | **已完成** | 三套件 BCP + Claw + τ³-Banking |
| P2-A07 | 撰写 Benchmark 调研与选型文档 | **已完成** | search_benchmark_decision.md |
| P2-A04 | 编写 runner / 聚合脚本（Claw-Eval、QCB、Search-R1 eval） | 待办 | |
| P2-A05 | 对接 SGLang 部署脚本，跑 v0.1 最小评测套件 | 待办 | 需 API key |
| P2-A06 | 生成 `reports/baseline_report.md` 与 `baselines/{model}/summary.json` | 待办 | |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P2-H01 | 确定主指标 Pass@1 vs Pass^3（D3） | 待办 | |
| P2-H02 | 选定 baseline 模型 checkpoint（D4） | 待办 | |
| P2-H03 | 配置 SERP / Brave 等 API 密钥 | 待办 | |
| P2-H04 | 审批 BrowseComp / GAIA 等外部 benchmark API 成本（D5） | **已定** | v0.1 用 BCP 闭集（无开网 API）；GAIA 延后 |
| P2-H05 | 审核 baseline 结果，排除 infra 误判 | 待办 | |
| P2-H06 | 阶段 2 门禁 sign-off | 待办 | D3、D4 写入 decision_log |

---

## 阶段 3 — 方法决策与冒烟测试

**周期**：~1–2 周  
**阶段状态**：待办  
**依赖**：阶段 1、阶段 2  
**目标**：选定训练路线并完成冒烟验证  
**详细计划**：[phases/phase3_method_poc.md](./phases/phase3_method_poc.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P3-A01 | 实现路线 A POC（SFT 100 条搜索轨迹格式验证） | 待办 | SM-SFT-100 |
| P3-A02 | 实现路线 B POC（Search-R1 50 step GRPO） | 待办 | SM-R1-50 |
| P3-A03 | 实现 ClawGym 启用 web 的 10 任务冒烟（SM-CG-WEB-10） | 待办 | |
| P3-A04 | 实现 Browser 5 任务 SFT schema 验证（SM-BRW-5） | 待办 | |
| P3-A05 | 汇总冒烟结果至 `reports/smoke_test_results.md` | 待办 | |
| P3-A06 | 撰写路线对比报告（效果 × 成本 × 工程复杂度） | 待办 | 供决策 memo 参考 |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P3-H01 | 选定主训练路线：SFT+RL / RL-only / SFT-only（D2） | 待办 | |
| P3-H02 | 确定分阶段策略（先 QA → agent → browser 等） | 待办 | |
| P3-H03 | 确定冒烟测试通过标准 | 待办 | |
| P3-H04 | 确定相对 baseline 提升目标 X%（D8） | 待办 | |
| P3-H05 | 批准全量数据与训练算力预算 | 待办 | |
| P3-H06 | 发布 `reports/method_decision_memo.md` 并 sign-off | 待办 | |

---

## 阶段 4 — 数据准备与质量核验

**周期**：~3–4 周（与阶段 2 并行）  
**阶段状态**：待办  
**目标**：SFT / RL / DPO 搜索训练数据 v1  
**详细计划**：[phases/phase4_data.md](./phases/phase4_data.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P4-A01 | 设计并实现强模型 rollout 脚本（Claw-Eval / QCB 搜索任务） | 待办 | |
| P4-A02 | 转换 HotpotQA/NQ 等为 OpenClaw tool-call 格式（RL 冷启动） | 待办 | |
| P4-A02b | 撰写 RL 搜索数据/合成项目调研文档 | **已完成** | [rl_search_data_landscape.md](./reports/rl_search_data_landscape.md) |
| P4-A02c | 撰写 OpenResearcher 环境构建指南（含 Claw 适配） | **已完成** | [openresearcher_env_setup.md](./reports/openresearcher_env_setup.md) |
| P4-A03 | 构建 `data/search_sft_v1/`（目标 2k–5k 条） | 待办 | |
| P4-A04 | 构建 `data/search_rl_v1/`（目标 500–1k 任务） | 待办 | |
| P4-A05 | 构建 DPO 负样本 / pairs（可选，~1k） | 待办 | |
| P4-A06 | 自动质检：tool 合法性、轨迹完整性、dedup、token 统计 | 待办 | |
| P4-A07 | 输出 `reports/data_quality_report_v1.md` | 待办 | |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P4-H01 | 定义数据质量 rubric | 待办 | |
| P4-H02 | 完成 5–10% 人工抽检并记录 `spot_check_log.md` | 待办 | |
| P4-H03 | 隐私 / 合规审核 | 待办 | |
| P4-H04 | 确定 SFT vs RL 数据配比 | 待办 | |
| P4-H05 | 批准强模型 rollout API 费用 | 待办 | |
| P4-H06 | 阶段 4 门禁 sign-off | 待办 | |

---

## 阶段 5 — 环境构建与训练

**周期**：~3–4 周  
**阶段状态**：待办  
**依赖**：阶段 3、阶段 4  
**目标**：搜索专项训练 run + 候选 checkpoint  
**详细计划**：[phases/phase5_train.md](./phases/phase5_train.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P5-A01 | ClawGym 新增 search profile，启用 web_search / memory_search | 待办 | `clawgym_rl_rollout.py` |
| P5-A02 | 扩展工具沙箱：mock SERP + 搜索缓存 | 待办 | `clawgym_tools.py` |
| P5-A03 | slime 搜索 RL 适配 Qwen3.5 chat template | 待办 | 基于 Search-R1；闭集见 openresearcher_env_setup.md |
| P5-A04 | 搜索 SFT 数据 tokenization 与训练脚本 | 待办 | |
| P5-A05 | 编写 `search_train/` 配置与 run 脚本 | 待办 | |
| P5-A06 | 执行训练 job，监控 loss / reward / tool 分布 | 待办 | 需人批准提交 |
| P5-A07 | 定时触发 eval subset，输出 checkpoint 对比表 | 待办 | |
| P5-A08 | 异常检测与告警报告（API 失败、reward hacking） | 待办 | |
| P5-A09 | 将 Agent ES BCP 最佳 checkpoint 纳入 search_eval baseline 表 | 待办 | 见 [agent_es_attempts.md](./reports/agent_es_attempts.md) |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P5-H01 | 拍板超参（lr、batch、KL、reward 权重） | 待办 | |
| P5-H02 | 算力调度与训练中断 / 重启决策 | 待办 | |
| P5-H03 | 确定搜索 RL 与 ClawGym 混合训练比例（D7） | 待办 | |
| P5-H04 | 批准多卡 / 多节点训练 job 提交 | 待办 | |
| P5-H05 | 从 2–3 个候选 checkpoint 中选优 | 待办 | |
| P5-H06 | reward hacking 时的 reward 设计修正 | 待办 | |
| P5-H07 | 阶段 5 门禁 sign-off | 待办 | |

---

## 阶段 6 — 效果评估与迭代

**周期**：~2 周 + 持续  
**阶段状态**：待办  
**依赖**：阶段 5  
**目标**：全量评估 + 发布 sign-off  
**详细计划**：[phases/phase6_eval.md](./phases/phase6_eval.md)

### Agent

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P6-A01 | 跑阶段 2 全量 benchmark 套件 | 待办 | |
| P6-A02 | 生成 baseline vs 候选模型对比报告 | 待办 | |
| P6-A03 | 失败 case 聚类（no_search / over_search 等） | 待办 | |
| P6-A04 | 归档真实场景 transcript | 待办 | QCB 全量 / 内部任务 |
| P6-A05 | 撰写 `reports/search_capability_evaluation_report.md` | 待办 | |
| P6-A06 | 撰写 `reports/production_checkpoint_recommendation.md` | 待办 | |

### 决策者

| ID | 任务 | 状态 | 备注 |
|----|------|------|------|
| P6-H01 | 确认是否达到发布标准（相对 D8 目标） | 待办 | |
| P6-H02 | 完成 top-20 失败 case 人工分析 | 待办 | |
| P6-H03 | 确认安全子集（如 T073）无回归 | 待办 | |
| P6-H04 | 决定是否 merge 至 Ornith 主线 | 待办 | |
| P6-H05 | 批准对外发布 benchmark 结论 | 待办 | |
| P6-H06 | 制定 v2 roadmap 并 sign-off | 待办 | |

---

## 更新说明

1. 任务完成后将「状态」改为 `已完成`，在「备注」填交付物路径或 PR 链接。  
2. 阻塞项改为 `阻塞`，备注写依赖与负责人。  
3. 阶段内全部必要任务完成且决策者 sign-off 后，将总览表「阶段状态」改为 `已完成`，「门禁」改为 `已通过`。  
4. 人工决策同步记录至 [templates/decision_log.md](./templates/decision_log.md) 或 `reports/decisions/`。
