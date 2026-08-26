# 阶段 4 — 数据准备与质量核验

**周期**：~3–4 周（与阶段 2 并行）  
**目标**：构建 web_search、memory_search、browser 三类工具的多轮轨迹训练集。

---

## 1. 数据来源

| 来源 | 类型 | 用途 | 参考 |
|------|------|------|------|
| Claw-Eval / QCB | 真实 agent 任务 | SFT query + grader | task yaml |
| 强模型 rollout | 合成轨迹 | SFT/DPO 正样本 | `travel_synth/rollout_9b.py` |
| HotpotQA/NQ/2Wiki | QA 搜索格式 | RL 冷启动 | Search-R1 scripts |
| BFCL 式合成 | 多轮 tool | 扩展搜索域 | `simulator_tool_sever_bfcl_revise_fix/` |
| Web 轨迹 | browse | Browser SFT | AgentTrek / 自建 |
| 失败轨迹 | DPO rejected | 策略对比 | `on_policy_dpo_loop/` |

---

## 2. 数据格式

统一 **OpenClaw tool-call** 格式：

```
user query
  → (assistant tool_call → tool_result)* 
  → assistant final answer
```

参考：`clawGym/ClawGym-Agents/SFT/process_scripts/sft_data_pre_tokenize_toolcall_for_openclaw.py`

### 质量维度

- 搜索 query 是否合理  
- 是否 redundant search  
- memory vs web 选择是否正确  
- 最终答案是否可被 grader 验证  

### 目标规模（v1 建议）

| 集合 | 规模 |
|------|------|
| SFT | 2k–5k 条 |
| RL 任务 | 500–1k |
| DPO pairs | ~1k |

---

## 3. ClawGym web 排除 — 工程方案

**原因**：大规模并行时网络工具导致级联超时（见 DATASET_README）。

| 措施 | 说明 |
|------|------|
| 独立子集 | 搜索 RL 与 ClawGym 2000 分池 |
| mock SERP | `claw_eval_new/claw-eval/mock_services/web_real/` |
| 限并发 + 超时 + 缓存 | 相同 query 复用 |
| 本地 retriever | KB 类任务替代部分 web_search |

---

## 4. 目录规划

```
data/
  search_sft_v1/
    manifest.json
    trajectories/*.jsonl
  search_rl_v1/
    tasks/              # ClawGym 式 task 目录
  search_dpo_v1/
    pairs.jsonl
docs/agent_search/reports/
  data_quality_report_v1.md
  spot_check_log.md
```

---

## 5. 人机分工

| Agent | 人 |
|-------|-----|
| rollout；转换；自动质检；分布报告 | rubric；5–10% 抽检；合规；SFT/RL 配比；API 费用 |

---

## 6. 交付物

- [ ] `data/search_sft_v1/`、`data/search_rl_v1/`  
- [ ] `reports/data_quality_report_v1.md`  
- [ ] `reports/spot_check_log.md`  

---

## 7. 完成标准

- [ ] manifest 含来源、轮数、工具分布统计  
- [ ] 自动质检通过率 ≥ 设定阈值  
- [ ] 人工抽检记录 ≥ 5% 样本  

---

## 8. 状态

| 项 | 状态 |
|----|------|
| 格式规范 | ✅ 文档 |
| 数据生成 | ⬜ |
