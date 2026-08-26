# 阶段 3 — 方法决策与冒烟测试

**周期**：~1–2 周  
**依赖**：阶段 1 report、阶段 2 baseline  
**目标**：选定 1–2 条训练路线，小规模验证可行性。

---

## 1. 候选路线

### 路线 A：SFT 冷启动 + RL 微调（与现有栈最一致）

1. 强模型在 OpenClaw 沙箱 rollout 搜索任务 → SFT  
2. slime/ClawGym GRPO 搜索专项（`generate_with_openclaw_search.py` 或扩展 ClawGym）  

| 优点 | 缺点 |
|------|------|
| 与 Ornith/ClawGym 一致 | web 并行超时需工程解决 |
| 评测工具与训练一致 | 数据合成成本高 |

### 路线 B：Search-R1 式 QA RL + Agent SFT 迁移

1. HotpotQA/NQ 上 search RL（`generate_with_search.py`）  
2. SFT 迁移到 OpenClaw schema  

| 优点 | 缺点 |
|------|------|
| RL 信号清晰 | 域迁移 gap |
| 有现成 slime 示例 | 需 Qwen3.5 template 适配 |

### 路线 C：纯 SFT/DPO

1. Claw-Eval/QCB 轨迹蒸馏  
2. DPO 正负搜索策略（`travel_synth` 模式）  

| 优点 | 缺点 |
|------|------|
| 实现快、成本低 | 上限可能低于 RL |

### 路线 D：Browser 专项（可与 A/B 并行）

1. gui-rl / WebArena 轨迹  
2. 独立 SFT，后期与 search RL 混合  

---

## 2. 冒烟测试矩阵

| 实验 ID | 规模 | 验证点 | 预估算力 |
|---------|------|--------|----------|
| SM-SFT-100 | 100 条轨迹 | chat template + tool call 格式 | 1–2 GPU·day |
| SM-R1-50 | 50 step GRPO | slime search RL 链路 | 2–4 GPU·day |
| SM-CG-WEB-10 | 10 ClawGym 任务 | 启用 web 后并行稳定性 | 1 GPU·day |
| SM-BRW-5 | 5 browser 任务 | 浏览器 tool schema | 1 GPU·day |

---

## 3. 对比维度

| 维度 | 权重建议 |
|------|----------|
| L2 搜索子集提升 | 高 |
| 工程复杂度 | 中 |
| GPU·day / API 成本 | 中 |
| 与主线 Ornith 兼容 | 高 |

---

## 4. 人机分工

| Agent | 人 |
|-------|-----|
| POC 脚本；跑冒烟；对比报告 | **选定主路线**；通过标准；全量训练预算 |

---

## 5. 交付物

- [ ] `reports/method_decision_memo.md`  
- [ ] `reports/smoke_test_results.md`  
- [ ] decision_log：D2、D8  

---

## 6. 冒烟通过标准（草案，人改）

| 实验 | 通过条件（示例） |
|------|------------------|
| SM-SFT-100 | ≥95% 轨迹格式合法 |
| SM-R1-50 | reward 曲线无崩溃；EM > 随机 baseline |
| SM-CG-WEB-10 | ≥8/10 任务在超时内完成；无级联失败 |
| 综合 | L2 子集 Pass@1 相对 baseline **+5%**（可调） |

---

## 7. 状态

| 项 | 状态 |
|----|------|
| 路线文档 | ✅ |
| 冒烟 POC | ⬜ |
| 决策 memo | ⬜ |
