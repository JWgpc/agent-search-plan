# 01 — 人机分工

本文档按六个阶段列出 **Agent（Cursor / 自动化）** 与 **人（决策者 / 审核者）** 的职责边界。  
原则：**Agent 做调研、脚本、汇总与重复劳动；人做拍板、抽检、成本与最终 sign-off。**

---

## 总览表

| 角色 | 典型产出 | 不应越权 |
|------|----------|----------|
| **Agent** | 文献摘要、代码调研、task 清单、runner 脚本、数据转换、日志报告 | 未经确认改训练超参、提交大规模 API 费用、发布 checkpoint |
| **人** | 优先级、路线选择、抽检、密钥、算力、选优、sign-off | — |

---

## 阶段 1：信息收集与调研

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | 检索 arXiv/GitHub/HF；生成方法对比表；阅读仓库内 Search-R1、Claw-Eval grader、QCB 任务并摘要；绘制「方法 × 能力 × 可复用性」矩阵；撰写 `search_landscape_report.md` 初稿 |
| **人需决策/审核** | 调研深度与三类能力优先级；审核 report、剔除与 OpenClaw 不兼容方案；批准 Serper/Brave、wiki-18 索引等外部依赖 |

**交付物**：`docs/agent_search/reports/search_landscape_report.md`（阶段 1 完成后）

---

## 阶段 2：Benchmark 与 Baseline

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | 自动筛选 Claw-Eval/QCB 搜索 task；设计 `search_eval/` 目录与 yaml；编写 runner/聚合脚本；对接 SGLang 部署脚本；生成 baseline 报告草稿 |
| **人需决策/审核** | 主指标 Pass@1 vs Pass^3；baseline checkpoint；BrowseComp/GAIA API 成本；审核 baseline 是否 infra 误判 |

**交付物**：Benchmark 套件 v0.1、task 清单、baseline 分数表

---

## 阶段 3：方法决策与冒烟测试

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | 各路线最小 POC；执行冒烟、收集 reward/通过率；路线对比报告（效果 × 成本 × 复杂度） |
| **人需决策/审核** | **核心**：选定 SFT+RL / RL-only / SFT-only；分阶段策略（先 QA 再 agent 再 browser）；冒烟通过标准；全量训练算力预算 |

**交付物**：`reports/method_decision_memo.md`、冒烟 raw results

---

## 阶段 4：数据准备与质量核验

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | rollout 脚本；格式转换、dedup、token 统计；自动质检（tool 合法性、轨迹完整性）；数据分布报告 |
| **人需决策/审核** | 质量 rubric 与 5–10% 抽检；隐私/合规审核；SFT vs RL 配比；强模型 rollout API 费用 |

**交付物**：`data/search_sft_v1/`、`data/search_rl_v1/`、质量报告

---

## 阶段 5：环境构建与训练

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | 训练 yaml/shell；提交 job、抓 log、画曲线；定时 eval subset；异常告警报告 |
| **人需决策/审核** | lr/batch/KL/reward 权重；算力调度与中断；checkpoint 选优；搜索 RL vs ClawGym 混合比例；reward hacking 修正 |

**交付物**：2–3 个候选 checkpoint、训练对比表

---

## 阶段 6：效果评估与迭代

| 类型 | 事项 |
|------|------|
| **Agent 可辅助** | 全量 benchmark run；baseline vs 候选对比；失败 case 聚类；transcript 归档 |
| **人需决策/审核** | 是否达到发布标准；top-20 失败人工分析；是否 merge Ornith 主线；v2 roadmap |

**交付物**：`reports/search_capability_evaluation_report.md`、production checkpoint 建议

---

## 门禁：何时必须人工介入

以下事项 **Agent 仅可提案，不可自行执行**：

1. 对外 API 密钥配置与单次 >$X 的调用预算  
2. 多卡 / 多节点训练 job 提交  
3. 将 checkpoint 标记为 production / merge 主线  
4. 修改 ClawGym 默认 deny 列表并上生产训练  
5. 对外发布 benchmark 分数或论文级结论  

使用 [templates/decision_log.md](./templates/decision_log.md) 记录每次人工决策。
