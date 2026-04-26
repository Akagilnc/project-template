# CLAUDE.md（项目级）

本项目继承全局规则与通用约定。本文件 TEMPLATE_END 上方是 schema 引导，下方放项目特有 boilerplate（设计 / 偏好 / 路径假设 / 关键架构事实等）。

## 引用层级

| 层 | 位置 | 内容 |
|---|---|---|
| 全局 hard rules + Claude 特有 | `~/.claude/CLAUDE.md` | SHARED block（违反 = 灾难的 9 条）+ Skill tool 行为 + 调用外部声音 CLI 规则 |
| 通用 dev conventions | `~/WorkSpace/vault/ak-cc-wiki/wiki/concepts/dev-conventions.md` | 角色 / 语言 / 沟通 / TDD 详细 / 实现 / Review / Git / 完成标准 / Skill routing 等 |
| Wiki 全部目录 | `~/WorkSpace/vault/ak-cc-wiki/wiki/index.md` | 概念页 / 实体页 / source / notes 完整索引 |
| 项目特有 | 本文件 TEMPLATE_END 下方 | 仅项目特定的设计 / 偏好 / 路径假设 / 架构事实 |

## 冲突优先级

用户当前对话指令 > 项目特有（本文件 TEMPLATE_END 下方）> 全局 hard rules > 通用 dev conventions > 项目 `docs/process.md`（如存在）

<!-- TEMPLATE_END — 项目特有 sections 写在下面，sync script 不会覆盖下方内容 -->
