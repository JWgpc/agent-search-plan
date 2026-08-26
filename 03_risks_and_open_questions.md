# 03 — 风险与待决策项

## 风险登记

| ID | 风险 | 影响 | 缓解措施 | 负责人 |
|----|------|------|----------|--------|
| R1 | Web API 不稳定 / 成本高 | RL 训练中断、预算超支 | mock SERP + 缓存 + 限并发；Claw-Eval mock 复用 | 工程 |
| R2 | SFT→RL 工具能力回退 | 搜索策略退化 | 搜索专项 RL 池；独立 profile | 训练 |
| R3 | QA RL 域迁移 gap | agent 搜索提升有限 | 优先 agent 轨迹 SFT；评测以 L2 为主 | 算法 |
| R4 | Browser 数据稀缺 | 进度滞后 | v1 先 web+KB，browser 后补 | 产品/人 |
| R5 | 评测与训练工具不一致 | 虚假提升 | 统一 OpenClaw tool schema | 工程 |
| R6 | ClawGym 并行超时 | 无法大规模 search RL | 独立子集、低并发、mock | 工程 |

## 待决策项（Open Questions）

以下事项需在对应阶段由**人**拍板；Agent 可整理选项与利弊。

| ID | 问题 | 建议决策窗口 | 选项 | 状态 |
|----|------|--------------|------|------|
| D1 | 三类能力是否并行还是分阶段？ | 阶段 1 末 | A 并行 / B 先 web+KB 后 browser | **待定** |
| D2 | 主训练路线？ | 阶段 3 | SFT+RL / RL-only / SFT-only | **待定** |
| D3 | Agent 评测主指标？ | 阶段 2 初 | Pass@1 / Pass^3 | **待定** |
| D4 | Baseline checkpoint？ | 阶段 2 初 | Ornith-9B / Qwen3.5-9B / 其他 | **待定** |
| D5 | 是否接入 BrowseComp / GAIA？ | 阶段 2 | 全量 / subset / 暂不 | **待定** |
| D6 | HotpotQA/NQ 本地 retriever 是否部署？ | 阶段 3 | 本地 FAISS / 仅 API search | **待定** |
| D7 | 搜索 RL 与 ClawGym 2000 是否混训？ | 阶段 5 前 | 独立 / 混合比例 | **待定** |
| D8 | 相对 baseline 提升目标 X%？ | 阶段 3 | 数值 | **待定** |

## 决策记录

正式决策写入 [templates/decision_log.md](./templates/decision_log.md) 副本或下方表格。

| 日期 | ID | 决策 | 决策人 | 备注 |
|------|-----|------|--------|------|
| — | — | （暂无） | — | — |

## 外部依赖审批清单

| 依赖 | 用途 | 估算 | 审批 |
|------|------|------|------|
| SERP_DEV_KEY / Brave | Claw-Eval 真实 web 搜索 | 按调用量 | 未批 |
| Serper (Search-R1 google 后端) | QA RL / eval | 按调用量 | 未批 |
| wiki-18 FAISS 索引 ~132GB | Search-R1 本地检索 | 存储 + GPU | 未批 |
| 强模型 rollout API | SFT 数据合成 | 按 token | 未批 |
| 训练 GPU | GRPO/SFT | GPU·day | 未批 |
