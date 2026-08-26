# 阶段 2 — Benchmark 设计与 Baseline

**周期**：~2 周（与阶段 4 部分并行）  
**目标**：建立分层评测体系，跑通 baseline，形成可追踪指标。

---

## 1. Benchmark 分层

详见 [appendix_benchmark_inventory.md](../appendix_benchmark_inventory.md)。

| 优先级 | 套件 | 现状 |
|--------|------|------|
| P0 | Claw-Eval web/KB 子集 | 有，需 curated list |
| P0 | QCB Research + Memory | 有 |
| P1 | HotpotQA/NQ subset | Search-R1 模板 |
| P1 | BrowseComp / SimpleQA | 无 harness |
| P2 | WebArena / GAIA | 后期 |

---

## 2. 目录结构（规划）

```
search_eval/
  README.md
  configs/
    benchmark_suite.yaml
    task_lists/
      l2_web_core.txt
      l2_kb_core.txt
      qcb_research.txt
  runners/
    run_claw_eval_subset.py
    run_qcb_search.py
    run_search_r1_eval.py
    run_browsecomp.py          # 占位
  scripts/
    export_task_lists.py
    aggregate_scores.py
  baselines/
    {model_name}/
      summary.json
```

---

## 3. 指标约定（待 D3 确认）

| 类型 | 默认建议 | 备选 |
|------|----------|------|
| Agent 任务 | Pass@1（开发迭代快） | Pass^3（与 Claw-Eval 官方一致） |
| QA | EM | F1 |
| 分项 | web / kb / browser 独立汇报 | 加权总分 |

---

## 4. Baseline 流程

1. **人**：选定 checkpoint（D4）、配置 API key  
2. **Agent**：编写 runner，对接 `model/model_deploy/sglang_deploy_3_5.sh`  
3. 跑 `l2_web_core` + `l2_kb_core` + `l2_qcb_research` + `l1_qa_smoke`  
4. 输出 `baselines/{model}/summary.json` 与 markdown 报告  

---

## 5. 人机分工

| Agent | 人 |
|-------|-----|
| task 清单导出；runner/聚合脚本；baseline 报告草稿 | 主指标；baseline 模型；API 成本；审核 infra 误判 |

---

## 6. 交付物

- [ ] `search_eval/` 目录与 README  
- [ ] `benchmark_suite.yaml` + task_lists  
- [ ] 至少 1 个模型的 baseline 分数表  
- [ ] `reports/baseline_report.md`  

---

## 7. 完成标准

- [ ] 一条命令可跑 v0.1 最小套件（或文档说明前置条件）  
- [ ] 分项得分可写入 JSON 并 diff 对比  
- [ ] D3、D4 已记录于 decision_log  

---

## 8. 状态

| 项 | 状态 |
|----|------|
| task 清单（附录） | ✅ 扫描初稿 |
| search_eval 代码 | ⬜ 未开始 |
| baseline 跑通 | ⬜ 未开始 |
