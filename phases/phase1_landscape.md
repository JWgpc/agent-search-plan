# 阶段 1 — 信息收集与调研

**周期**：~2 周  
**目标**：梳理提升 agent 多轮搜索能力的方法论、开源实现与论文，输出《Search Capability Landscape Report》。

---

## 1. 调研方向与代表工作

### A. 开放域 QA 搜索 RL

| 项目/论文 | 链接 | 要点 |
|-----------|------|------|
| Search-R1 | https://github.com/PeterGriffinJin/Search-R1 | 多轮 search + EM reward；仓库内 slime 示例 |
| ReSearch | https://github.com/Agent-RL/ReSearch | 多轮搜索 RL 变体 |
| R1-Searcher | https://github.com/RUCAIBox/R1-Searcher | 两阶段 RL 搜索 |
| DeepResearcher | https://github.com/GAIR-NLP/DeepResearcher | 端到端 research agent RL |
| ReAct / Toolformer / WebGPT | 经典论文 | 工具调用与搜索范式基础 |

**仓库内必读**：`slime_0427/slime/examples/search-r1/README_zh.md`

### B. Agent 级 Web 搜索 / 浏览

| 项目 | 要点 |
|------|------|
| WebAgent / WebWalker | 网页导航与信息抽取 |
| BrowseComp | 高难度 browse benchmark |
| WebArena / VisualWebArena | 真实网页交互 |
| Mind2Web | 网页操作数据集 |
| OpenClaw 原生 | `web_search` + `web_fetch` + 浏览器链 |

### C. 知识库 / RAG 检索

| 项目 | 要点 |
|------|------|
| Self-RAG | 检索决策 + 生成 |
| RAG-R1 | RAG 场景 RL |
| tau2-bench banking_knowledge | 仓库内 BM25 检索域 |
| OpenClaw | `memory_search` + workspace RAG |

### D. 浏览器 / GUI Agent

| 项目 | 要点 |
|------|------|
| OSWorld | 桌面操作；参考 `OpenClaw-RL/gui-rl/` |
| AgentTrek | web 轨迹合成 |
| Claw-Eval mock_services | Playwright 集成参考 |

### E. 数据合成与蒸馏

| 参考 | 路径 |
|------|------|
| BFCL 多轮合成 | `simulator_tool_sever_bfcl_revise_fix/pipeline.py` |
| Travel DPO 合成 | `travel_synth/` |
| 强模型 rollout → SFT/DPO | 通用范式 |

---

## 2. 对比表（模板，调研时填充）

| 方法 | web | KB | browser | Reward | 数据 | 模型规模 | 开源 | 与 OpenClaw 集成难度 |
|------|-----|----|---------|--------|------|----------|------|----------------------|
| Search-R1 | ○ | — | — | EM | NQ/HotpotQA | 3B+ | 是 | 中（需改 tool schema） |
| ClawGym GRPO | △ | △ | — | task reward | ClawGym | 9B | 是 | 低（已集成，需开 web） |
| Self-RAG | — | ● | — | 自评 | 自建 | 7B+ | 是 | 高 |
| … | | | | | | | | |

图例：● 直接支持 ○ 间接 △ 需改造 — 不适用

---

## 3. 人机分工

| Agent | 人 |
|-------|-----|
| 批量检索与摘要；填对比表；读仓库代码写集成评估；撰写 report 初稿 | 确认调研深度；审核 report；批准外部依赖 |

---

## 4. 交付物

| 文件 | 说明 |
|------|------|
| `reports/search_landscape_report.md` | 方法对比 + 3–5 条 shortlist + 集成难度 |
| 更新 `03_risks_and_open_questions.md` | 关闭/新增 D1 等决策项 |

### Shortlist 输出格式（示例）

1. **路线 A 候选**：SFT（agent 轨迹）+ ClawGym/slime GRPO — 集成难度：**低**
2. **路线 B 候选**：Search-R1 QA RL + schema 迁移 — 集成难度：**中**
3. …

---

## 5. 完成标准（Definition of Done）

- [ ] 五个方向（A–E）均有至少 3 个代表工作摘要  
- [ ] 对比表 ≥10 行  
- [ ] shortlist 3–5 条，每条有集成难度与风险  
- [ ] 人工评审会议完成，D1 有结论或明确延期  

---

## 6. 状态

| 项 | 状态 |
|----|------|
| 计划文档 | ✅ 已落地 |
| Landscape Report | ✅ v0.1 初稿（[reports/search_landscape_report.md](../reports/search_landscape_report.md)） |
| 人工评审 | ⬜ 待 P1-H02 / P1-H04 |

**下一步**：决策者评审 report → P1-H01～H04 sign-off → 进入阶段 2。
