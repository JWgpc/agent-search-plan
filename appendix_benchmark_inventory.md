# 附录 — Benchmark 任务清单

> 2026-08-26 自仓库自动扫描；正式评测前需人工复核 task 是否属于「搜索能力」子集。

## 分层定义

| 层级 | 名称 | 指标 | 用途 |
|------|------|------|------|
| L1 | 开放域 QA | EM / F1 | 检索+答案能力、快速迭代 |
| L1 | 高难度 browse | 准确率 | BrowseComp / SimpleQA（待接入） |
| L2 | Agent Web | Pass@1 或 Pass^3 | 主战场 |
| L2 | Agent KB | Pass@1 或 Pass^3 | memory/RAG |
| L2 | Agent 综合 | Pass@1 或 Pass^3 | QCB 真实 OpenClaw 场景 |
| L3 | Browser | Pass@1 | 网页交互（后期） |
| L3 | Research 长程 | Pass@1 | GAIA / FRAMES（后期） |

## Claw-Eval 扫描结果

| 类别 | 数量（启发式匹配） | 说明 |
|------|-------------------|------|
| web 相关 | **93** | web_search/web_fetch/pinbench/officeqa/research 等 |
| KB 相关 | **55** | kb_search/memory/RAG 等 |
| browser 相关 | **39** | browser/playwright/webpage 等 |

> 任务间有重叠；正式子集需去重并人工标注 `capability: [web, kb, browser]`。

### 核心 KB 任务（必含）

- `T015zh_kb_search`
- `T016_kb_search`

### 核心 Web 安全任务（必含）

- `T073_web_search_injection`

### Web 相关任务样例（前 20）

```
C02zh_personal_finance
C03en_real_estate_finance
C05zh_personal_finance_2
C06zh_clinical_pharmacy
C07zh_financial_valuation
C08zh_personal_finance_3
C09zh_ai_video_creation
C10zh_labor_law
C11zh_container_orchestration
C12zh_ecommerce_operations
C13zh_psychology_statistics
C14zh_cross_border_compliance
C15en_structural_seismic_design
C17en_devops_sop_design
C18en_statistical_analysis_spss
C19en_ab_testing_sample_size
C20zh_mental_health_social_work
C21zh_ecommerce_data_analysis
C22zh_experimental_psychology
C23zh_academic_writing
```

完整列表生成脚本（计划阶段 2 落地）：`search_eval/scripts/export_task_lists.py`

## QwenClawBench 扫描结果

| 类别 | 数量 |
|------|------|
| Research and Information Retrieval | **7** |
| Knowledge and Memory（启发式） | **16** |
| Browser 相关 | **3** |

### Research 任务（7）

1. `task_00055_literature_retrieval_bot_error_diagnosis_and_config_fix`
2. `task_00056_seo_long_tail_keyword_research_report_for_retirement_calculator`
3. `task_00057_competitor_website_change_analysis_targetimpact_cta_shift`
4. `task_00066_svpwm_implementation_for_edge_aligned_pwm_motor_controller`
5. `task_00094_exam_monitor_system_audit_cron_sync_bug_rate_limit_gap_and_site`
6. `task_00099_competitor_pricing_change_analysis_alphaware_solutions`
7. `task_00100_house_robber_algorithm_deep_dive_explanation`

> 注：`task_00100` 等可能偏算法非搜索，需人工标注是否纳入 v1 子集。

### Browser 相关（3）

1. `task_00033_ai_browser_project_git_initialization_and_workspace_setup`
2. `task_00048_baidu_qianfan_api_integration_test_document`
3. `task_00088_personal_assistant_security_policy_assessment`

## 建议 v0.1 最小评测包

| 包 ID | 组成 | 预估任务数 |
|-------|------|------------|
| `l2_web_core` | Claw-Eval web 子集（人工 curated）+ T073 | ~30–65 |
| `l2_kb_core` | T015/T016 + QCB memory 核心 ~10 | ~12 |
| `l2_qcb_research` | QCB Research 7 | 7 |
| `l1_qa_smoke` | HotpotQA/NQ dev 各 100（Search-R1 格式） | 200 |

## 待接入（无现成 harness）

| Benchmark | 优先级 | 备注 |
|-----------|--------|------|
| BrowseComp | P1 | 需 API + 评测脚本 |
| SimpleQA | P1 | 可与 BrowseComp 同批 |
| GAIA subset | P2 | 长程 research |
| WebArena subset | P2 | 浏览器 L3 |
| HotpotQA / NQ 全量 | P1 | Search-R1 模板可复用 |

## 配置文件规划（阶段 2）

```yaml
# search_eval/configs/benchmark_suite.yaml（草案结构）
version: "0.1"
suites:
  l2_web_core:
    source: claw_eval
    task_list: configs/task_lists/l2_web_core.txt
    metric: pass_at_1
    trials: 3  # Pass^3 若人定 D3
  l2_kb_core:
    source: claw_eval
    task_list: configs/task_lists/l2_kb_core.txt
  l2_qcb_research:
    source: qwenclawbench
    task_list: configs/task_lists/qcb_research.txt
  l1_qa_smoke:
    source: search_r1
    datasets: [hotpotqa, nq]
    split: dev
    limit: 100
    metric: em
```
