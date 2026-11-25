---
name: dsh-publish
description: 发布本仓库 dsh-plugin 子包到 DSH 作为独立 npm-only 条目，覆盖去 repository、bump、npm publish、等 CDN 同步、提交 DSH、轮询上架全流程。触发词：发布到 DSH、DSH 发布、提交 DSH、dsh publish、上架 DSH。仅在 agent-skills 工作区内使用。
---

# DSH 独立条目发布（dsh-publish）

把本仓库 `dsh-plugin/packages/<skill>/` 下的子包发布到 DSH，并确保它成为**独立的 npm-only 条目**，而不是被归并到根包 `agent-skills-3`。

适用范围：仅 `yumingtao/agent-skills` 仓库。包名、账号、目录结构都硬编码在本技能里，换仓库不适用。

## 核心原理（为什么要去掉 repository）

DSH 的 entry id 派生规则：
- 包声明了 `repository` → id 取**仓库名**（同一个 GitHub 仓库的所有子包会被归并成一条）
- 包**没有** `repository` → id 取 **npm 包名**（每个包独立一条）

本仓库是 monorepo，7 个子包的 `repository` 都指向 `github.com/yumingtao/agent-skills`，所以 DSH 把它们全归并到根条目 `agent-skills-3`，子包没有独立 artifact 页。**修复方法：从子包的 `package.json` 删除 `repository` 字段**（保留 `homepage` 和 `bugs`，源码链接仍可见）。

> 关键：DSH 服务端提交时会**重新从 npm registry 拉取 metadata**，用包**实际发布的** `repository` 字段，而不是你 POST payload 里传的值。所以必须从**已发布的 npm 包**里去掉 `repository`，光在提交脚本里设空没用。

## 何时使用

- 新增一个 DSH 子包后要发布上架
- 子包更新后要 bump 版本重新提交 DSH
- 复查某个子包为什么在 DSH 没独立条目（多半是还带着 repository）

## 何时不用

- 发布根包 `@yumingtao/agent-skills` —— 它是 `private: true`，**绝不发布**
- 非 DSH 渠道的发布（npm / SkillHub / ClawHub 各有各的流程，不在此技能范围）
- 只是查 DSH 上架状态而不发布 —— 直接用 `scripts/check-dsh-live.py`

## 前置条件

- 已 `npm login`（`npm whoami` 应为 `yumingtao`）
- 子包的 `package.json` 已不带 `repository` 字段（生成器模板 `dsh-plugin/_generate-packages.mjs` 已确保新生成的不带；存量包需手动确认）
- 子包已有 `dsh` 字段（`bundle` 或 `client`），README 和 LICENSE 齐全

## 执行步骤

### 步骤 0：确认子包不带 repository（首次发布或存量包必做）

检查目标包的 `package.json`：

```bash
node -e "const p=require('./dsh-plugin/packages/<skill>/package.json'); console.log('repo:', p.repository||'(none)','| v:', p.version)"
```

如果输出有 `repository`，删掉它（保留 `homepage` 和 `bugs`）。用 `dsh-plugin/_generate-packages.mjs` 重新生成也行（模板已不带 repository）。

### 步骤 1：bump 版本 + npm publish

在子包目录里执行。**monorepo 不打 git tag**，用 `--no-git-tag-version`：

```bash
cd dsh-plugin/packages/<skill>
npm version patch --no-git-tag-version   # 或 minor / 具体 x.y.z
npm publish
```

记下输出里的新版本号。根包 `@yumingtao/agent-skills` 永远不要 publish。

### 步骤 2：等 npm CDN 同步（关键，不可跳过）

`npm publish` 返回成功后，**metadata 和 tarball 不会立即可用**——npm 的 CDN 边缘节点同步有延迟（通常 1–5 分钟）。表现为：
- `dist-tags.latest` 已更新到新版本，但 tarball 下载 404
- 或 metadata 还停在旧版本（仍带 repository）

**必须等到全部就绪才能提交 DSH**，否则 DSH 服务端 re-fetch 拉不到 tarball 或拉到旧 metadata，会报误导性错误 `The repository could not be re-fetched server-side`，导致提交失败。

用本技能的等待脚本（不依赖工作目录，任意位置可执行）：

```bash
python3 local-skills/dsh-publish/scripts/wait-npm-sync.py yumingtao-<skill>
# 多个包一起等：
python3 local-skills/dsh-publish/scripts/wait-npm-sync.py yumingtao-a yumingtao-b yumingtao-c
```

脚本每 30 秒查一次，直到每个包都满足：metadata 无 `repository` + tarball HTTP 200，并打印当前 latest 版本供你肉眼确认是新版本。全部就绪后退出。

### 步骤 3：提交到 DSH

用本技能的提交脚本（复刻官方 checker 页面的 POST 逻辑，含客户端安全扫描）：

