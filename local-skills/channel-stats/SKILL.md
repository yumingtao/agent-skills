---
name: channel-stats
description: 统计本仓库（yumingtao/agent-skills）7 个已发布技能在各渠道的下载量与收录状态，输出统一汇总表格。覆盖 npm、SkillHub、ClawHub、skills.sh、DSH 五个渠道。触发词：「统计各渠道下载量」「看下下载量」「渠道数据」「各渠道下载量」「stats」。仅在 agent-skills 工作区内使用。
---

# 渠道下载量统计（channel-stats）

为本仓库的 7 个已发布技能，拉取各分发渠道的最新下载量与收录状态，汇总成一张表。

适用范围：仅 `yumingtao/agent-skills` 仓库。技能清单、namespace、账号名都硬编码在脚本里，换仓库不适用。

## 何时使用

- 「统计各渠道下载量」「看下下载量」「各渠道下载量」「渠道数据」
- 需要对比各平台分发效果、看某个技能的跨渠道表现
- 复查 DSH 审核队列是否有子包新上架

## 何时不用

- 只看某一个渠道的实时数据且不需要汇总——直接调用对应脚本段即可
- 非本仓库的技能统计

## 渠道与数据来源

| 渠道 | 取数方式 | 指标 |
|---|---|---|
| npm | 脚本（纯 API） | 7 个包 last-week / last-month 下载量 |
| SkillHub | 脚本（纯 API） | 7 个技能 downloads |
| ClawHub | **浏览器渲染**（SPA，脚本拿不到） | 8 个条目（7 技能 + 1 别名）的下载量 |
| skills.sh | 脚本（HTML 解析） | 已索引技能数量（平台不公开单技能下载量） |
| DSH | 脚本（HTTP 状态 + 搜索索引） | 7 个子包 artifact 页是否上架 + 根包状态 |

## 执行步骤

### 第 1 步：跑脚本取 4 个渠道（npm / SkillHub / skills.sh / DSH）

运行本技能目录下的取数脚本（脚本只做网络请求，不依赖当前工作目录，任意位置都可执行）：

```bash
python3 <本技能所在目录>/scripts/fetch-stats.py
```

在本仓库根目录下，等价于：

```bash
python3 local-skills/channel-stats/scripts/fetch-stats.py
# 或通过项目级软链：
python3 .trae/skills/channel-stats/scripts/fetch-stats.py
```

脚本输出四段：NPM、SkillHub、skills.sh、DSH。直接把数字抄进汇总表。

> 如果 `python3` 不可用或网络失败，脚本报错会标注是哪一段，其余段不受影响。

### 第 2 步：浏览器渲染抓 ClawHub

ClawHub 是 SPA，`curl` 只能拿到空壳；且其 API 的 `?ownerHandle=` / `?author=` 参数被忽略（返回全局列表），直查 `api/v1/skills/<slug>` 对 diagram-generator 会命中别名条目。**以网页渲染的发布者目录为准。**

1. 用浏览器工具打开 `https://clawhub.ai/@yumingtao`（新标签页）。
2. 等待 3 秒让页面渲染完成。
3. 执行页面脚本提取发布者目录的文本：

   ```js
   (() => {
     const el = document.querySelector('[aria-label="Publisher catalog"]')
             || document.querySelector('main');
     return el ? el.innerText : document.body.innerText;
   })()
   ```

4. 解析文本：每个技能卡片里，技能名下方那行 `0  <N>`，**第二个数 N 是下载量**（第一个 0 是收藏数）。

   账号下共有 **8 个条目 = 7 个技能 + 1 个重复别名**「Diagram Generator Clawhub」。别名的下载量要**单独列示**，不混入 7 技能的合计。

### 第 3 步：汇总成表

按下表输出，数值全部来自上面两步的实时结果，不要估算、不要复用上一次的旧数（数据每天都在变）。

```
| 技能 | npm 近月 | npm 近周 | SkillHub 下载 | ClawHub 下载 | skills.sh | DSH |
|---|---:|---:|---:|---:|---|---|
| diagram-generator | ... | ... | ... | ... | ✅ 已索引 | ⏳/✅ |
| ...（7 行）... |
| 合计 | ... | ... | ... | ... | 8 个技能 | N/7 上架 |
```

然后补一段「各渠道总览」：

```
| 渠道 | 下载量 | 说明 |
|---|---:|---|
| npm | 近月 X / 近周 Y | 根包 @yumingtao/agent-skills 为 private（不公开） |
| ClawHub | X（7 技能）/ 含别名 Y | 8 条目 = 7 技能 + 1 别名 |
| SkillHub | X | namespace=user_95900c57；installs 字段恒 0，安装量=downloads |
| skills.sh | — | 已索引 N 个；平台不公开单技能下载计数 |
| DSH | X/N 上架 | 子包在审核队列；根包 agent-skills-3 状态 |
```

如果用户要对比上一次，把这次与上次的差值（+/-N）也列出来。

## 踩坑记录（不要重蹈）

- **SkillHub host 是 `api.skillhub.cn`，不是 `skillhub.cn`**；后者返回 SPA HTML。namespace 是 `user_95900c57`，**不是 `yumingtao`**（那是 npm/clawhub 的 handle，SkillHub 用另一套 ID）。slug 要带 `yumingtao-` 前缀。API 的 `installs` 字段恒为 0，页面展示的安装量实际是 `downloads` 字段（在 `skill.stats` 下）。
- **ClawHub 是 SPA**，必须浏览器渲染。`?ownerHandle=yumingtao` 不生效；`api/v1/skills/<slug>` 对 diagram-generator 命中的是别名条目（数值偏低）。以 `clawhub.ai/@yumingtao` 渲染页的发布者目录为准。账号有 1 个「Diagram Generator Clawhub」别名，要单独标注，别算进 7 技能合计。
- **DSH**：npm-only 提交返回 `{"ok":true}` 只是入队，**artifact 页不会立即生成**——提交进入维护者审核队列，合并后才上架。`url:null` 是正常的。查上架状态 = 查 `https://www.dsh.so/artifact/<pkg>/` 的 HTTP 状态 + `search-index-core.json` 里的命中数。不要因为 404 就判定提交失败。
- **skills.sh**：仓库根包页不显示单技能下载计数，只能统计"索引了几个技能"。索引数靠解析页面里 `/yumingtao/agent-skills/<slug>` 链接，记得排除 `opengraph-image` 这个静态资源。
- **npm**：根包 `@yumingtao/agent-skills` 是 `private: true`，查询返回 404 是正确的，不是故障。defect-detective / session-retrospective / skill-maintainer 发布较近时可能出现「近周 = 近月」，属正常（下载集中在最近 7 天窗口）。

## 输出要求

- 全部数值**实时取**，不复用历史数据。
- 标明数据采集日期。
- 注明各指标来源（API / 页面渲染），让结果可追溯。
- ClawHub 的别名条目单独说明，避免合计被误读。
