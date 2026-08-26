# 阶段 6 — 效果评估与迭代

**周期**：~2 周 + 持续  
**依赖**：阶段 5 checkpoint  
**目标**：全量 benchmark + 真实场景验证 + sign-off。

---

## 1. 评估维度

| 维度 | 方法 | 通过标准（人定） |
|------|------|------------------|
| 标准 benchmark | 阶段 2 全量套件 | 主指标提升 X% |
| 分能力 | web / kb / browser | 无明显 trade-off |
| 真实场景 | QCB 全量 100 / 内部任务 | 人工满意度 |
| 安全 | T073 等 | 不回归 |
| 效率 | 搜索轮数、延迟、API 成本 | 阈值内 |
| 泛化 | 未见 query 抽样 | 人工评 |

---

## 2. 失败 case 分析 taxonomy

| 类型 | 描述 |
|------|------|
| no_search | 应搜未搜，直接幻觉 |
| over_search |  redundant 或无关搜索 |
| wrong_source | 应用 memory 却 web，或反之 |
| bad_query | 搜索词质量差 |
| parse_fail | 未从结果抽取答案 |
| format | tool call 格式错误 |
| safety | 注入/越权 |

Agent 对失败 transcript 聚类；**人**复核 top-20。

---

## 3. 交付物

| 文件 | 内容 |
|------|------|
| `reports/search_capability_evaluation_report.md` | 全量结果 + 对比 + 结论 |
| `reports/production_checkpoint_recommendation.md` | 推荐 ckpt + 已知限制 |
| v2 roadmap | WebArena 全量、多语言等 |

---

## 4. Sign-off 检查清单

- [ ] 全量 benchmark 跑完且可复现  
- [ ] 相对 baseline 达到 D8 目标（或 documented 未达标原因）  
- [ ] 安全子集无回归  
- [ ] top-20 失败 case 人工分析完成  
- [ ] 是否 merge Ornith 主线有书面决定  

---

## 5. 人机分工

| Agent | 人 |
|-------|-----|
| 全量 run；对比报告；聚类 | sign-off；merge 决策；roadmap |

---

## 6. 状态

| 项 | 状态 |
|----|------|
| 评估框架 | ⬜ 依赖阶段 2 |
| 最终报告 | ⬜ |
