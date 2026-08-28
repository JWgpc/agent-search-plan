# 阶段 4 — 数据准备与质量核验

**周期**：~3–4 周（与阶段 2 并行）  
**目标**：构建 web_search、memory_search、browser 三类工具的多轮轨迹训练集；**RL 搜索数据与环境输入已文档化**。

---

## 0. 阶段 4 专篇（2026-08-28）

| 文档 | 内容 |
|------|------|
| [reports/rl_search_data_landscape.md](../reports/rl_search_data_landscape.md) | RL 搜索 **Q+A / 合成项目** 调研对比表与选型 |
| [reports/openresearcher_env_setup.md](../reports/openresearcher_env_setup.md) | **OpenResearcher** 数据、检索服务、训练接入、Claw 适配（决策者认定高参考） |
| [reports/important_references.md](../reports/important_references.md) | OpenResearcher / TRACE 登记与决策记录 |

**决策者认定（2026-08-28）**：OpenResearcher **参考价值较高** — 闭集 Q+A + 本地检索可支撑 GRPO smoke；Claw 主线仍用 `web_search` + `web_fetch`，`find`/长页截断 **待实测数据后再定**。

---

## 1. 数据来源

| 来源 | 类型 | 用途 | URL / 参考 |
|------|------|------|------------|
| **OpenResearcher-Corpus-Gold-Doc** | 6,102 Q+A + gold_docs | **RL 题源（去重）** | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus-Gold-Doc · [§3](../reports/rl_search_data_landscape.md#3-openresearcher-数据包说明gpc-重点) |
| **OpenResearcher-Dataset** | Q+A + 97K 轨迹 | RL prompt+GT；SFT 轨迹 | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Dataset |
| **OpenResearcher-Corpus + Indexes** | 检索语料 + embedding | 闭集 search/open | [Corpus](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus) · [Indexes](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Indexes) · [env 专篇](../reports/openresearcher_env_setup.md) |
| Claw-Eval / QCB | 真实 agent 任务 | SFT query + grader；**Claw schema RL 主池** | task yaml |
| 强模型 rollout | 合成轨迹 | SFT/DPO 正样本 | `travel_synth/rollout_9b.py` |
| HotpotQA/NQ/2Wiki | QA 搜索格式 | RL 冷启动 smoke | [Search-R1](https://github.com/PeterGriffinJin/Search-R1) · [HF 合集](https://huggingface.co/collections/PeterJinGo/search-r1-67d1a021202731cb065740f5) |
| OpenSeeker-v1-Data | 11.7K 合成 | SFT 备选 | https://huggingface.co/datasets/PolarSeeker/OpenSeeker-v1-Data |
| BFCL 式合成 | 多轮 tool | 扩展搜索域 | `simulator_tool_sever_bfcl_revise_fix/` |
| Web 轨迹 | browse | Browser SFT | AgentTrek / 自建 |
| 失败轨迹 | DPO rejected | 策略对比 | `on_policy_dpo_loop/` |

---

## 2. RL 数据最小单元

GRPO 在线 rollout 所需：

1. **Question**（OpenClaw chat prompt）  
2. **Ground truth answer**（EM / grader）  
3. **搜索服务**（运行时，非静态文件）— 见 [openresearcher_env_setup.md](../reports/openresearcher_env_setup.md) §3  

---

## 3. 数据格式

统一 **OpenClaw tool-call** 格式：

```
user query
  → (assistant tool_call → tool_result)* 
  → assistant final answer
```

参考：`clawGym/ClawGym-Agents/SFT/process_scripts/sft_data_pre_tokenize_toolcall_for_openclaw.py`

Search-R1 式 parquet 字段见 [rl_search_data_landscape.md](../reports/rl_search_data_landscape.md) §4。

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

**RL v1 数据源候选**：OpenResearcher Q+A 子集（闭集 smoke）+ Claw-Eval 可验证 web 子集（开网/mock 主池）。

---

## 4. ClawGym web 排除 — 工程方案

**原因**：大规模并行时网络工具导致级联超时（见 DATASET_README）。

| 措施 | 说明 |
|------|------|
| 独立子集 | 搜索 RL 与 ClawGym 2000 分池 |
| mock SERP | `claw_eval_new/claw-eval/mock_services/web_real/` |
| 限并发 + 超时 + 缓存 | 相同 query 复用 |
| 本地 retriever | OpenResearcher 闭集 **或** KB 类 memory_search |
| OpenResearcher 闭集池 | 无外部 API，适合 RL 内环（与 Claw 开网池 **分开**） |

---

## 5. 目录规划

```
data/
  search_sft_v1/
    manifest.json
    trajectories/*.jsonl
  search_rl_v1/
    tasks/              # ClawGym 式 task 目录
    openresearcher/     # Q+A parquet / manifest（闭集 smoke）
  search_dpo_v1/
    pairs.jsonl
docs/agent_search/reports/
  rl_search_data_landscape.md
  openresearcher_env_setup.md
  data_quality_report_v1.md   # 待建
  spot_check_log.md           # 待建
  web_fetch_length_survey.md  # 待建（最长文档实测）
```

---

## 6. 阶段 4 执行顺序（建议）

| 步 | 动作 | 文档 |
|----|------|------|
| 1 | 下载 OpenResearcher-Dataset 子集 + manifest | env 专篇 §2.1 |
| 2 | Search-R1 NQ/Hotpot smoke parquet | rl_search_data_landscape §2.1 |
| 3 | 本地检索服务 smoke | env 专篇 §3 |
| 4 | 统计 web_fetch / 正文长度 | 待建 web_fetch_length_survey |
| 5 | Claw-Eval web 子集 + rollout | 原有 P4-A01 |
| 6 | 定 RL v1 主数据源 | P4-H04 |

---

## 7. 人机分工

| Agent | 人 |
|-------|-----|
| rollout；转换；自动质检；分布报告；OpenResearcher 下载与 manifest | rubric；5–10% 抽检；合规；SFT/RL 配比；Corpus 存储/GPU 审批 |

---

## 8. 交付物

- [ ] `data/search_sft_v1/`、`data/search_rl_v1/`  
- [ ] `reports/rl_search_data_landscape.md` ✅  
- [ ] `reports/openresearcher_env_setup.md` ✅  
- [ ] `reports/data_quality_report_v1.md`  
- [ ] `reports/spot_check_log.md`  
- [ ] `reports/web_fetch_length_survey.md`（可选，建议做）

---

## 9. 完成标准

- [ ] manifest 含来源、轮数、工具分布统计  
- [ ] 自动质检通过率 ≥ 设定阈值  
- [ ] 人工抽检记录 ≥ 5% 样本  
- [ ] OpenResearcher 或 Search-R1 **至少一条** Q+A → 检索 smoke 通  

---

## 10. 状态

| 项 | 状态 |
|----|------|
| RL 数据/项目调研文档 | ✅ |
| OpenResearcher env 指南 | ✅ |
| 格式规范 | ✅ 文档 |
| 数据生成 | ⬜ |
| 最长文档长度实测 | ⬜ 待讨论 |
