# 图表生成器

图表生成器是一套平台中立的指令包，用于创建独立的专业技术系统图。它将架构简报、代码库笔记、部署描述、信任边界叙述和流程说明，转换为单个可在浏览器中打开的 HTML 文件（内联 SVG）。

该包面向 Claude、Codex、Cursor、OpenCode、Windsurf、Gemini、GitHub Copilot、CodeBuddy 和 Hermes 等智能体环境。共享行为位于 `resources/` 中；平台文件是有意精简的适配器，将各平台路由到相同的生成与审计工作流。

## 产出物

生成器从七种视角（lens）中选择一种，渲染独立 HTML/SVG 图。以下是各视角的实例，均由简短简报渲染并通过 `scripts/check-diagram.mjs` 校验。

> 下方示例图片托管于 GitHub。`docs/*.png` 和 `LICENSE` 文件属于源仓库；某些打包目标（如 SkillHub）会从分发包中剥离图片和许可证文件。

### 系统视角

![系统图：含客户端、API 网关、服务、PostgreSQL、Redis、Kafka、对象存储和 OIDC 提供方的电商平台](https://raw.githubusercontent.com/yumingtao/agent-skills/main/skills/diagram-generator/docs/example-system-map.png)

服务关系、用户入口、存储归属、外部集成和运维上下文。

### 基础设施视角

![基础设施图：多区域部署，含 CDN、全局负载均衡、两个 Kubernetes 区域、托管数据库、对象存储和消息总线](https://raw.githubusercontent.com/yumingtao/agent-skills/main/skills/diagram-generator/docs/example-infrastructure-map.png)

区域、集群、网络、网关、托管服务、对象存储、队列、容器和部署位置。

### 信任边界视角

![信任图：公共客户端跨越信任边界，在私有服务运行前执行认证、令牌校验、策略和密钥管理](https://raw.githubusercontent.com/yumingtao/agent-skills/main/skills/diagram-generator/docs/example-trust-map.png)

身份提供方、公有/私有边界、特权操作、密钥、策略检查、令牌校验和管理路径。

### 数据流动视角

![数据流图：Web 和 IoT 生产者汇入事件流，分发到数据仓库、搜索索引和对象存储](https://raw.githubusercontent.com/yumingtao/agent-skills/main/skills/diagram-generator/docs/example-data-movement-map.png)

摄取、复制、事件流、持久记录、转换、搜索索引、导出和报表。

### 流程视角

![流程图：从提交到构建、测试、审批、预发和生产的 CI/CD 流水线，含监控反馈回路](https://raw.githubusercontent.com/yumingtao/agent-skills/main/skills/diagram-generator/docs/example-process-map.png)

有序交互、审批链、事件响应、自动化流水线和类序列流。

同时支持：**实现图**（仓库推导的阶段、脚本执行链、生成产物）和**部署位置图**（工作负载到基础设施的分配）。

## 输出契约

默认输出为 `html-first`：一个独立 `.html` 文件，包含：

- 内联 SVG
- 嵌入 CSS
- 无外部运行时或网络依赖
- SVG 下载
- PNG 下载
- 浏览器支持时的 PNG 复制
- 打印/PDF 支持
- 用于系统形态、关键流和运维注释的 notes 栏

Draw.io XML 是可选的，仅当 draw.io 或 Confluence draw.io 中的可编辑性是工作流的一部分时才应请求。

## 目录结构

```text
diagram-generator/
├── README.md
├── SKILL.md
├── AGENTS.md
├── GEMINI.md
├── COPILOT-INSTRUCTIONS.md
├── CODEBUDDY.md
├── HERMES.md
├── LICENSE
├── agents/
│   └── openai.yaml
├── resources/
│   ├── generation-rules.md
│   ├── diagram-ir.md
│   └── template.html
├── scripts/
│   └── check-diagram.mjs
├── examples/
│   ├── architecture-brief.md
│   ├── codex-cli-example.txt
│   ├── codex-smoke-test-prompt.md
│   ├── drawio-mode-prompt.md
│   └── portable-agent-smoke-test-prompt.md
├── docs/
│   ├── example-system-map.png
│   ├── example-infrastructure-map.png
│   ├── example-trust-map.png
│   ├── example-data-movement-map.png
│   └── example-process-map.png
├── tests/
│   ├── platform-smoke-tests/
│   └── fixtures/
│       ├── example-commerce-system-map.html
│       └── bad-injected-defects.html
└── RELEASE_CHECKLIST.md
```

## Installation

下方按平台给出安装方式：核心是把本目录放到平台的技能/指令目录，并保证 `resources/` 可访问。中文环境同样适用，触发词见 SKILL.md。

### Claude

Place or link this directory under a Claude skills folder:

```bash
mkdir -p ~/.claude/skills
ln -s /absolute/path/to/diagram-generator ~/.claude/skills/diagram-generator
```

Then ask:

```text
Use the diagram-generator skill to create a system map from this brief:

[paste brief]
```

### Codex, Cursor, OpenCode, Windsurf

Use `AGENTS.md` as the project instruction source and keep `resources/` available. The adapter points these platforms to the shared files, lens/output-mode selection, placeholder replacement, and the final audit. For Codex skill-style use:

```bash
mkdir -p ~/.codex/skills
ln -s /absolute/path/to/diagram-generator ~/.codex/skills/diagram-generator
```

### Gemini

Use `GEMINI.md` as the Gem or project instruction. Add `resources/generation-rules.md`, `resources/diagram-ir.md`, and `resources/template.html` as project knowledge when direct file access is unavailable.

### GitHub Copilot

Use `COPILOT-INSTRUCTIONS.md` as the custom instruction source, or copy its content into a repository instruction file.

### CodeBuddy

Use `CODEBUDDY.md` as the workspace rule file.

### Hermes

Use `HERMES.md` as the task specification and keep `resources/` available in the workspace.

## 使用模式

1. 提供简报或要求智能体检查代码库。
2. 指定想要的视角：system、implementation、infrastructure、trust、data movement、deployment 或 process。
3. 除非明确需要 draw.io 可编辑性，否则生成 `html-first` 产物。
4. 发布前要求一次视觉审计。

## 冒烟测试

平台特定的冒烟提示位于 `tests/platform-smoke-tests/`。

发布前或修改 `resources/` 后使用：

- `claude.md`
- `codex.md`
- `gemini.md`
- `copilot.md`
- `codebuddy.md`
- `agents.md` 适用于 Cursor、OpenCode、Windsurf 和类似智能体

每个冒烟测试验证智能体使用 `html-first`、遵循地图集风格模板、默认隐藏 draw.io、输出不含占位符文本的 notes 栏，并能在修改现有图表时保留不相关内容。

## 输出检查器

每个生成的产物在返回前必须通过零依赖校验器：

```bash
node scripts/check-diagram.mjs <output-file.html>
```

它校验占位符清除、notes 栏存在、自包含性、标记完整性、IR 几何（节点边界、重叠、连线端点、区域边界、区域包含且每边至少 10px 间距）、`data-node-id`/`data-edge-id` 与 IR 的交叉核对，以及可选的 `labelAnchor` 重叠检查。警告不阻断；错误以退出码 1 结束。

### 错误码

Every checker message carries a stable, machine-greppable code prefix (`[Exxx]` errors, `[Wxxx]` warnings) so callers can classify failures without parsing prose:

| Code | Category | Notes |
|------|----------|-------|
| E001 | Usage | No input path given |
| E002 | IR parse | `#diagram-ir` slot is not valid JSON |
| E003 | Regions | Region ids/bounds/containment violations |
| E004 | IR structure | Missing/duplicate ids, missing nodes/edges arrays |
| E005 | Bounds | Node/region bounds invalid or outside the viewBox |
| E006 | Node overlap | Two node bounds intersect |
| E007 | Edge references | Missing or unknown source/target node |
| E008 | SVG–IR mismatch | `data-node-id`/`data-edge-id` not cross-consistent |
| E009 | Markers | Undefined marker reference or fill mismatch |
| E010 | Placeholder | Template placeholder text still present |
| E011 | Notes rail | `<aside class="notes">` missing |
| E012 | Self-containment | External or relative asset reference |
| E013 | Label anchor | `labelAnchor` invalid or sitting on a node |
| E014 | Connector geometry | Endpoint off-node, path through node, border-hugging |
| E099 | Uncategorized | Any error not yet mapped — report it so it gets a code |
| W001 | Legacy mode | No IR slot found; geometry checks skipped |
| W002 | Revise scope | `mode: revise` without `edit_scope` |
| W003 | Export UI | Optional toolbar / `#system-map` SVG absent |
| W004 | Path syntax | Unsupported SVG path syntax; endpoint geometry unchecked — review manually |

退出码：无错误时为 `0`（允许警告），有任何错误时为 `1`。

已知良好的参考产物位于 `tests/fixtures/example-commerce-system-map.html`——它渲染下方的示例提示词简报，并以零错误零警告通过检查器。CI 在每次推送时重新运行检查器，因此在修改检查器规则或模板时保持它为绿色。

已知不良的测试夹具位于 `tests/fixtures/bad-injected-defects.html`——已知良好产物注入了四个缺陷（模板占位符残留、节点边界超出 viewBox、区域 `contains` 条目引用不存在的节点、节点紧贴区域边框）。CI 断言检查器拒绝它（非零退出）并报告全部四类缺陷；这证明检查器是失败关闭的，而不仅仅是能通过良好样本。

## 质量指引

以下规则保证生成结果可维护、可审计：

- 将可复用行为放在 `resources/generation-rules.md`。
- 将规划模型放在 `resources/diagram-ir.md`。
- 将 HTML/SVG/CSS 基础放在 `resources/template.html`。
- 保持平台文件简短；它们应将智能体路由到共享资源，而非重述。
- 当必需行为变更时，保持平台适配器与 `SKILL.md` 同步。
- 对较小上下文模型使用两步工作流：先将系统规范化为参与者、组件、存储、流和风险；再从该规范化计划生成最终 HTML。
- 对现有图表编辑，优先局部坐标和连线修改，而非完整重新生成。
- 将 draw.io XML 视为导出适配器，而非默认渲染目标。

## 输出模式

### `html-first`

默认模式。优先视觉清晰度、可读标签、正确连线和精致的独立 HTML 产物。

Prompt:

```text
Create a system map for this platform:

[brief]
```

### `html + drawio xml`

实验性且需主动启用。当用户想要浏览器可查看的产物加上模型生成的 draw.io XML 时使用。在依赖前，在 draw.io 中对 XML 进行导入测试。

Prompt:

```text
Create a system map in html + drawio xml mode:

[brief]
```

### `drawio-first`

计划中。此模式在包含专用 mxGraphModel 规则、模板和导入验证之前不具备生产就绪性。

## 示例提示词

```text
Create a standalone HTML system map for:

- Web and mobile clients enter through a CDN and API gateway.
- Backend services include users, catalog, orders, payments, and notifications.
- PostgreSQL stores transactional records.
- Redis caches sessions and hot catalog reads.
- Kafka carries order-created and payment-completed events.
- Object storage keeps invoices and exports.
- An external OIDC provider handles identity.
- Everything runs in Kubernetes behind ingress.

Use the default html-first mode. Keep visible text in English.
```

## 设计原则

图表应解释行为，而不只是罗列组件。核心原则：

- 图表应解释行为，而不只是罗列组件。
- 每个产物使用一个抽象层级。
- 展示所有权边界、持久状态、异步移动、信任控制和运维观察点。
- 在添加次要路径前保持主路径可读。
- 偏好简洁标签，将较长解释放入 notes 栏。
- 不依赖外部图片、字体、脚本或构建工具。

## 发布

发布前，删除本地冒烟测试输出（`tests/fixtures/` 下的已检入夹具保留）并运行 `RELEASE_CHECKLIST.md`。

## FAQ & Common Pitfalls

以下是使用中最常见的问题及其处理方式。中文环境下可直接用对应触发词生成图表，标签和注释语言跟随用户偏好。

**Q: The checker reports an edge collinear with a node or region border. What do I do?**
A: Reroute the connector so it exits a node edge perpendicularly and travels in the free space between nodes. Never run a connector along the outer edge of its own source or target node, and avoid segments that share more than ~12 px with any region border.

**Q: A node overlaps a region it should sit inside.**
A: The checker enforces a 10 px gutter between every node and the region border. Shrink the node or expand the region; do not place nodes flush against a border.

**Q: draw.io XML fails to import in draw.io / Confluence.**
A: `html + drawio xml` mode is experimental. Always import-test the XML before relying on it. If editability is not required, use the default `html-first` mode, which is production-ready.

**Q: The generated HTML has leftover placeholder text.**
A: Every `{{...}}` token in `resources/template.html` must be replaced with concrete content. The checker fails on any residual placeholder. Do not leave template defaults in a delivered artifact.

**Q: Can I edit an existing diagram instead of regenerating it?**
A: Yes — prefer local coordinate and connector changes over full regeneration. Inspect the current artifact first and preserve unrelated nodes, notes, and color semantics.

**Q: The diagram looks cluttered.**
A: Use the notes rail for longer explanations instead of crowding the canvas. Keep one abstraction level per artifact and put secondary flows behind the main path.

**Q: Which lens should I pick?**
A: System for components/flows, infrastructure for deployment topology, trust for security boundaries, data movement for ingestion/streams, process for ordered pipelines, deployment for workload placement, implementation for code-derived stages. When unsure, start with a system map.

**Q: Why are images and LICENSE missing from my installed copy?**
A: Some distributors (e.g. SkillHub) strip PNG images and standalone LICENSE files from the package for security/format reasons. The canonical images and license are always available in the source GitHub repository.
