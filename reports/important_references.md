# 重要参考文献登记

> Agent Search 能力提升项目 · 决策者精读与复现风险跟踪  
> **最后更新**：2026-08-27

本表记录 **对训练路线/复现有直接影响的论文**；「决策者已精读」表示决策者已与 Agent 完成机制讨论，可作为阶段 3 POC 设计依据。**未解决疑问**须在复现前澄清或做 ablation。

---

## 登记表

| 论文 | arXiv | 优先级 | 决策者精读 | 项目专篇 | 复现意向 |
|------|-------|--------|------------|----------|----------|
| **TRACE** — Turn-level Reward Assignment via Credit Estimation | [2607.13988](https://arxiv.org/html/2607.13988) | **高** | **已精读**（2026-08-27） | [trace_vs_abseeker_credit.md](./trace_vs_abseeker_credit.md) §2 | **是**（ClawGym GRPO + turn auxiliary POC） |
| ABSeeker — Answer-Backtracked Credit Assignment | [2608.05102](https://arxiv.org/html/2608.05102) | 高 | 已对照读（与 TRACE 合读） | [trace_vs_abseeker_credit.md](./trace_vs_abseeker_credit.md) §3 | 待定（ABC-SFT reweight 优先于全链路） |
| LiveBrowseComp | [2605.28721](https://arxiv.org/abs/2605.28721) | 中 | Agent 调研 | [five_papers_deep_dive.md](./five_papers_deep_dive.md) §1 | 评测参考 |
| OpenSeeker / DeepResearcher 等 | 见 five_papers | 中 | Agent 调研 | [five_papers_deep_dive.md](./five_papers_deep_dive.md) | 数据/环境参考 |

---

## TRACE（2607.13988）— 决策者精读摘要

**为何标为重要参考文献**

- 与 GPC **ClawGym search profile GRPO** 同构：outcome reward + **turn-level credit**，无需 PRM / judge
- 实验用 **Qwen3-Thinking** backbone，与 Ornith/Qwen3.5 思考模型路线相关
- BrowseComp-Plus **7.2→35.6**（4B 纯 RL），是 **credit 分配** 方向的强 baseline

**已确认机制（精读共识）**

1. 轨迹级：GRPO outcome \(A^{\text{out}}\)（最终短答案 EM + format）
2. 轮次级：每个 tool 边界 \(S_k\) 上，冻结 ref 对 **GT 短答案** teacher-force 算 \(\bar{\ell}_k\) → log-ratio \(V_k\) → TD \(\delta_k\) → 与 outcome 混合（\(\alpha_{\text{turn}}=0.2\)）
3. **不是**对标准搜索轨迹做逐步监督；**是**「相对上一步 prefix，写 GT 是否变容易」

**Turn reward 未决疑问（复现前必须处理）**

| ID | 疑问 | 来源 | 对 GPC 的影响 | 建议 |
|----|------|------|---------------|------|
| **TRACE-Q1** | **`final-answer opener` 未定义**：§2.1 称 scoring 时在 \(S_k\) 后加 opener 再算 GT logprob，但正文 **未给出具体 token 字符串**；Appendix A.3 无完整 prompt；实现指向 Search-R1 launch script（**未公开**） | 正文 + [Pith 外评 Minor #4](https://pith.science/paper/2607.13988) | 复现时 scoring 与 rollout **格式不一致** → \(\bar{\ell}_k\) 无意义 | POC 前 **对齐 ClawGym/Qwen3 最终 `<answer>` / thinking 模板** 并文档化；做 opener ablation |
| **TRACE-Q2** | **思考模型 final thinking 缺失**：Rollout 用 Qwen3-Thinking（每轮 + 最终交卷前大段 thinking）；scoring 侧论文 **未说明** 是否在 opener 与 GT 之间插入 `` 或等价标签 | 决策者精读讨论；Pith Major #1（reasoning 在 prefix 内可刷分） | 若 scoring 为 `S_k + opener + GT` 而 inference 为 `S_k + think + opener + GT`，则 **条件分布 OOD**，turn credit 噪声大 | 至少两路对照：**(A)** 论文式 opener+GT；**(B)** 固定空 thinking 壳 + opener + GT；对比 Claw-Eval 子集 turn credit 稳定性 |
| **TRACE-Q3** | **Private reasoning 未 mask**：Pith 指出 ref scorer 的 prefix **含 policy 自身 CoT**，模型可在 reasoning 里写 GT 抬高 \(V_k\) 而无 tool 证据 | Pith Referee Major #1 | reward hacking；与 LiveBrowseComp「非真搜索」风险叠加 | 复现时记录「\(\delta_k\) 跃升是否伴随 tool obs 变化」；可选 mask 中间 reasoning 做 sensitivity |

**当前结论（决策者 + Agent，2026-08-27）**

- TRACE **值得 POC**，但 **不能按「S_k 后直接拼 golden_answer」字面实现**
- 阶段 3 若做 TRACE auxiliary，门禁增加：**scoring 序列定义文档** + **opener/thinking ablation 至少 1 组**

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-08-27 | 初建；TRACE 标重要参考文献、决策者已精读；登记 TRACE-Q1～Q3 |
