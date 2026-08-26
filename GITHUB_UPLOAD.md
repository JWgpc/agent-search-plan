# 上传到 GitHub

本地已在 `docs/agent_search/` 初始化 git 并完成首次提交（仅计划文档，不含 `/dev/gpc_code` 其他代码）。

## 前置条件

1. 安装 [GitHub CLI](https://cli.github.com/)（本机已有 `gh`）
2. 登录 GitHub：

```bash
gh auth login
```

按提示选择 GitHub.com → HTTPS → 浏览器登录。

## 方式 A：创建新仓库并推送（推荐）

在终端执行（将 `YOUR_ORG` 和仓库名按需修改）：

```bash
cd /dev/gpc_code/docs/agent_search

# 创建 GitHub 仓库（public 或 private）
gh repo create YOUR_ORG/agent-search-plan --public --source=. --remote=origin --push
```

若只想创建空仓库再手动推送：

```bash
cd /dev/gpc_code/docs/agent_search
gh repo create YOUR_ORG/agent-search-plan --public
git remote add origin https://github.com/YOUR_ORG/agent-search-plan.git
git push -u origin main
```

## 方式 B：推送到已有仓库

```bash
cd /dev/gpc_code/docs/agent_search
git remote add origin https://github.com/YOUR_ORG/YOUR_REPO.git
git push -u origin main
```

## 修改提交作者（可选）

首次提交使用了占位作者。推送前可 amend（**仅当尚未 push**）：

```bash
git commit --amend --author="Your Name <you@example.com>" --no-edit
```

## 后续更新

```bash
cd /dev/gpc_code/docs/agent_search
git add -A
git commit -m "Update plan: ..."
git push
```

## 当前状态

| 项 | 状态 |
|----|------|
| 本地 git 仓库 | `/dev/gpc_code/docs/agent_search/.git` |
| 分支 | `main` |
| 首次提交 | `a059721` — 18 个计划文档 |
| GitHub 远程 | **未配置**（需 `gh auth login` 后执行上方命令） |