```bash
# 先 scan-only 预检查（不提交），看扫描结果和 entry id
python3 local-skills/dsh-publish/scripts/dsh-submit.py yumingtao-<skill>

# 确认 entry id = 包名（不是 agent-skills）、source=npm-registry、扫描无 critical 后，加 --submit 提交
python3 local-skills/dsh-publish/scripts/dsh-submit.py yumingtao-<skill> --submit
```

成功返回 `{"ok":true,"id":"...","url":"https://github.com/ihuajiu/dsh-plugin-submissions/issues/<N>","number":<N>}`。**有独立的 issue URL/number 说明是独立条目**；如果被归并，会返回 `url:null`。

> `{"ok":true}` 只是**入队**，artifact 页不会立即生成——进入维护者审核队列，合并后才上架。不要因为 404 就判定失败。

### 步骤 4：轮询上架状态

提交后查上架状态（可反复运行，一次性查询）：

```bash
python3 local-skills/dsh-publish/scripts/check-dsh-live.py yumingtao-<skill>
# 查全部 7 个：
python3 local-skills/dsh-publish/scripts/check-dsh-live.py yumingtao-diagram-generator yumingtao-clarify-before-acting yumingtao-insight-challenge yumingtao-workflow-skill-designer yumingtao-defect-detective yumingtao-session-retrospective yumingtao-skill-maintainer
```

上架标志：artifact 页 `https://www.dsh.so/artifact/<pkg>/` 返回 HTTP 200，且 `search-index-core.json` 里有命中。审核通常需要几小时到 1–2 天。

需要长时间后台监控时，可起一个后台循环反复调 `check-dsh-live.py`：

```bash
# 后台每 5 分钟查一次，最长 6 小时
nohup zsh -c 'for i in $(seq 1 72); do python3 local-skills/dsh-publish/scripts/check-dsh-live.py <pkg>; sleep 300; done' > /tmp/dsh-poll.log 2>&1 &
```

### 步骤 5：commit + push package.json 改动

bump 版本 + 去 repository 的 `package.json` 改动要入库。**走 `public-push-check` 技能的 9 项清单**后再 push（本仓库公开远端，必须检查）。

## 批量发布多个包

一次性处理多个包时，按顺序串起来：

1. 逐个（或用脚本批量）改 `package.json`：去 repository + bump patch
2. 逐个 `npm publish`
3. **一次性** `wait-npm-sync.py` 传所有包名，等全部就绪
4. 逐个 `dsh-submit.py --submit`
5. `check-dsh-live.py` 传所有包名监控
6. 统一 commit + push（一次提交覆盖多个包的 package.json）

## 踩坑记录（不要重蹈）

- **npm tarball CDN 滞后**：publish 成功 ≠ 立即可下载。metadata 可能先刷新（latest 变了）但 tarball 还 404；也可能 metadata 还停在旧版。**不等到 `无 repo + tarball 200` 就提交 DSH，服务端会 re-fetch 失败并报 "repository could not be re-fetched"**——这个错误信息有误导性，实际是 tarball/metadata 没同步。
- **去掉 repository 必须是已发布的 npm metadata**：在 `dsh-submit.py` 的 POST payload 里把 `repository` 设空字符串没用，DSH 服务端会重新拉 npm 包的真实 metadata。必须先 publish 一个不带 repository 的版本，等同步后再提交。
- **monorepo 不要打 git tag**：用 `npm version patch --no-git-tag-version`，否则每个子包发版都会在 git 里留一个 tag，污染仓库。
- **根包不能发**：`@yumingtao/agent-skills` 是 `private: true`，`npm publish` 会被拒绝，这是正确的，不是故障。
- **DSH 审核是异步的**：`ok:true` 是入队回执，不是上架确认。artifact 页 404 持续几小时到 1–2 天属正常。用 `check-dsh-live.py` 确认，别反复提交（重复提交会重复入队）。
- **checker 页面 vs 脚本二选一**：官方 checker 页面（`https://www.dsh.so/check`）能可视化验证格式 + 安全扫描，但批量时用脚本更快。两者提交到同一个 `/api/submit`，效果等价。首次发布某个包建议先用 checker 页面肉眼确认 "No Git repository — npm only"，批量后续包用脚本即可。

## 脚本说明

| 脚本 | 作用 |
|---|---|
| `scripts/wait-npm-sync.py` | 等 npm CDN 同步：轮询直到指定包 metadata 无 repository + tarball 200 |
| `scripts/dsh-submit.py` | 复刻 DSH 官方 checker：拉 npm metadata + tarball → 安全扫描 → 构建 entry → 可选 POST 提交 |
| `scripts/check-dsh-live.py` | 查 DSH 上架状态：artifact 页 HTTP + search-index 命中数（一次性查询） |

所有脚本只依赖 Python 标准库，不依赖当前工作目录，任意位置可执行。
