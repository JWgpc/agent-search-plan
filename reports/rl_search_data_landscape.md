# RL 搜索训练数据与合成项目调研

> Agent Search 能力提升项目 · 阶段 4 数据准备输入  
> 版本：v0.2 | 日期：2026-08-28  
> 关联：[phase4_data.md](../phases/phase4_data.md) · [openresearcher_env_setup.md](./openresearcher_env_setup.md)

---

## 0. 前提：RL「数据」指什么

GRPO / outcome RL **不需要预存完整 rollout 轨迹**，最小单元是：

| 字段 | 用途 |
|------|------|
| `question` / prompt | rollout 起点 |
| `ground_truth` / answer | 结束时 **EM / format reward** |
| **搜索服务**（运行时） | 模型调 tool 时返回 doc/snippet |

完整 trajectory 用于 **SFT**；RL 在线采样。因此下表区分 **「现成 Q+A」**、**「轨迹+ Q+A」**、**「合成管线」**。

---

## 1. 总览对比表（含 URL）

完整明细见 **§8 项目与数据 URL 索引**。

| 项目 | 论文 | 代码仓库 | 主要数据 HF | 现成 Q+A | 现成轨迹 |
|------|------|----------|-------------|----------|----------|
| **OpenResearcher** ⭐ | [arxiv:2603.20278](https://arxiv.org/abs/2603.20278) | [TIGER-AI-Lab/OpenResearcher](https://github.com/TIGER-AI-Lab/OpenResearcher) | 见 §3.1 | ✅ **6,102** [Corpus-Gold-Doc](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus-Gold-Doc) | ✅ 97K [Dataset](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Dataset) |
| **TRACE** | [arxiv:2607.13988](https://arxiv.org/html/2607.13988) | 无独立仓（实现指 Search-R1 script，未公开） | ❌ 合成 QA 未 release | ❌ | ❌ |
| **Search-R1** | [arxiv:2503.09516](https://arxiv.org/abs/2503.09516) | [PeterGriffinJin/Search-R1](https://github.com/PeterGriffinJin/Search-R1) | [HF 合集](https://huggingface.co/collections/PeterJinGo/search-r1-67d1a021202731cb065740f5) | ✅ NQ/HotpotQA 等 | ❌ |
| **OpenSeeker** | [arxiv:2603.15594](https://arxiv.org/abs/2603.15594) | [PolarSeeker/OpenSeeker](https://github.com/PolarSeeker/OpenSeeker) | [OpenSeeker-v1-Data](https://huggingface.co/datasets/PolarSeeker/OpenSeeker-v1-Data) | ✅ 11.7K | ✅ 含轨迹 |
| **ASearcher** | [ASearcher 论文 PDF](https://github.com/inclusionAI/ASearcher/blob/main/assets/paper.pdf) | [inclusionAI/ASearcher](https://github.com/inclusionAI/ASearcher) | [ASearcher-train-data](https://huggingface.co/datasets/inclusionAI/ASearcher-train-data) | ✅ 35K | 部分 |
| **R1-Searcher** | [arxiv:2503.05592](https://arxiv.org/abs/2503.05592) | [RUCAIBox/R1-Searcher](https://github.com/RUCAIBox/R1-Searcher) | [RAG-RL-Hotpotqa-with-2wiki](https://huggingface.co/datasets/XXsongLALA/RAG-RL-Hotpotqa-with-2wiki) | ✅ | ❌ |
| **DeepDive** | [THUDM/DeepDive README](https://github.com/THUDM/DeepDive) | [THUDM/DeepDive](https://github.com/THUDM/DeepDive) | [zai-org/DeepDive](https://huggingface.co/datasets/zai-org/DeepDive) | ✅ RL **2234** | ✅ SFT 轨迹 |
| **Tree-GRPO** | [arxiv:2509.21240](https://arxiv.org/abs/2509.21240) | [AMAP-ML/Tree-GRPO](https://github.com/AMAP-ML/Tree-GRPO) | 沿用 Search-R1 | 沿用 Search-R1 | ❌ |
| **ABSeeker** | [arxiv:2608.05102](https://arxiv.org/html/2608.05102) | [PolarSeeker/ABSeeker](https://github.com/PolarSeeker/ABSeeker) | [ABSeeker-4B-RL](https://huggingface.co/PolarSeeker/ABSeeker-4B-RL)（模型） | OpenSeeker 子集 | ✅ 8.5K 轨迹 |
| **WebSailor / WebDancer** | [WebSailor](https://arxiv.org/abs/2507.02592) · [WebDancer](https://arxiv.org/abs/2505.22648) | [Alibaba-NLP/DeepResearch/WebAgent](https://github.com/Alibaba-NLP/DeepResearch/tree/main/WebAgent) | [sailorfog-QA.jsonl](https://github.com/Alibaba-NLP/DeepResearch/blob/main/WebAgent/WebSailor/dataset/sailorfog-QA.jsonl) | 样例 | 部分 |
| **GrepSeek** | [alireza7/GrepSeek 项目页](https://github.com/alirezasalemi7/grepseek) | [alirezasalemi7/grepseek](https://github.com/alirezasalemi7/grepseek) | [GrepSeek-ColdStart-SFT-10k](https://huggingface.co/datasets/alireza7/GrepSeek-ColdStart-SFT-10k) | SFT 10K | ❌ |
| **AgentSim** | [arxiv:2604.26653](https://arxiv.org/abs/2604.26653) | [searchsim-org/sigir26-agentsim](https://github.com/searchsim-org/sigir26-agentsim) | [searchsim/agentsim-atc](https://huggingface.co/datasets/searchsim/agentsim-atc) | supervised pairs | ✅ traces |

**其他维度**：合成管线见各项目代码仓库；OpenResearcher 默认 **离线 FAISS** + search/open/find，与 Claw 距离 **高**（闭集 env 可参考）；OpenSeeker/ABSeeker 与 Claw 距离 **低**（真 web、schema 不同）。

---

## 2. 按用途选型

### 2.1 最快 GRPO 链路 smoke（工程验证）

**Search-R1 + slime 示例**（`slime_0427/slime/examples/search-r1/`）

- 数据：NQ + HotpotQA → `train.parquet`
- 搜索：local wiki 索引 **或** Serper
- 局限：轨迹短（示例 `max_turns=2`），**不能对标 TRACE 数字**

### 2.2 长程闭集 deep search（对齐 TRACE / BrowseComp-Plus 设定）

**OpenResearcher**（决策者认定参考价值较高，见 [important_references.md](./important_references.md)）

- **6,102 题 Q+A（题源表）**：[OpenResearcher-Corpus-Gold-Doc](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus-Gold-Doc)（`query_id` / `query` / `answer` / `gold_docs`）
- **97K 轨迹（含 Q+A）**：[OpenResearcher-Dataset](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Dataset)（6102 题 × 16 seed；RL 抽 `question`/`answer`）
- **检索语料+索引**：[OpenResearcher-Corpus](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus) + [OpenResearcher-Indexes](https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Indexes)（gold 已 merge 进 corpus）
- **代码**：[TIGER-AI-Lab/OpenResearcher](https://github.com/TIGER-AI-Lab/OpenResearcher) — `search` / `open` / `find` + 本地检索（详见 [openresearcher_env_setup.md](./openresearcher_env_setup.md)）
- 缺口：TRACE 专用合成 QA **未公开**；RL 训练 loop 需自接 slime/ClawGym

### 2.3 长程开网 deep search SFT + 可选 RL

**OpenSeeker-v1-Data**（11.7K，含轨迹）

- 适合 SFT 冷启动；RL 需 Serper 类 API
- ABSeeker 的 8.5K 轨迹与 clue 脚本可借鉴 **step credit**，非首选 env

### 2.4 小规模合成 QA + RL smoke

**DeepDive**（RL 2234 题 + `qa_synthetic` 管线）

- 规模小、KG 驱动，适合算法验证，非 BrowseComp 分布

---

## 3. OpenResearcher 数据包说明（GPC 重点）

### 3.1 配套关系

```text
OpenResearcher-Corpus-Gold-Doc (6,102 Q+A + gold_docs)
        │
        ├──► gold 文档已 merge ──► OpenResearcher-Corpus (~15M docs, 含干扰)
        │                              │
        │                              └──► OpenResearcher-Indexes (Qwen3-Embedding-8B pkl)
        │
        └──► 多 seed 扩轨迹 ──► OpenResearcher-Dataset (97,630 行 = 6102 × 16 seed)
```

- **6102 题** 与 corpus **配套**：gold hit ~29.54%（非一搜即中）
- **不是** TRACE Appendix A.4 那套 multi-doc ID 合成题（TRACE 合成 QA **未 release**）

### 3.2 HuggingFace 数据集

| 数据集 | URL | 内容 | RL 用法 | 规模 |
|--------|-----|------|---------|------|
| **Corpus-Gold-Doc** | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus-Gold-Doc | `query_id`, `query`, `answer`, `gold_docs` | **题源 Q+A**；gold 文档 ID | **6,102** 行 |
| **Dataset** | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Dataset | `qid`, `question`, `answer`, `messages` | RL 用 Q+A；SFT 用 messages | **97,630** 行 |
| **Corpus** | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus | `docid`, `text`, `url` | 离线检索语料 | ~15M docs, ~30GB |
| **Indexes** | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Indexes | embedding pkl 分片 | 与 Corpus 配 FAISS | 需 GPU 检索 |

### 3.3 代码与评测语料（非训练主语料）

| 资源 | URL | 用途 |
|------|-----|------|
| 主仓库 | https://github.com/TIGER-AI-Lab/OpenResearcher | 检索服务、`browser.py`、评测脚本 |
| BrowseComp-Plus corpus（评测） | https://huggingface.co/datasets/Tevatron/browsecomp-plus-corpus | `setup.sh` / 默认 search 脚本 **默认绑定** |
| BrowseComp-Plus indexes（评测） | https://huggingface.co/datasets/Tevatron/browsecomp-plus-indexes | BM25 / dense 评测索引 |
| Embedding 模型 | https://huggingface.co/Qwen/Qwen3-Embedding-8B | dense 检索 encoder |
| Tevatron（依赖） | https://github.com/texttron/tevatron | OpenResearcher 检索后端依赖 |

---

## 4. Search-R1 数据格式（Claw 迁移参考）

每条样本（转 parquet 前）：

```python
{
    "data_source": "...",
    "prompt": [{"role": "user", "content": question}],
    "ability": "fact-reasoning",
    "reward_model": {"style": "rule", "ground_truth": solution},
    "extra_info": {"split": split, "index": idx},
}
```

ClawGym GRPO 需改为 **OpenClaw tool-call** 轨迹格式，见 `sft_data_pre_tokenize_toolcall_for_openclaw.py`。

---

## 5. 尚未决、待看数据再定

| 项 | 说明 | 状态 |
|----|------|------|
| 最长文档 / fetch 截断 | Claw `web_fetch` 仅 `maxChars` 头截断；是否需页内 find | **待实测 Claw-Eval / OpenResearcher 文档长度分布** |
| OpenResearcher vs BrowseComp-Plus 语料 | GitHub 默认 search 脚本绑 BCP 评测库，训练 corpus 需单独配置 | 见 env 专篇 §3 |
| TRACE 合成 QA | 无 release；是否自跑 A.4 | 阶段 4 可选，非阻塞 smoke |
| RL 数据主来源 | OpenResearcher Q+A vs Search-R1 vs Claw-Eval 子集 | 阶段 3/4 决策 |

---

## 6. GPC 阶段 4 建议顺序

| 顺序 | 动作 | 产出 |
|------|------|------|
| 1 | 下载 OpenResearcher-Dataset 子集 + 统计 Q+A 字段 | `data/manifests/openresearcher_sample.json` |
| 2 | Search-R1 NQ/Hotpot 子集转 OpenClaw 格式（并行 smoke） | `data/search_rl_v1/search_r1_smoke/` |
| 3 | 按 [openresearcher_env_setup.md](./openresearcher_env_setup.md) 起本地检索 smoke | 检索 API 可达 |
| 4 | 统计 fetch 长度（Claw + 若用 OpenResearcher open） | 写入 `reports/web_fetch_length_survey.md`（待建） |
| 5 | 定 RL v1 规模（500–1k）与主数据源 | P4-H04 |

---

## 7. 参考文献

- Li et al., OpenResearcher, [arXiv:2603.20278](https://arxiv.org/abs/2603.20278), 2026.  
- Jin et al., Search-R1, [arXiv:2503.09516](https://arxiv.org/abs/2503.09516), 2025.  
- TRACE, [arXiv:2607.13988](https://arxiv.org/html/2607.13988), 2026.  
- Du et al., OpenSeeker, [arXiv:2603.15594](https://arxiv.org/abs/2603.15594), 2026.

---

## 8. 项目与数据 URL 索引

### 8.1 OpenResearcher ⭐

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | OpenResearcher | https://arxiv.org/abs/2603.20278 |
| 代码 | TIGER-AI-Lab/OpenResearcher | https://github.com/TIGER-AI-Lab/OpenResearcher |
| 数据 | Corpus-Gold-Doc（6,102 Q+A） | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus-Gold-Doc |
| 数据 | Dataset（97K 轨迹） | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Dataset |
| 数据 | Corpus（检索语料） | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Corpus |
| 数据 | Indexes（embedding） | https://huggingface.co/datasets/OpenResearcher/OpenResearcher-Indexes |
| 评测语料 | BrowseComp-Plus corpus | https://huggingface.co/datasets/Tevatron/browsecomp-plus-corpus |
| 评测索引 | BrowseComp-Plus indexes | https://huggingface.co/datasets/Tevatron/browsecomp-plus-indexes |
| 模型 | Qwen3-Embedding-8B | https://huggingface.co/Qwen/Qwen3-Embedding-8B |
| 依赖 | tevatron | https://github.com/texttron/tevatron |

### 8.2 TRACE

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | TRACE | https://arxiv.org/html/2607.13988 |
| 训练数据 | 合成 QA（Appendix A.4） | ❌ **未 release** |
| 语料 | 同 OpenResearcher-Corpus | 见 §8.1 |

### 8.3 Search-R1

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | Search-R1 | https://arxiv.org/abs/2503.09516 |
| 代码 | PeterGriffinJin/Search-R1 | https://github.com/PeterGriffinJin/Search-R1 |
| 数据 | HF 合集（NQ/HotpotQA 等） | https://huggingface.co/collections/PeterJinGo/search-r1-67d1a021202731cb065740f5 |
| GPC 示例 | slime search-r1 | `slime_0427/slime/examples/search-r1/`（仓库内路径） |

### 8.4 OpenSeeker

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | OpenSeeker | https://arxiv.org/abs/2603.15594 |
| 代码 | PolarSeeker/OpenSeeker | https://github.com/PolarSeeker/OpenSeeker |
| 数据 | OpenSeeker-v1-Data | https://huggingface.co/datasets/PolarSeeker/OpenSeeker-v1-Data |

### 8.5 ASearcher

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | ASearcher（PDF） | https://github.com/inclusionAI/ASearcher/blob/main/assets/paper.pdf |
| 代码 | inclusionAI/ASearcher | https://github.com/inclusionAI/ASearcher |
| 数据 | ASearcher-train-data | https://huggingface.co/datasets/inclusionAI/ASearcher-train-data |

### 8.6 R1-Searcher

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | R1-Searcher | https://arxiv.org/abs/2503.05592 |
| 代码 | RUCAIBox/R1-Searcher | https://github.com/RUCAIBox/R1-Searcher |
| 数据 | RAG-RL-Hotpotqa-with-2wiki | https://huggingface.co/datasets/XXsongLALA/RAG-RL-Hotpotqa-with-2wiki |

### 8.7 DeepDive

| 类型 | 名称 | URL |
|------|------|-----|
| 代码 | THUDM/DeepDive | https://github.com/THUDM/DeepDive |
| 数据 | zai-org/DeepDive | https://huggingface.co/datasets/zai-org/DeepDive |

### 8.8 Tree-GRPO

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | Tree-GRPO | https://arxiv.org/abs/2509.21240 |
| 代码 | AMAP-ML/Tree-GRPO | https://github.com/AMAP-ML/Tree-GRPO |

### 8.9 ABSeeker

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | ABSeeker | https://arxiv.org/html/2608.05102 |
| 代码 | PolarSeeker/ABSeeker | https://github.com/PolarSeeker/ABSeeker |
| 模型 | ABSeeker-4B-RL | https://huggingface.co/PolarSeeker/ABSeeker-4B-RL |
| 数据 | 轨迹来自 OpenSeeker 子集 | 见 §8.4 |

### 8.10 WebSailor / WebDancer

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | WebSailor | https://arxiv.org/abs/2507.02592 |
| 论文 | WebDancer | https://arxiv.org/abs/2505.22648 |
| 代码 | Alibaba-NLP/DeepResearch/WebAgent | https://github.com/Alibaba-NLP/DeepResearch/tree/main/WebAgent |
| 数据 | sailorfog-QA.jsonl | https://github.com/Alibaba-NLP/DeepResearch/blob/main/WebAgent/WebSailor/dataset/sailorfog-QA.jsonl |

### 8.11 GrepSeek

| 类型 | 名称 | URL |
|------|------|-----|
| 代码 | alirezasalemi7/grepseek | https://github.com/alirezasalemi7/grepseek |
| 数据 | GrepSeek-ColdStart-SFT-10k | https://huggingface.co/datasets/alireza7/GrepSeek-ColdStart-SFT-10k |

### 8.12 AgentSim

| 类型 | 名称 | URL |
|------|------|-----|
| 论文 | AgentSim | https://arxiv.org/abs/2604.26653 |
| 代码 | searchsim-org/sigir26-agentsim | https://github.com/searchsim-org/sigir26-agentsim |
| 数据 | agentsim-atc | https://huggingface.co/datasets/searchsim/agentsim-atc |

---

## 变更记录

| 日期 | 变更 |
|------|------|
| 2026-08-28 | 初稿：RL 搜索数据/合成项目调研；OpenResearcher 为重点；Claw 适配待决项 |
| 2026-08-28 | v0.2：§1/§3/§8 补全项目与数据 URL；6102 题明确为 Corpus-Gold-Doc |
