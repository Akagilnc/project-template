# CLAUDE.md

## 目的
本文件定义本仓库中的默认执行规则。
除非我在当前对话中明确覆盖，否则默认遵守以下要求。

## 角色原则
- 角色由当前任务决定，而不是由工具名称决定。
- 实现任务、调试任务、重构任务、测试任务、review 任务都可能发生切换。
- 无论当前由哪个 agent 执行任务，都应遵守本文件中的共享规则。
- 如果当前任务是 review，则应以审查质量、风险和验证完整性为重点。
- 如果当前任务是实现，则应以最小改动、可验证、可回滚为重点。

## 工作语言
- 与我沟通使用中文。
- 代码注释使用英文。
- commit message 使用英文。
- PR 标题和描述默认使用英文；如我另有要求，按我要求执行。
- 写在 `~/.gstack/projects/` 下面的长文本（design doc / plan / checkpoint / retro /
  builder journey / learnings export / 本地便签）**属于沟通材料不属于工程产物**，
  必须**默认用中文写**，不是英文写完再翻译。英文仅限代码注释、commit message、
  PR 标题和描述。**本规则历史上出现过多次 regression，要主动自检**。

## 沟通风格
- 简洁直接，少说废话。
- 不要为了迎合我而同意；有不同意见直接说。
- 不确定就明确说不确定，不要编造。
- 我熟悉工程实践和架构设计，不需要解释基础概念。
- 涉及具体实现决策时，简要说明理由，尤其是：
  - 为什么选这个库
  - 为什么用这种数据结构
  - 为什么这样拆模块
  - 为什么这样设计测试

## 默认工作流程（最高优先级）
收到任何开发任务后，默认按以下顺序执行：

1. 先阅读相关代码、测试、配置和上下文
2. 给出简洁方案，至少包括：
   - 目标
   - 做法
   - 涉及文件
   - 验证方式
   - 风险 / 备选项（如有）
3. 等我确认方案后，才开始修改仓库内容
4. 实现时优先做最小可行修改
5. 完成后进行验证、整理改动并提交

只有用户明确表达"开始改 / 动手 / 可以实现 / proceed / go / 做 / 写 / 合并"等，才算授权修改仓库内容。
用户对方案的评价、讨论、补充、认可，默认不构成修改授权。
只要下一步会修改仓库内容，必须先检查当前对话里是否存在明确授权；没有就停留在方案 / 分析 / 验证阶段。

如果存在多种可行方案，先列出主要方案及其优缺点，由我决定。

## 未经确认前允许做的事
- 阅读代码
- 搜索代码库
- 查看测试
- 运行现有测试
- 复现问题
- 查看日志、配置、报错信息
- 梳理影响范围
- 输出方案

## 未经确认前禁止做的事
- 修改仓库内容（包括实现代码、测试、配置、文档）
- 新增或删除依赖
- 调整目录结构
- 修改 public API / 接口契约
- 修改数据库 schema / migration
- 修改数据流向
- 修改 CI/CD、部署逻辑
- 修改环境变量结构
- 做会影响现有行为的重构

## TDD / 验证规则
凡是会改变行为的代码，默认走 TDD：

1. 先写失败的测试
2. 运行测试，确认失败
3. 展示真实失败输出
4. 编写最小实现让测试通过
5. 再次运行测试，确认通过
6. 展示真实通过输出

补充规则：
- 没有验证的代码不算完成。
- 不要伪造测试结果，不要假装运行测试。
- 如果不适合写自动化测试，必须先说明原因，再给出最小可行验证方式。
- 文档、文案、纯配置变更可不强制 TDD，但若会影响行为，仍需给出验证方式。
- 真实文件系统测试必须使用临时隔离路径，不得直接操作仓库内共享目录；测试结束后必须可重复执行且无残留。
- 如果测试结果依赖执行环境（如 sandbox、权限、终端、操作系统差异），必须明确区分"环境失败"和"代码失败"。
- 遇到环境相关失败时，不要直接下代码结论；先记录失败环境、命令和现象，并在可行时用另一执行环境交叉验证。
- 不要把单一环境下的通过结果视为充分证据，尤其是涉及真实文件系统、网络、子进程或平台工具链时。
- 凡是修改发帖链路、调度、Worker dispatch、平台集成或真实 API 交互相关逻辑，完成前必须说明本次实际验证覆盖了哪些路径；仅有单元测试通常不算充分验证。
- 任何 `throw new Error("...先 X 再重试...")` 形式的 user-facing 恢复提示，必须配套一条端到端测试：模拟做 X，断言再次走同一路径不再抛同一错。只测"X 前会抛"不够——必须同时测"X 后不再抛"。这是为了防止"错误提示描述的恢复流程"和"实现行为"之间出现单测捕获不到的 drift（反面例子：某次 PR round-4 P1 bug 的根因：提示说"跑 add-quality-rule 再重试"，但实现只认 git commit，recovery loop 死循环）。

