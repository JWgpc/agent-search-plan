# 阶段 2 — Benchmark 设计与 Baseline

**周期**：~2 周（与阶段 4 部分并行）  
**目标**：建立分层评测体系，跑通 baseline，形成可追踪指标。

**v0.1 选型（2026-08-28）**：见 [reports/search_benchmark_decision.md](../reports/search_benchmark_decision.md)

| 套件 | Benchmark | 题量 |
|------|-----------|------|
| `bcp_closed` | BrowseComp-Plus | 830 |
| `claw_web_search` | Claw-Eval 搜索题 | 65 |
| `tau3_banking` | τ³-Banking | 97 |

---

## 1. Benchmark 分层（v0.1 已定 vs 备选）

| 优先级 | 套件 | 状态 |
|--------|------|------|
| **P0** | BrowseComp-Plus（闭集 deep search） | ✅ v0.1 主套件 |
| **P0** | Claw-Eval web 搜索 65 题 | ✅ v0.1 主套件 |
| **P0** | τ³-Banking（`banking_knowledge`） | ✅ v0.1 主套件 |
| P1 | HotpotQA/NQ subset | 备选 · GRPO smoke |
| P1 | QCB Research | 备选 · 未入 v0.1 |
| P2 | LiveBrowseComp / GAIA 全量 | 后期 |

---

## 2. 目录结构

```
search_eval/                          # 已建配置；runner 待建
  README.md
  configs/
    benchmark_suite.yaml              # ✅
    task_lists/
      claw_eval_web_search.txt        # ✅ 65 题
  runners/                            # ⬜
  baselines/{model}/summary.json      # ⬜
```

代码路径：

- Claw-Eval：`claw_eval_new/claw-eval/`
- τ³-Banking：`tau2-bench/`（`--domain banking_knowledge`）
- BCP：OpenResearcher / Tevatron + HF 数据

---

## 3. 指标约定（待 D3 确认）

| 套件 | 默认建议 | 备选 |
|------|----------|------|
| `claw_web_search` | Pass@1（迭代） | Pass^3（官方） |
| `bcp_closed` | 准确率 / EM | — |
| `tau3_banking` | Pass@1 | Pass^k（leaderboard） |

分项独立汇报，v0.1 **不做加权总分**。

---

## 4. Baseline 流程

1. **人**：选定 checkpoint（D4）；Claw 侧批 `SERP_DEV_KEY`  
2. **Agent**：对接 `model/model_deploy/sglang_deploy_3_5.sh`  
3. 推荐顺序：**τ³-Banking bm25**（免搜索 Key）→ **BCP 100 题 smoke** → **Claw web 子集**  
4. 输出 `search_eval/baselines/{model}/summary.json` + `reports/baseline_report.md`

---

## 5. 人机分工

| Agent | 人 |
|-------|-----|
| runner / 聚合脚本；baseline 报告草稿 | D3/D4；SERP 密钥；审核 infra 误判 |

---

## 6. 交付物

- [x] 选型文档 `reports/search_benchmark_decision.md`  
- [x] `search_eval/` 配置 + Claw task list  
- [ ] runner / 聚合脚本  
- [ ] 至少 1 个模型 baseline 分数表  
- [ ] `reports/baseline_report.md`  

---

## 7. 完成标准

- [ ] 三套件各有一条 smoke 命令或文档化前置条件  
- [ ] 分项得分可写入 JSON 并 diff  
- [ ] D3、D4 写入 decision_log  

---

## 8. 状态

| 项 | 状态 |
|----|------|
| v0.1 三套件决策 | ✅ 2026-08-28 |
| task 清单（Claw 65） | ✅ |
| search_eval 配置 | ✅ |
| baseline 跑通 | ⬜ |