## 实现原则
- 优先最小改动，不要顺手大改。
- 不要修改无关文件。
- 优先复用仓库里已有模式，不要随意新造抽象。
- 修改行为时，同步更新相关测试、类型、文档。
- 错误处理要完整，不要吞异常。
- 敏感信息必须走环境变量，绝对不能硬编码。
- 新增日志时避免泄露敏感信息。
- 没有明确理由时，不要引入新依赖。
- 单个文件和函数应尽量保持可维护；若明显变大，需要说明原因。

## Review 原则
当当前任务是 review 时，重点检查：
- 正确性
- 回归风险
- 边界条件
- 测试覆盖是否足够
- 改动范围是否失控
- 是否引入了不必要的复杂度
- 是否违反本仓库既有约定

review 默认应以指出问题、解释风险、给出建议为主。
除非我明确要求，否则不要在 review 场景中直接接管实现。

## 必须先确认的事项
以下事项必须先和我讨论，得到确认后才能动手：
- 新增依赖
- 引入新的抽象层
- 调整目录结构
- 修改 API 设计
- 修改数据流向
- 修改存储模型
- 修改数据库 schema / migration
- 修改 CI/CD 或部署方式
- 修改认证、权限、鉴权逻辑
- 修改环境变量设计

以下小型实现细节可自行决定：
- 变量命名
- 私有函数拆分
- 局部重构
- 小范围错误处理优化

## Git 工作流
Git 具体规则（Branch、Commit、PR、Review）遵循 `docs/process.md`。
以下为核心要求：
- 每个功能使用独立 feature branch。
- 每个 green checkpoint 及时 commit，避免 session 中断导致进度丢失。
- PR 描述中在适用时使用 `closes #N` / `fixes #N` / `resolves #N`。
- Issue / milestone / label 管理规则遵循 `docs/process.md`。

## 完成标准
满足以下条件才算完成：
- 方案已确认
- 代码已实现
- 已完成测试或等价验证
- 相关测试 / 文档 / 类型已同步更新
- 改动范围受控，没有无关修改
- 到达合适的 green checkpoint 时已提交 commit

## 冲突处理
规则优先级如下：
1. 我在当前对话中的明确指令
2. 本文件
3. `docs/process.md`
4. 仓库内其他一般性说明

如果你判断我的要求存在明显风险、错误或更差实现，直接指出，不要迎合。

## 环境诊断规则
- 安装任何工具前，先用 `which <tool>` 和常见路径（`/opt/homebrew/bin/`、`/usr/local/bin/`）检查是否已安装。
- 如果工具已安装但 Claude 找不到，优先排查 PATH 问题，不要直接重装。
- 遇到环境问题时，先诊断再行动；不确定时列出 2-3 个备选方案让用户选择，而不是一条路走到黑。

## 自治 TDD 开发 Loop

完整流程见 `~/WorkSpace/vault/ak-cc-wiki/wiki/concepts/tdd-autonomous-dev.md`。

当用户明确授权"自治 TDD"或等价表达时，按以下流程执行，**切片之间不停顿、不询问、不报告中间进度**。

**前置条件**：Plan view 各角色批准（CEO / Eng / Design / DX）

**切片**（只做一次）：把 plan 产出分成独立、中小粒度的提交单元。**默认整队列装 1 个 PR**，commit 维度分离 review 量；只有 diff > 2000 行 / 破坏性 schema migration / 用户要求 / drift 命中时才拆 PR。

**Per 切片 sN**（重复直到所有切片完成）：

1. **TDD Loop**：红（写 failing test）→ 绿（最小实现）→ 重构 → 分支覆盖率检查 → 未过补测试回绿
2. **自查**（窄）：类似 pattern bug / 修复引入新 bug
3. **Commit**（切片 baseline）
4. **Cross-model review**（含修复闭环）：
   - **N+1 并行启动**（**单条 message 内**同时发 N 个 Agent + 1 个 Bash codex exec）
     - N=1（< 200 行）/ N=2（200–500 行）/ N=3（500+ 行，empirically validated）
     - 外部声音降级链：`codex exec` → `gemini --approval-mode auto_edit` → Claude subagent（兜底，要 flag「缺 outside voice」）
     - 调用规范见 `~/WorkSpace/vault/ak-cc-wiki/wiki/concepts/codex-bot-conventions.md`
   - 收 findings → P0/P1 必修，P2/P3/P4 按 defer 协议（**显式分级 + 具体理由 + TODO 写入 PR `## Deferred Findings`**，不能"P1 私自降为 P2"）→ 自查 → commit → 下一轮
   - **跨切片 finding**（sN 发现 sM<N 的问题）：默认 fix-in-current（在 sN commit 里直接改 sM），不回滚 sM；架构级重做 → 强停 reground
   - 终止：(N+1)/(N+1) approve / bug 无法收敛（架构改进）/ drift 三联命中

**所有切片完成后**：
- `gstack-ship`（含内部 1+1 评审；**多次 ship 是正常的**，失败直接重跑，不切策略；同类 finding 重复 ≥ 3 次升级为 ship 阶段 drift）
- PR 创建后自动进 `pr-review-loop`（3 轮上限，Layer 3）

**停止点**：pr-review-loop 收敛后停下报告，等用户 E2E / smoke 测试 → 用户 merge。

**自治不停顿例外**（必须停下报告的情况）：
- (a) pr-review-loop 收敛，等 E2E
- (b) Drift 三联命中（强停 reground）
- (c) 4/4 始终无法收敛 / ship 同类 finding 重复 ≥ 3 次（架构建议）
- (d) 重大决策事件：实现与 plan 实质不符 / 引新依赖 / 接口契约变更 / 数据 migration / 安全鉴权改动

「我刚做完 s3 准备做 s4」「这一轮 review 完毕开始 fix」不是有效报告，吞掉。

进入条件：用户明确说"自治 TDD"或等价表达。未授权时仍按 `## TDD / 验证规则` 走。

## 长期状态文档
- `docs/current-state.md` 是长期存在的项目现状文档，不是一次性 handoff 便签。
- 该文件应只保留"当前真实状态"，不要堆历史聊天过程。
- 至少应覆盖：
  - 当前主流程 / 当前 MVP 语义
  - 进行中的 branch / PR / review 状态
  - 最近一次真实验证结果
  - 当前 blocker / 风险
  - 下一步建议
- 当以下信息发生实质变化时，应同步更新 `docs/current-state.md`：
  - 主流程或目录结构变化
  - PR / branch 状态变化
  - issue / milestone 计划重排
  - 真实 API / 端到端验证结果更新
  - blocker 被确认、解除或替换
- 更新时保持简洁、事实化、可接力，不要写成长篇日报。

## 经验复盘文档
- 阶段性的经验、教训、复盘不要写进 `docs/current-state.md`。
- 这类内容统一放在 `docs/retrospectives/`。
- `current-state` 负责"现在是什么状态"，`retrospectives` 负责"我们从过去学到了什么"。

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke gstack-office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke gstack-investigate
- Ship, deploy, push, create PR → invoke gstack-ship
- QA, test the site, find bugs → invoke gstack-qa
- Code review, check my diff → invoke gstack-review
- Update docs after shipping → invoke gstack-document-release
- Weekly retro → invoke gstack-retro
- Design system, brand → invoke gstack-design-consultation
- Visual audit, design polish → invoke gstack-design-review
- Architecture review → invoke gstack-plan-eng-review
- Save progress, checkpoint, resume → invoke gstack-context-save
- Code quality, health check → invoke gstack-health

<!-- TEMPLATE_END — 项目特有 sections 写在下面，sync script 不会覆盖下方内容 -->

